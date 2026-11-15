#!/bin/bash
#
# Script to download and organize a model into /data/llm_models/<model_name>/

LLAMA_CACHE="/data/llm_models"
readonly LLAMA_CACHE
export LLAMA_CACHE

echo "--- Starting Model Download Process ---"
if [ -z "$1" ]; then
    echo "ERROR: No model name provided. Usage: $0 <model_name>"
    echo "Example: $0 bartowski/Llama-3.2-3B-Instruct-uncensored-GGUF:Q6_K"
    exit 1
fi

MODEL=$1

# Attempting to download the model using the standard download command.
# We download it to a temporary location first.
echo "Starting download of model ${MODEL} to ${LLAMA_CACHE}..."
llama download -hf "$MODEL"

if [ $? -ne 0 ]; then
    echo "ERROR: Model download failed for $MODEL. Aborting."
    exit 1
fi

echo "--- Download Complete ---"
