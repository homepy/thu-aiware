#!/usr/bin/env bash
vllm bench serve \
    --dataset-name random \
    --model "Qwen3-8B-AWQ" \
    --tokenizer "Qwen/Qwen3-8B-AWQ" \
    --num-prompts "640" \
    --max-concurrency "1" \
    --random-input-len "3072" \
    --random-output-len "64" \
    --trust-remote-code \
    --ignore-eos \
    --host 127.0.0.1 \
    --port 8001 \
    --save-result


vllm bench serve \
    --dataset-name random \
    --model "Qwen3-8B-AWQ" \
    --tokenizer "Qwen/Qwen3-8B-AWQ" \
    --num-prompts "640" \
    --max-concurrency "2" \
    --random-input-len "3072" \
    --random-output-len "64" \
    --trust-remote-code \
    --ignore-eos \
    --host 127.0.0.1 \
    --port 8001 \
    --save-result

vllm bench serve \
    --dataset-name random \
    --model "Qwen3-8B-AWQ" \
    --tokenizer "Qwen/Qwen3-8B-AWQ" \
    --num-prompts "640" \
    --max-concurrency "4" \
    --random-input-len "3072" \
    --random-output-len "64" \
    --trust-remote-code \
    --ignore-eos \
    --host 127.0.0.1 \
    --port 8001 \
    --save-result

vllm bench serve \
    --dataset-name random \
    --model "Qwen3-8B-AWQ" \
    --tokenizer "Qwen/Qwen3-8B-AWQ" \
    --num-prompts "640" \
    --max-concurrency "8" \
    --random-input-len "3072" \
    --random-output-len "64" \
    --trust-remote-code \
    --ignore-eos \
    --host 127.0.0.1 \
    --port 8001 \
    --save-result

vllm bench serve \
    --dataset-name random \
    --model "Qwen3-8B-AWQ" \
    --tokenizer "Qwen/Qwen3-8B-AWQ" \
    --num-prompts "640" \
    --max-concurrency "16" \
    --random-input-len "3072" \
    --random-output-len "64" \
    --trust-remote-code \
    --ignore-eos \
    --host 127.0.0.1 \
    --port 8001 \
    --save-result

vllm bench serve \
    --dataset-name random \
    --model "Qwen3-8B-AWQ" \
    --tokenizer "Qwen/Qwen3-8B-AWQ" \
    --num-prompts "640" \
    --max-concurrency "32" \
    --random-input-len "3072" \
    --random-output-len "64" \
    --trust-remote-code \
    --ignore-eos \
    --host 127.0.0.1 \
    --port 8001 \
    --save-result

