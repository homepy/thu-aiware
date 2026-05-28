import os
import torch
from modelscope import AutoModelForCausalLM, AutoTokenizer

os.environ['HF_ENDPOINT'] = 'https://hf-mirror.com'

class QwenChatbot:
    def __init__(self, model_name="Qwen/Qwen3-0.6B", use_half_precision=False):
        # 检测可用设备
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        print(f"Using device: {self.device}")

        # 加载分词器（无需移动）
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)

        # 加载模型，如果使用半精度则设置 torch_dtype
        if use_half_precision and self.device == "cuda":
            self.model = AutoModelForCausalLM.from_pretrained(
                model_name,
                torch_dtype=torch.float16
            )
        else:
            self.model = AutoModelForCausalLM.from_pretrained(model_name)

        # 将模型移动到目标设备（GPU 或 CPU）
        self.model.to(self.device)

        self.history = [{"role": "system", "content": "You are a helpful assistant."}]

    def generate_response(self, user_input):
        messages = self.history + [{"role": "user", "content": user_input}]

        text = self.tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True
        )
        print(f"input text for this turn:\n\"\"\"\n{text}\n\"\"\"")  # 调试输出，查看格式化后的输入文本

        # 将输入张量也移动到相同设备
        inputs = self.tokenizer(text, return_tensors="pt").to(self.device)

        # 生成时确保模型处于 eval 模式，并控制梯度
        with torch.no_grad():
            response_ids = self.model.generate(
                **inputs,
                max_new_tokens=32768
            )[0][len(inputs.input_ids[0]):].tolist()

        response = self.tokenizer.decode(response_ids, skip_special_tokens=True)

        # 更新对话历史
        self.history.append({"role": "user", "content": user_input})
        self.history.append({"role": "assistant", "content": response})

        return response


if __name__ == "__main__":
    # 可选：use_half_precision=True 可减少显存占用（适用于较大模型）
    chatbot = QwenChatbot(use_half_precision=True)

    print("\n======== Turn 1 start========")
    user_input_1 = "你好"
    print(f"user: {user_input_1}")
    response_1 = chatbot.generate_response(user_input_1)
    print(f"assistant: {response_1}")
    print("======== Turn 1 end========")

    print("\n======== Turn 2 start========")
    user_input_2 = "你是谁？ /no_think"
    print(f"user: {user_input_2}")
    response_2 = chatbot.generate_response(user_input_2)
    print(f"assistant: {response_2}")
    print("======== Turn 2 end========")

    print("\n======== Turn 3 start========")
    user_input_3 = "再见 /think"
    print(f"user: {user_input_3}")
    response_3 = chatbot.generate_response(user_input_3)
    print(f"assistant: {response_3}")
    print("======== Turn 3 end========")