conda create --name PY310 python=3.10 -y
conda activate PY310

pip3 install modelscope transformers==4.51.3
pip3 install accelerate autoawq


# 方案A: 如果你有NVIDIA显卡并需要CUDA加速（访问 https://pytorch.org 获取最新命令）
# CUDA 12.6
pip3 install torch==2.6.0 torchvision==0.21.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cu126

# 方案B: 如果你只有CPU，或不确定
pip3 install torch==2.6.0 torchvision==0.21.0 torchaudio==2.6.0

# 安装后，可在python中验证： import torch; print(torch.__version__); print(torch.cuda.is_available())