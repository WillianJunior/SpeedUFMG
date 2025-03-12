# === Used a lot ====================================================

# update slurm.conf
parallel-scp -h hosts slurm.conf /usr/local/slurm/etc/slurm.conf
scontrol reconfigure

# mounting home_cerberus:
sudo sshfs -o allow_other,reconnect,delay_connect cerberus:/home /home_cerberus/
# unmounting home_cerberus:
sudo fusermount -u /home_cerberus

# If a node was downed, but now it is up again but signaled down, must 
# enable the node manually:
sudo su slurm
scontrol update NodeName=gorgona7 State=Idle
# A really down node is 'down*'. If '*' is removed, the node may be 
# available, but not enabled yet.

# Create a reservation with magnetic (i.e., any allowed user can allocate on this nodes without adding the reservation parameter)
scontrol create reservation user=willianjunior nodes=gorgona2 starttime=now endtime=2024-03-16 flags=magnetic reservationname=r1

# Configure ssh access on:
vim /etc/ssh/sshd_config
==========
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers root
==========
# Restart sshd for changes to take effect
systemctl restart sshd


# check all services on head node. all should be active
SERVICES=(munge slurmctld mariadb slurmdbd); for s in ${SERVICES[@]}; do echo -ne "$s ->\t"; systemctl status $s | grep Active; done

# Add gateway for external internet
ip route add default via 150.164.203.1

# UPDATE CUDA
# On issues, remove and purge all on 'dpkg -l | grep -i nvidia' except nvidia-common
apt --fix-broken install -y && sudo apt remove nvidia-* -y && sudo apt autoremove -y && apt install nvidia-driver-550 nvidia-utils-550 nvidia-cuda-toolkit -y

# Check who has ssh session
netstat -tnpa | grep 'ESTABLISHED.*sshd'

# === Basics ========================================================
sudo apt install build-essential libssl-dev libdbus-1-dev mariadb-server mariadb-client libmariadbd-dev libpam0g-dev -y

# create group for slurm (ALWAYS USE SAME GID FOR OTHER NODES)
# sudo groupadd -g 9000 gslurm
# create slurm super-user
sudo groupadd -g 3000 slurm
sudo adduser slurm --uid 3010 --gid 3000
# sudo usermod -aG sudo slurm
# sudo usermod -aG gslurm slurm

# All nodes should have the same timezone (America, são paulo):
dpkg-reconfigure tzdata

# slurmctl node (HEAD) should be accessible:
# add HEAD node to /etc/hosts:
echo "192.168.62.4 phocus4" >> /etc/hosts # slurm HEAD

# show cluster usage by year with beg-end months
mbeg=1; mend=6; ano=2024; format="allocated,idle,down,reported"; i=( 01 02 03 04 05 06 07 08 09 10 11 );j=( 02 03 04 05 06 07 08 09 10 11 12 ); echo "----------------- $ano -----------------"; echo -e "Month\tAlloc.\tIdle\tDown\tReported"; echo '----------------------------------------'; echo '----- -------- ------- ------- ---------'; for idx in $(seq $(($mbeg - 1)) $( if [ $mend -lt 12 ]; then echo $(($mend - 1)); else echo 10; fi ) ); do echo -n -e "${i[$idx]}-${j[$idx]}\t"; sreport cluster Utilization -t percent start=${ano}-${i[$idx]}-01 end=${ano}-${j[$idx]}-01 format=${format} | grep "%" | tr -s ' ' | awk '{$1=$1};1' | sed  's/ /\t/g'; done; if [ $mend -eq 12 ]; then echo -n "12-01 "; sreport cluster Utilization -t percent start=${ano}-12-01 end=$((${ano}+1))-01-01 format=${format} | grep "%" | tr -s ' ' | awk '{$1=$1};1' | sed  's/ /\t/g'; fi; echo '----------------------------------------';

# show number users who used the cluster 
sreport cluster UserUtilizationByAccount Start=2024-01-01 End=now | grep sonic | grep -v root | wc -l

# show all jobs of an user
sacct --starttime 2024-01-01 -X --format=User%20,Jobname,State,start,elapsed -u juliane.pascoal | grep -v CANCELLED

# === MUNGE =========================================================

# create sys user for munge with nologin
sudo groupadd -g 8000 munge
sudo adduser munge --system --uid 8010 --gid 8000

# installing munge
wget https://github.com/dun/munge/releases/download/munge-0.5.15/munge-0.5.15.tar.xz
tar xJf munge-0.5.15.tar.xz; cd munge-0.5.15
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --runstatedir=/run
make -j
sudo make install

# munge config:
# assign propper permissions for munge dirs and create a mungekey
sudo chmod 0700 /etc/munge/
sudo chmod 0711 /var/lib/munge/
sudo chmod 0700 /var/log/munge/
sudo mkdir /run/munge
sudo chmod 0755 /run/munge
sudo touch /var/log/munge/munged.log
sudo chown munge /etc/munge/ /var/lib/munge/ /var/log/munge/ /run/munge /var/log/munge/munged.log
sudo chgrp munge /etc/munge/ /var/lib/munge/ /var/log/munge/ /run/munge /var/log/munge/munged.log

# Only create once, and share among all other nodes
sudo -u munge /usr/sbin/mungekey --verbose
# Located at /etc/munge/munge.key

sudo mv munge.key /etc/munge/
scp munge.key root@gorgona2:/etc/munge/

sudo chmod 600 /etc/munge/munge.key 
sudo chown munge /etc/munge/munge.key
sudo chgrp munge /etc/munge/munge.key

sudo systemctl enable munge.service
sudo systemctl start munge.service

# Testing:
# https://github.com/dun/munge/wiki/Installation-Guide
sudo -u munge /usr/sbin/munged # start deamon
munge -n # return munge key
sudo -u munge munge -n | ssh phocus4@phocus4 unmunge
cd ..

# === SLURM =========================================================

wget https://download.schedmd.com/slurm/slurm-23.02.4.tar.bz2
tar --bzip -x -f slurm-23.02.4.tar.bz2; cd slurm-23.02.4
mkdir /usr/local/slurm
mkdir /lib/security
./configure --prefix=/usr/local/slurm/ --with-mysql_conf=/usr/bin/mysql_config --without-hdf5 --enable-pam --with-pam_dir=/lib/security
make -j
make install
make contrib -j
cd contribs/pam_slurm_adopt/
make install
cd ../..
ldconfig -n /usr/local/slurm/lib/
mkdir /usr/local/slurm/etc

# configuration file:
# /usr/local/slurm/etc/slurm.conf

# sbindir:
# /usr/local/slurm/sbin/

# task epilog file
# /usr/local/slurm/etc/job-epilog.sh

vim /etc/environment
# add /usr/local/slurm/bin to PATH

sudo mkdir -m 770 /var/spool/slurmctld /var/spool/slurmd
sudo chgrp -R slurm /var/spool/slurmctld /var/spool/slurmd
sudo chown -R slurm /var/spool/slurmctld /var/spool/slurmd

sudo touch /var/log/slurmctld.log
sudo chmod 0770 /var/log/slurmctld.log
sudo chown slurm /var/log/slurmctld.log
sudo chgrp slurm /var/log/slurmctld.log

sudo mkdir -m 770 /var/run/slurm
sudo chown -R slurm /var/run/slurm
sudo chgrp -R slurm /var/run/slurm

sudo mkdir -m 770 /var/log/slurm
sudo chown -R slurm /var/log/slurm
sudo chgrp -R slurm /var/log/slurm

sudo touch /home/slurm/jobcomploc.txt
sudo chmod 0770 /home/slurm/jobcomploc.txt
sudo chown -R slurm /home/slurm/jobcomploc.txt
sudo chgrp -R slurm /home/slurm/jobcomploc.txt

scp slurm.conf root@gorgona2:/usr/local/slurm/etc/slurm.conf

# Enable on startup for HEAD
sudo systemctl enable slurmctld.service
# Enable on startup for compute nodes
sudo systemctl enable slurmd.service
sudo systemctl start slurmd.service

# If .service files were not present
scp *.service root@gorgona2:/etc/systemd/system/

# === MariaDB =========================================================

sudo systemctl start mariadb
sudo systemctl enable mariadb

# use to setup new password and close all other testing stuff
sudo mysql_secure_installation

# create users and account database
sudo mariadb -u root -p
CREATE USER 'admin'@'localhost' IDENTIFIED BY '#exPer1ment@t10n';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost';
CREATE DATABASE slurm_acct_db;
grant all on slurm_acct_db.* TO 'slurm'@'localhost' identified by 'exPer1ment@t10n' with grant option;
FLUSH PRIVILEGES;

# === SLURMDBD ======================================================

# send configuration file for slurmdbd and protect it from other users
scp slurmdbd.conf root@phocus4:/usr/local/slurm/etc/slurmdbd.conf
sudo chmod 0600 /usr/local/slurm/etc/slurmdbd.conf
sudo chown slurm /usr/local/slurm/etc/slurmdbd.conf
sudo chgrp slurm /usr/local/slurm/etc/slurmdbd.conf

sudo touch /var/log/slurmdbd.log
sudo chmod 0770 /var/log/slurmdbd.log
sudo chown slurm /var/log/slurmdbd.log
sudo chgrp slurm /var/log/slurmdbd.log

sudo systemctl enable slurmdbd.service
sudo systemctl start slurmdbd.service

sacctmgr add cluster

# === Environment Modules ===========================================
sudo apt install environment-modules
source /etc/profile.d/modules.sh # add to ~/.bashrc


