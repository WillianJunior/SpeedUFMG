apt update
apt upgrade -y
apt install -y nvidia-driver-570-server
git clone https://github.com/NVIDIA/cuda-samples.git
cd cuda-samples
git checkout v12.8
cd Samples/6_Performance/transpose
module load cuda/12.8.0
make clean
make
./transpose
