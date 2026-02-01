# Qwen3-8B-AWQ benchmark serving script
vllm bench serve \
    --dataset-name random \
    --model "Qwen3-8B-AWQ" \
    --tokenizer "Qwen/Qwen3-8B-AWQ" \
    --num-prompts "100" \
    --max-concurrency "2" \
    --random-input-len "3072" \
    --random-output-len "64" \
    --trust-remote-code \
    --ignore-eos \
    --host 127.0.0.1 \
    --port 8001 \
    --save-result \
    --extra-body '{"chat_template_kwargs":{"enable_thinking":false}}'

# Qwen3-8B benchmark serving script
vllm bench serve \
    --dataset-name random \
    --model "Qwen3-8B" \
    --tokenizer "Qwen/Qwen3-8B" \
    --num-prompts "100" \
    --max-concurrency "2" \
    --random-input-len "3072" \
    --random-output-len "64" \
    --trust-remote-code \
    --ignore-eos \
    --host 127.0.0.1 \
    --port 8001 \
    --save-result \
    --extra-body '{"chat_template_kwargs":{"enable_thinking":false}}'

# Qwen3-14B benchmark serving script
vllm bench serve \
    --dataset-name random \
    --model "Qwen3-14B" \
    --tokenizer "Qwen/Qwen3-14B" \
    --num-prompts "100" \
    --max-concurrency "2" \
    --random-input-len "3072" \
    --random-output-len "64" \
    --trust-remote-code \
    --ignore-eos \
    --host 127.0.0.1 \
    --port 8001 \
    --save-result

# Qwen3-14B-AWQ benchmark serving script
vllm bench serve \
    --dataset-name random \
    --model "Qwen3-14B-AWQ" \
    --tokenizer "Qwen/Qwen3-14B-AWQ" \
    --num-prompts "100" \
    --max-concurrency "2" \
    --random-input-len "3072" \
    --random-output-len "64" \
    --trust-remote-code \
    --ignore-eos \
    --host 127.0.0.1 \
    --port 8001 \
    --save-result 