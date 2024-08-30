#!/bin/bash
# Tested on:
# OS:     Rocky 8.10
# Kernel: 4.18.0-553.16.1.el8_10.x86_64

# OBS:
# All config files are within the lustre fs s2common, which
# should be mounted at /lustre/s2common

# === Basics ========================================================
export SLURM_UID=38000
export SLURM_GID=38010
export MUNGE_UID=48000
export MUNGE_GID=48010

groupadd -g $SLURM_GID slurm
groupadd -g $MUNGE_GID munge
adduser slurm --uid $SLURM_UID --gid $SLURM_GID
adduser munge --uid $MUNGE_UID --gid $MUNGE_GID --system

# === Munge =========================================================
dnf install -y munge munge-libs munge-devel

# Copy munge key from s2common to expected munge path
# Munge doesn't allow symlinking munge.key
cp /lustre/s2common/munge/munge.key /etc/munge/
chown munge /etc/munge/munge.key
chmod 400 /etc/munge/munge.key

# assign propper permissions for munge dirs
chmod 0700 /etc/munge/
chmod 0711 /var/lib/munge/
chmod 0700 /var/log/munge/
mkdir /run/munge
chmod 0755 /run/munge
touch /var/log/munge/munged.log
chown munge /etc/munge/ /var/lib/munge/ /var/log/munge/ /run/munge /var/log/munge/munged.log
chgrp munge /etc/munge/ /var/lib/munge/ /var/log/munge/ /run/munge /var/log/munge/munged.log

# More threads for munge
# https://wiki.fysik.dtu.dk/Niflheim_system/Slurm_installation/#munge-0-5-13-increase-number-of-threads
cp /usr/lib/systemd/system/munge.service /etc/systemd/system/munge.service
# add ExecStart=/usr/sbin/munged --num-threads 10
systemctl daemon-reload

# Start munge service
systemctl restart munge
systemctl enable munge

# === Slurm =========================================================
# Steps:
#  1. Download and build slurm rpms
#  3. Install slurm daemon
#  4. Prepare paths and log files
#  7. Configure and start slurmd
#  8. profit

# Optional plugins
dnf install -y mariadb-devel pam-devel readline-devel

# Build and install slurm
export SLURM_VER=24.05.3
cp /lustre/s2common/slurm/slurm-$SLURM_VER.tar.bz2 .
rpmbuild -ta slurm-$SLURM_VER.tar.bz2
export SLM_PATH=/root/rpmbuild/RPMS/x86_64/
dnf install -y ${SLM_PATH}/slurm-${SLURM_VER}*rpm

# Link slurm.conf to show where the head is
ln -fs /lustre/s2common/slurm/slurm.conf /etc/slurm/slurm.conf

# run to test
sinfo
