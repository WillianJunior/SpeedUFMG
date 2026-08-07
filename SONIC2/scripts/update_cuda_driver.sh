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



# medusas:
dnf update -y
reboot
nvidia-uninstall
reboot
dnf clean all
dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
dnf makecache
dnf install -y nvidia-driver.x86_64
reboot
dnf install -y nvidia-driver-cuda
