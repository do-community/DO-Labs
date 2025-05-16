# Execute inside triton pod
export NIM_MODEL_NAME="meta/llama-3.1-8b-instruct"
# export NIM_MODEL_NAME="meta/llama-3.1-70b-instruct"

export SERVER_URL=http://my-nim-nim-llm.nim.svc.cluster.local:8000
export NUM_PROMPTS=100
export INPUT_TOKENS=100
export CONCURRENCY=50
export OUTPUT_TOKENS=100


genai-perf profile -m $NIM_MODEL_NAME \
 --endpoint v1/chat/completions \
 --endpoint-type chat \
 --service-kind openai \
 --streaming \
 -u $SERVER_URL \
 --num-prompts $NUM_PROMPTS \
 --synthetic-input-tokens-mean $INPUT_TOKENS \
 --synthetic-input-tokens-stddev 50 \
 --concurrency $CONCURRENCY \
 --extra-inputs max_tokens:$OUTPUT_TOKENS \
 --extra-input ignore_eos:true \
 --profile-export-file test_chat_${CONCURRENCY}



