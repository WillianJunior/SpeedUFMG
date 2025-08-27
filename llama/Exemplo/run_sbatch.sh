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
PROMPT_SERVER=$(jq -r '.prompt_server' config.json)
PROMPTS_USER_DIR=$(jq -r '.prompts_user_dir' config.json)
RESULT_DIR=$(jq -r '.result_dir' config.json)
SBATCH_SCRIPT=$(jq -r '.sbatch_script' config.json)

# Limpa arquivos antigos
echo "Limpando logs e criando diretório de resultados..."
[ -f "$OUTPUT_LOG" ] && rm -f "$OUTPUT_LOG"
RESULT_DIR_DATE="$RESULT_DIR/result_$(date +%d-%m-%Y_%H-%M-%S)"
mkdir -p "$RESULT_DIR_DATE"

# Submete o job passando as variáveis para o script do SLURM
sbatch --export=ALL,DIR_LLAMA_SCRIPT=$DIR_LLAMA_SCRIPT,MODEL=$MODEL,PORT_SERVER=$PORT_SERVER,PORT_RPC=$PORT_RPC,VENV_DIR=$VENV_DIR,PROMPT_SERVER=$PROMPT_SERVER,PROMPTS_USER_DIR=$PROMPTS_USER_DIR,RESULT_DIR=$RESULT_DIR_DATE \
       --job-name=$JOB_NAME \
       --nodes=$NODES \
       --ntasks=$NTASKS \
       --time=$TIME \
       --output=$OUTPUT_LOG \
    $SBATCH_SCRIPT
