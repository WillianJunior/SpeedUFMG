#!/bin/bash
# Tested on:
# OS:     Rocky 8.10
# Kernel: 4.18.0-553.16.1.el8_10.x86_64

# === Basics ========================================================
export SLURM_UID=38000
export SLURM_GID=38010
export MUNGE_UID=48000
export MUNGE_GID=48010

sudo groupadd -g $SLURM_GID slurm
sudo groupadd -g $MUNGE_GID munge
sudo adduser slurm --uid $SLURM_UID --gid $SLURM_GID
sudo adduser munge --uid $MUNGE_UID --gid $MUNGE_GID --system

# === Munge =========================================================
dnf install -y munge munge-libs munge-devel

# Generate a random munge key. This should be copied to all
dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key
chown munge /etc/munge/munge.key
chmod 400 /etc/munge/munge.key

# assign propper permissions for munge dirs
sudo chmod 0700 /etc/munge/
sudo chmod 0711 /var/lib/munge/
sudo chmod 0700 /var/log/munge/
sudo mkdir /run/munge
sudo chmod 0755 /run/munge
sudo touch /var/log/munge/munged.log
sudo chown munge /etc/munge/ /var/lib/munge/ /var/log/munge/ /run/munge /var/log/munge/munged.log
sudo chgrp munge /etc/munge/ /var/lib/munge/ /var/log/munge/ /run/munge /var/log/munge/munged.log

# More threads for munge
# https://wiki.fysik.dtu.dk/Niflheim_system/Slurm_installation/#munge-0-5-13-increase-number-of-threads
cp /usr/lib/systemd/system/munge.service /etc/systemd/system/munge.service
systemctl daemon-reload

# Start munge service
systemctl restart munge
systemctl enable munge

# === Slurm =========================================================
# Steps:
#  1. Download and build slurm rpms
#  2. Install deps: mariadb, pam, ...
#  3. Install slurm daemons
#  4. Prepare paths and log files
#  5. Configure and start mariadb
#  6. Configure and start slurmdbd
#  7. Configure and start slurmd
#  8. profit

# Optional plugins
dnf install -y mariadb-server mariadb-devel pam-devel readline-devel

# Select later...
# dnf install rpm-build gcc python3 openssl openssl-devel pam-devel \
# numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel \
# rrdtool-devel ncurses-devel gtk2-devel libibmad libibumad perl-Switch \
# perl-ExtUtils-MakeMaker xorg-x11-xauth dbus-devel libbpf

# Build and install slurm
export SLURM_VER=24.05.3
wget https://download.schedmd.com/slurm/slurm-${SLURM_VER}.tar.bz2
rpmbuild -ta slurm-$SLURM_VER.tar.bz2
export SLM_PATH=/root/rpmbuild/RPMS/x86_64/
dnf install -y ${SLM_PATH}/slurm-${SLURM_VER}*rpm \
${SLM_PATH}/slurm-devel-${SLURM_VER}*rpm \
${SLM_PATH}/slurm-example-configs-${SLURM_VER}*rpm \
${SLM_PATH}/slurm-slurmctld-${SLURM_VER}*rpm

# Prepare spool, run and log paths
mkdir /var/spool/slurmctld /var/log/slurm /var/run/slurm
chown slurm: /var/spool/slurmctld /var/log/slurm /var/run/slurm
chmod 755 /var/spool/slurmctld /var/log/slurm
chmod 770 /var/run/slurm

# Create slurm required files
touch /var/log/slurm/slurmctld.log /var/log/slurm/slurmd.log /home/slurm/jobcompl.txt /var/log/slurm/slurmdbd.log /var/run/slurmdbd.pid
chown slurm: /var/log/slurm/slurmctld.log /var/log/slurm/slurmd.log /home/slurm/jobcompl.txt /var/log/slurm/slurmdbd.log /var/run/slurmdbd.pid
chmod 0770 /var/log/slurm/slurmctld.log /var/log/slurm/slurmd.log /home/slurm/jobcompl.txt /var/log/slurm/slurmdbd.log /var/run/slurmdbd.pid

# Install slurm, slurmdb and mariadb
dnf install -y ${SLM_PATH}/slurm-${SLURM_VER}*rpm \
${SLM_PATH}/slurm-devel-${SLURM_VER}*rpm \
${SLM_PATH}/slurm-slurmdbd-${SLURM_VER}*rpm

systemctl start mariadb
systemctl enable mariadb

# Configure mariadb
mysql_secure_installation
echo "[mysqld]" >> /etc/my.cnf
echo "innodb_buffer_pool_size=4096M" >> /etc/my.cnf
echo "innodb_log_file_size=64M" >> /etc/my.cnf
echo "innodb_lock_wait_timeout=900" >> /etc/my.cnf
echo "max_allowed_packet=16M" >> /etc/my.cnf
systemctl restart mariadb

mysql -u root -p
# Run in mysql bash
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'qp';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost';
CREATE DATABASE slurm_acct_db;
grant all on slurm_acct_db.* TO 'slurm'@'localhost' identified by 'qp' with grant option;
FLUSH PRIVILEGES;

# Fill slurmdb.conf:
cat /etc/slurm/slurmdbd.conf
chown slurm /etc/slurm/slurmdbd.conf
chmod 600 /etc/slurm/slurmdbd.conf
systemctl start slurmdbd.service 
systemctl status slurmdbd.service 
systemctl enable slurmdbd.service 

# Start slurm controller
cat /etc/slurm/slurm.conf
systemctl start slurmctld.service 
systemctl status slurmctld.service 

# run to test
sinfo

# check all services on head node. all should be active
SERVICES=(munge slurmctld mariadb slurmdbd); for s in ${SERVICES[@]}; do echo -ne "$s ->\t"; systemctl status $s | grep Active; done
