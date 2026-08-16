SGLANG_USE_MODELSCOPE=true SGLANG_USE_MLX=1 python -m sglang.launch_server \
  --model-path qwen/Qwen3-4B \
  --disable-cuda-graph \
  --port 30000