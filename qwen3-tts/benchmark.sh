#1、环境安装
conda create -n vllm python=3.12 -y
conda activate vllm

pip install --upgrade uv

## 安装pytorch
uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

## 安装vllm
uv pip install vllm==0.17.0 --torch-backend=auto

## 安装vllm-omni
cd /root/shared-nvme/
git clone https://github.com/vllm-project/vllm-omni.git
cd vllm-omni
uv pip install -e .

uv pip install matplotlib aiohttp soundfile numpy tqdm

#2、 模型下载
uv pip install modelscope


source ~/shared-nvme/env
### ~/shared-nvme/env 的内容

export MODELSCOPE_CACHE=/root/shared-nvme/cache/
export VLLM_USE_MODELSCOPE=True

###


modelscope download --model Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice
modelscope download --model Qwen/Qwen3-TTS-12Hz-0.6B-Base 



#3、 bench
## bench 服务端






## bench 客户端




## 正常启动
vllm serve "/root/shared-nvme/cache/models/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice" \
    --stage-configs-path /root/shared-nvme/vllm-omni/vllm_omni/model_executor/stage_configs/qwen3_tts.yaml \
    --omni \
    --port 8091 \
    --trust-remote-code \
    --enforce-eager

python /root/shared-nvme/vllm-omni/benchmarks/qwen3-tts/vllm_omni/bench_tts_serve.py \
    --port 8091 \
    --num-prompts 1 \
    --max-concurrency 1 \
    --config-name "async_chunk" \
    --result-dir /root/shared-nvme/vllm-omni/benchmarks/qwen3-tts/results/



## bench启动 客户端发起请求时报错  
MODEL=/root/shared-nvme/cache/models/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice NUM_PROMPTS=1 CONCURRENCY="1" bash benchmarks/qwen3-tts/run_benchmark.sh --async-only
MODEL=/root/shared-nvme/cache/models/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice NUM_PROMPTS=1 CONCURRENCY="1" bash benchmarks/qwen3-tts/run_benchmark.sh --hf-only

MODEL=/root/shared-nvme/cache/models/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice  bash ./run_benchmark.sh


CUDA_VISIBLE_DEVICES=0 python -m vllm_omni.entrypoints.cli.main serve \
    "/root/shared-nvme/cache/models/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice" \
    --omni --host 127.0.0.1 --port 8000 \
    --stage-configs-path /root/shared-nvme/vllm-omni/benchmarks/qwen3-tts/vllm_omni/configs/qwen3_tts_bs1.yaml \
    --trust-remote-code


## 
python /root/shared-nvme/vllm-omni/benchmarks/qwen3-tts/vllm_omni/bench_tts_serve.py \
    --port 8000 \
    --num-prompts 1 \
    --max-concurrency 1 \
    --config-name "async_chunk" \
    --result-dir /root/shared-nvme/vllm-omni/benchmarks/qwen3-tts/results/




python transformers/bench_tts_hf.py \
    --model "Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice" \
    --num-prompts 50 \
    --gpu-device 0 \
    --result-dir results/
