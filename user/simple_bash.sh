#!/bin/bash
#SBATCH --job-name=my_little_job        # Nome do job
#SBATCH --time=00:20:00                 # Tempo máximo de execução (HH:MM:SS)
#SBATCH --nodes=1
#SBATCH -w gorgona4
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mail@gmail.com

set -x #all commands are also outputted

cd /home_cerberus/disk2/user
pwd
ls

PATH='path/to/inputs'
NUM=$1

python3 meu_codigo.py $NUM $PATH

echo "done..."