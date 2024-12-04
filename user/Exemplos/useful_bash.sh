#!/bin/bash
#SBATCH --job-name=ldg-gen-image         # Nome do job
#SBATCH --time=00:20:00                 # Tempo máximo de execução (HH:MM:SS)
#SBATCH --nodes=1

set -x

# Carregar módulos necessários
module load python3.10.12
module load cuda/11.8.0  # Ajuste conforme a versão do CUDA no cluster

# Definir o diretório de cache do Hugging Face
export HF_HOME="/home/all_home/user/.cache/huggingface"

# Verificar se o diretório de cache existe, se não, criar
if [ ! -d "$HF_HOME" ]; then
    echo "[PRINT] Creating cache directory at $HF_HOME"
    mkdir -p $HF_HOME
fi
 
if [ -d "/home/all_home/user/" ]  
then 
  echo "      [PRINT] /home/all_home/user/ exists..." 
 
  if [ -d "/home/all_home/user/exp_notebook_venv" ] 
  then 
    echo "      [PRINT] exp_venv exists..." 
 
    source /home/all_home/user/exp_notebook_venv/bin/activate 
  else 
    echo "      [PRINT] exp_venv doesnt exists, creating it..." 
 
    python3 -m venv /home/all_home/user/exp_notebook_venv/ 
    source /home/all_home/user/exp_notebook_venv/bin/activate 
 
  fi 
 
  set -x 
  pwd  
 
  echo "[PRINT] Installing required packages..."
  python3 -m pip install --upgrade pip
  pip install torch

  python3 generate_image.py
 
else 
  echo "      [PRINT] /home/all_home/user/ Creating..." 
  mkdir /home/all_home/user/ 
  python3 -m venv /home/all_home/user/exp_notebook_venv/ 
  source /home/all_home/user/exp_notebook_venv/bin/activate 
 
  set -x 
  pwd  
 
  echo "[PRINT] Installing required packages..."
  python3 -m pip install --upgrade pip
  pip install torch

  python3 generate_image.py
fi