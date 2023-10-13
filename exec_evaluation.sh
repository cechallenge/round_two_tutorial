#!/bin/sh
start=$(date +%s.%N)

python main.py    --model hf-causal-experimental     --model_args pretrained=/home/llama-30b/,use_accelerate=True     --tasks hellaswag     --device cuda     --batch_size 16


finish=$(date +%s.%N)
time=$( echo "$finish - $start" | bc -l )
echo 'time:' $time
