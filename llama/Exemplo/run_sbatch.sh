#!/bin/bash

# Lê as variáveis do JSON
JOB_NAME=$(jq -r '.job_name' config.json)
NODES=$(jq -r '.nodes' config.json)
NTASKS=$(jq -r '.ntasks' config.json)
TIME=$(jq -r '.time' config.json)
OUTPUT_LOG=$(jq -r '.output_log' config.json)
DIR_LLAMA_SCRIPT=$(jq -r '.dir_llama_script' config.json)
MODEL=$(jq -r '.model' config.json)
PORT_RPC=$(jq -r '.port_rpc' config.json)
PORT_SERVER=$(jq -r '.port_server' config.json)
VENV_DIR=$(jq -r '.venv_dir' config.json)
PROMPT_DIR=$(jq -r '.prompt_dir' config.json)
RESULT_FILE=$(jq -r '.result_file' config.json)
SBATCH_SCRIPT=$(jq -r '.sbatch_script' config.json)

# Limpa arquivos antigos
echo "Limpando logs e resultados antigos..."
[ -f "$OUTPUT_LOG" ] && rm -f "$OUTPUT_LOG"
[ -f "$RESULT_FILE" ] && rm -f "$RESULT_FILE"

# Submete o job passando as variáveis para o script do SLURM
sbatch --export=ALL,DIR_LLAMA_SCRIPT=$DIR_LLAMA_SCRIPT,MODEL=$MODEL,PORT_SERVER=$PORT_SERVER,PORT_RPC=$PORT_RPC,VENV_DIR=$VENV_DIR,PROMPT_DIR=$PROMPT_DIR,RESULT_FILE=$RESULT_FILE \
       --job-name=$JOB_NAME \
       --nodes=$NODES \
       --ntasks=$NTASKS \
       --time=$TIME \
       --output=$OUTPUT_LOG \
    $SBATCH_SCRIPT
