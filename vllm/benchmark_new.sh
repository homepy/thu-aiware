#!/usr/bin/env bash
set -eo pipefail

# ============================== 配置区 ==============================
: ${OUTPUT_DIR:="/var"}                # 输出根目录（可设置环境变量）
: ${NUM_PROMPT_LIST:="1,2,4,8,16"}     # 并发数列表（可设置环境变量）
: ${HOST:="127.0.0.1"}                 # 服务IP（可设置环境变量）
: ${PORT:=8000}                        # 服务端口（可设置环境变量）
: ${INPUT_OUTPUT:="128 128,128 1024"}  # 输入输出长度组合（格式："ilen olen,ilen olen"）
: ${NUM_GPUS:=4}                       # vllm服务使用DCU数量

# 自动生成的日志目录，位于OUTPUT_DIR/output下
LOG_DIR="${OUTPUT_DIR}/vllm_benchmarks_log/${MODEL}/$(date +%Y-%m-%d-%H-%M-%S)"  
RESULT_CSV="${LOG_DIR}/${MODEL}-${NUM_GPUS}cards.csv"      # 结果汇总文件

# ============================== 函数定义 ==============================
validate_positive_int() {
  local value=${!1}
  if ! [[ "$value" =~ ^[1-9][0-9]*$ ]]; then
    >&2 echo "错误: $1 必须是正整数，当前值: '$value'"
    exit 1
  fi
}

validate_input_output_pairs() {
  if [[ -z "${INPUT_OUTPUT}" ]]; then
    >&2 echo "错误: INPUT_OUTPUT 不能为空"
    exit 1
  fi
  
  IFS=',' read -r -a pairs <<< "${INPUT_OUTPUT}"
  if [[ ${#pairs[@]} -eq 0 ]]; then
    >&2 echo "错误: INPUT_OUTPUT 格式无效，至少需要一个组合"
    exit 1
  fi

  for pair in "${pairs[@]}"; do
    IFS=' ' read -r -a len <<< "${pair}"
    if [[ ${#len[@]} -ne 2 ]]; then
      >&2 echo "错误: 输入输出长度组合格式错误: '${pair}'，应为'ilen olen'"
      exit 1
    fi
    if ! [[ "${len[0]}" =~ ^[1-9][0-9]*$ ]]; then
      >&2 echo "错误: 输入长度必须为正整数，当前值: '${len[0]}'"
      exit 1
    fi
    if ! [[ "${len[1]}" =~ ^[1-9][0-9]*$ ]]; then
      >&2 echo "错误: 输出长度必须为正整数，当前值: '${len[1]}'"
      exit 1
    fi
  done
}

validate_num_prompts_list() {
  if [[ ${#num_prompts_list[@]} -eq 0 ]]; then
    >&2 echo "错误: NUM_PROMPT_LIST 不能为空"
    exit 1
  fi
  for num in "${num_prompts_list[@]}"; do
    if ! [[ "$num" =~ ^[1-9][0-9]*$ ]]; then
      >&2 echo "错误: NUM_PROMPT_LIST 包含无效的并发数 '$num'，必须为正整数"
      exit 1
    fi
  done
}

init_logging() {
  # 确保输出目录存在
  mkdir -p "${OUTPUT_DIR}" || { 
    >&2 echo "无法创建输出目录: ${OUTPUT_DIR}"; 
    exit 1; 
  }
  
  # 创建日志目录
  mkdir -p "${LOG_DIR}/log/" || { 
    >&2 echo "无法创建日志目录: ${LOG_DIR}/log/"; 
    exit 1; 
  }
  
  # CSV 标题行（字段顺序严格对齐）
  echo "num_prompts,input_len,output_len,Benchmark Duration (s),Total Input Tokens,Total Generated Tokens,Request Throughput (req/s),Output Token Throughput (tok/s),Total Token throughput (tok/s),Mean TTFT (ms),Median TTFT (ms),P99 TTFT (ms),Mean TPOT (ms),Median TPOT (ms),P99 TPOT (ms),Mean ITL (ms),Median ITL (ms),P99 ITL (ms)" > "${RESULT_CSV}"
}

check_port() {
  local n=1
  local max_retry=10000
  local port=${PORT}
  local host=${HOST}

  # 检查nc是否安装
  if ! command -v nc &>/dev/null; then
    echo "错误：检测端口依赖 'nc'（netcat），请确保已安装。"
    exit 1
  fi

  echo "等待服务启动（主机：${host}，端口：${port}）..."

  while (( n <= max_retry )); do
    # 使用nc检测端口连通性
    if nc -zv -w 2 "${host}" "${port}" &>/dev/null; then
      echo -e "\n✅ 服务启动成功！"
      return 0
    fi

    echo -n "."
    sleep 5
    ((n++))
  done

  echo -e "\n❌ 等待超过 $((max_retry * 5)) 秒仍未检测到端口开放"
  exit 1
}

extract_metric() {
  local log_file=$1 pattern=$2
  # 使用精确匹配模式，避免歧义
  local value=$(grep -i -a "^[[:space:]]*${pattern}[[:space:]:]*" "${log_file}" | awk '{print $NF}' | tr -d ',')
  printf "%s" "${value:-NaN}"  # 空值处理防止列错位
}

run_benchmark() {
  local num_prompts=$1 input_len=$2 output_len=$3
  local log_file="${LOG_DIR}/log/${MODEL}-bs-${num_prompts}-inputlen-${input_len}-outputlen-${output_len}-$(date +%Y%m%d%H%M%S).log"
  
  echo "▶ 正在测试并发数: ${num_prompts} (输入长度: ${input_len}, 输出长度: ${output_len})"
  
  # 执行基准测试（带错误捕获）
  if ! vllm bench serve \
    --dataset-name random \
    --model "${MODEL}" \
    --tokenizer "${TOKENIZER}" \
    --num-prompts "${num_prompts}" \
    --random-input-len "${input_len}" \
    --random-output-len "${output_len}" \
    --trust-remote-code \
    --ignore-eos \
    --host $HOST \
    --port "${PORT}" 2>&1 | tee "${log_file}"; then
    >&2 echo "❌ 测试失败: 并发数 ${num_prompts} (输入:${input_len}, 输出:${output_len})"
    return 1
  fi

  # 严格按CSV列顺序定义提取模式
  local csv_row="${num_prompts},${input_len},${output_len}"
  while IFS= read -r pattern; do
    csv_row+=",$(extract_metric "${log_file}" "${pattern}")"
  done << EOF
Benchmark duration (s)
Total input tokens
Total generated tokens
Request throughput (req/s)
Output token throughput (tok/s)
Total Token throughput (tok/s)
Mean TTFT (ms)
Median TTFT (ms)
P99 TTFT (ms)
Mean TPOT (ms)
Median TPOT (ms)
P99 TPOT (ms)
Mean ITL (ms)
Median ITL (ms)
P99 ITL (ms)
EOF

  echo "${csv_row}" >> "${RESULT_CSV}"
  echo "✅ 数据已记录: ${log_file}"
}

# ============================== 主程序 ==============================
main() {
  # 参数验证
  validate_input_output_pairs
  IFS=',' read -r -a pairs <<< "${INPUT_OUTPUT}"

  # 解析并发数列表
  IFS=',' read -r -a num_prompts_list <<< "${NUM_PROMPT_LIST}"
  validate_num_prompts_list

  # 初始化日志系统
  init_logging

  # 检查服务端口是否就绪
  #check_port

  # 执行测试序列
  for current_num in "${num_prompts_list[@]}"; do
    for pair in "${pairs[@]}"; do
      IFS=' ' read -r -a len <<< "${pair}"
      input_len="${len[0]}"
      output_len="${len[1]}"
      if ! run_benchmark "${current_num}" "${input_len}" "${output_len}"; then
        break 2  # 出现错误时终止所有循环
      fi
    done
  done

  echo "✅ 测试完成！结果文件: ${RESULT_CSV}"
  echo "日志目录: ${LOG_DIR}"
}

# ============================== 执行入口 ==============================
main "$@"