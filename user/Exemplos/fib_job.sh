#!/bin/bash
#SBATCH --job-name=my_little_job  # Job name
#SBATCH --time=00:05:00           # Time limit hrs:min:sec
#SBATCH -w gorgona5
#SBATCH -N 1                        # Number of nodes
#SBATCH --mail-type=ALL
#SBATCH --mail-user=larissa.gomide@dcc.ufmg.br

set -x # all comands are also outputted

cd /scratch/larissa.gomide
module list
module avail
module load python3.12.1

source venv/bin/activate

export HOME="/minha_home"

cd /home_cerberus/disk3/larissa.gomide

python3 fib.py

hostname   # just show the allocated node

echo "Meu job terminou!" | mail -s "Slurm Job Finalizado" larissa.gomide@dcc.ufmg.br
