# 进入容器
nerdctl exec -it autotest bash
 
# 可以使用以下语句测试是否通
curl http://127.0.0.1:8001/v1/models
 
# 在环境变量中配置测试参数
export MODEL=Qwen3-8B-AWQ # API 使用的模型名称
export TOKENIZER=/var/model/qwen3-32b # 分词器路径，主要需要
export NUM_PROMPT_LIST=1,4,8 # 测试并发数，每个并发数间用英文逗号隔开
export INPUT_OUTPUT='128 128,256 256,1024 512,2048 512,2048 1024,3072 1024' # 输入输出长度，支持输入多组，每组间以逗号分隔，输入输出长度间以空格分隔
export NUM_GPUS=2 # GPU数量
export HOST=28.105.66.202 # 服务器IP
export PORT=31126 # 服务端口号
# 关闭端口检查
cd /vllm/benchmarks
# 注释掉第183行的"check_port"
vim /vllm/benchmarks/benchmark.sh
# 执行测试
bash /vllm/benchmarks/benchmark.sh
 
#执行完成以后，控制台会输出csv文件路径