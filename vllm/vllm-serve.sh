conda create -n py312 python=3.12 -y
conda activate py312
pip install --upgrade uv
uv pip install vllm --torch-backend=auto
uv pip install modelscope


export MODELSCOPE_CACHE=/root/shared-nvme/cache/
export VLLM_USE_MODELSCOPE=True
export HF_ENDPOINT=https://hf-mirror.com

vllm serve "/root/shared-nvme/cache/models/Qwen/Qwen3-14B"  \
  --host 0.0.0.0  --port 8001  --served-model-name Qwen3-14B  \
  --tensor-parallel-size 2  --dtype float16 \
  --max-model-len 40960  \
  --gpu-memory-utilization 0.92  \
  --max_num_seqs 8  \
  --trust-remote-code   \
  --enable-auto-tool-choice  --tool-call-parse hermes

vllm serve "/root/shared-nvme/cache/models/Qwen/Qwen3-14B-AWQ"  \
  --host 0.0.0.0  --port 8001  --served-model-name Qwen3-14B-AWQ  \
  --tensor-parallel-size 2  --dtype float16  -q awq_marlin  \
  --max-model-len 40960  \
  --gpu-memory-utilization 0.92  \
  --max_num_seqs 8  \
  --trust-remote-code   \
  --enable-auto-tool-choice  --tool-call-parse hermes

vllm serve "/root/shared-nvme/cache/models/Qwen/Qwen3-8B"  \
  --host 0.0.0.0  --port 8001  --served-model-name Qwen3-8B  \
  --tensor-parallel-size 2  --dtype float16 \
  --max-model-len 40960  \
  --gpu-memory-utilization 0.92  \
  --max_num_seqs 8  \
  --trust-remote-code   \
  --enable-auto-tool-choice  --tool-call-parse hermes

vllm serve "/root/shared-nvme/cache/models/Qwen/Qwen3-8B-AWQ"  \
  --host 0.0.0.0  --port 8001  --served-model-name Qwen3-8B-AWQ  \
  --tensor-parallel-size 2  --dtype float16  -q awq_marlin \
  --max-model-len 40960  \
  --gpu-memory-utilization 0.92  \
  --max_num_seqs 8  \
  --trust-remote-code   \
  --enable-auto-tool-choice  --tool-call-parse hermes


curl http://127.0.0.1:8001/v1/models
curl http://127.0.0.1:8001/metrics

curl http://127.0.0.1:8001/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "Qwen3-8B-AWQ",
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Who won the world series in 2020?"}
        ]
    }'






# bench 4
vllm serve "/root/shared-nvme/cache/models/Qwen/Qwen3-14B"  \
  --host 0.0.0.0  --port 8001  --served-model-name Qwen3-14B  \
  --tensor-parallel-size 4  --dtype float16 \
  --max-model-len 40960  \
  --gpu-memory-utilization 0.92  \
  --max_num_seqs 32  \
  --trust-remote-code   \
  --enable-auto-tool-choice  --tool-call-parse hermes

vllm serve "/root/shared-nvme/cache/models/Qwen/Qwen3-14B-AWQ"  \
  --host 0.0.0.0  --port 8001  --served-model-name Qwen3-14B-AWQ  \
  --tensor-parallel-size 4  --dtype float16  -q awq_marlin \
  --max-model-len 40960  \
  --gpu-memory-utilization 0.92  \
  --max_num_seqs 32  \
  --trust-remote-code   \
  --enable-auto-tool-choice  --tool-call-parse hermes

vllm serve "/root/shared-nvme/cache/models/Qwen/Qwen3-8B"  \
  --host 0.0.0.0  --port 8001  --served-model-name Qwen3-8B  \
  --tensor-parallel-size 4  --dtype float16 \
  --max-model-len 40960  \
  --gpu-memory-utilization 0.92  \
  --max_num_seqs 32  \
  --trust-remote-code   \
  --enable-auto-tool-choice  --tool-call-parse hermes

vllm serve "/root/shared-nvme/cache/models/Qwen/Qwen3-8B-AWQ"  \
  --host 0.0.0.0  --port 8001  --served-model-name Qwen3-8B-AWQ  \
  --tensor-parallel-size 4  --dtype float16  -q awq_marlin \
  --max-model-len 40960  \
  --gpu-memory-utilization 0.92  \
  --max_num_seqs 32  \
  --trust-remote-code   \
  --enable-auto-tool-choice  --tool-call-parse hermes