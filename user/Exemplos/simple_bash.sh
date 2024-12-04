#!/bin/bash
#SBATCH --job-name=my_little_job  # Job name
#SBATCH --time=00:05:00       	  # Time limit hrs:min:sec
#SBATCH -N 1            	        # Number of nodes
#SBATCH --mail-type=ALL
#SBATCH --mail-user=my_mail@mail.com

set -x # all comands are also outputted

cd /home_cerberus/speed/username

module list
module avail
module load python3.12.1

source myenv1/bin/activate

python3 test.py

hostname   # just show the allocated node