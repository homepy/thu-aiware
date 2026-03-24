#1、环境安装

## ubuntu安装ffmpeg
apt update
apt install ffmpeg

## 环境1 vllm-omni
conda create -n hongpai-omni python=3.12 -y
conda activate hongpai-omni

pip install --upgrade uv

### 安装pytorch
uv pip install torch==2.10.0 torchvision==0.25.0 torchaudio==2.10.0 --index-url https://download.pytorch.org/whl/cu128

### 安装vllm
#### uv pip install vllm==0.17.0 --torch-backend=auto
uv pip install vllm==0.18.0 --torch-backend=auto

### 安装vllm-omni
cd /root/shared-nvme/
git clone https://github.com/vllm-project/vllm-omni.git
cd vllm-omni
uv pip install -e .

uv pip install matplotlib aiohttp soundfile numpy tqdm


conda deactivate

## 环境2 qwen3-tts
conda create -n hongpai-tts python=3.12 -y
conda activate hongpai-tts
pip install --upgrade uv

### 安装pytorch
uv pip install torch==2.10.0 torchvision==0.25.0 torchaudio==2.10.0 --index-url https://download.pytorch.org/whl/cu128


### 安装flash-attn
uv pip install ./flash_attn-2.8.3+cu128torch2.10-cp312-cp312-linux_x86_64.whl


uv pip install matplotlib aiohttp soundfile numpy tqdm


#2、 模型下载
uv pip install modelscope




source ~/shared-nvme/env
### ~/shared-nvme/env 的内容

export MODELSCOPE_CACHE=/root/shared-nvme/cache/
export VLLM_USE_MODELSCOPE=True

###

modelscope download --model Qwen/Qwen3-TTS-Tokenizer-12Hz  
modelscope download --model Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice
modelscope download --model Qwen/Qwen3-TTS-12Hz-0.6B-Base



#3、 bench

## 自动模式
MODEL=/root/shared-nvme/cache/models/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice NUM_PROMPTS=1 CONCURRENCY="1" bash benchmarks/qwen3-tts/run_benchmark.sh --async-only
MODEL=/root/shared-nvme/cache/models/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice NUM_PROMPTS=1 CONCURRENCY="1" bash benchmarks/qwen3-tts/run_benchmark.sh --hf-only


MODEL=/root/shared-nvme/cache/models/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice bash benchmarks/qwen3-tts/run_benchmark.sh --async-only
MODEL=/root/shared-nvme/cache/models/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice bash benchmarks/qwen3-tts/run_benchmark.sh --hf-only

## 手动模式

## bench 服务端
CUDA_VISIBLE_DEVICES=0 python -m vllm_omni.entrypoints.cli.main serve \
    "Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice" \
    --omni --host 127.0.0.1 --port 8000 \
    --stage-configs-path benchmarks/qwen3-tts/vllm_omni/configs/qwen3_tts_bs1.yaml \
    --trust-remote-code


vllm serve "/root/shared-nvme/cache/models/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice" \
    --stage-configs-path /root/shared-nvme/vllm-omni/vllm_omni/model_executor/stage_configs/qwen3_tts.yaml \
    --omni \
    --port 8091 \
    --trust-remote-code \
    --enforce-eager


## bench 客户端

python /root/shared-nvme/vllm-omni/benchmarks/qwen3-tts/vllm_omni/bench_tts_serve.py \
    --port 8091 \
    --num-prompts 50 \
    --max-concurrency 1 4 10 \
    --config-name "async_chunk" \
    --result-dir /root/shared-nvme/vllm-omni/benchmarks/qwen3-tts/results/


	
	

####压测时进程
####root       10022   10001 18 11:14 pts/1    00:00:25 python -m vllm_omni.entrypoints.cli.main serve /root/shared-nvme/cache/models/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice --omni --host 127.0.0.1 --port 8000 --stage-configs-pat
####root       11867   10001  5 11:16 pts/1    00:00:03 python /root/shared-nvme/vllm-omni/benchmarks/qwen3-tts/vllm_omni/bench_tts_serve.py --host 127.0.0.1 --port 8000 --num-prompts 100 --max-concurrency 1 --num-warmups 3 --
