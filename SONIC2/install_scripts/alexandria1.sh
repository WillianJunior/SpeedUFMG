# === Base ======================================
dnf install -y epel-release
dnf install -y htop
dnf config-manager --set-enabled powertools
dnf update

systemctl stop firewalld
systemctl mask firewalld

# vim /etc/selinux/config
# SELINUX=disabled

# === Networking ================================
hostnamectl set-hostname alexandria1

# Enable NAT interface on boot
# change in /etc/sysconfig/network-scripts/ifcfg-enp0s25
# ONBOOT=yes

# === SSH =======================================
# Disallow access from non-root users
echo "AllowUsers root" >> /etc/ssh/sshd_config

# === LDAP =====================================
# ref: https://www.howtoforge.com/how-to-install-openldap-on-rocky-linux-9/
dnf install -y openldap-clients sssd sssd-ldap oddjob-mkhomedir
authselect select sssd with-mkhomedir --force
systemctl enable --now oddjobd.service

echo "URI ldap://ldap.dcc.ufmg.br" >> /etc/openldap/ldap.conf

# copy sssd.conf file to /etc/sssd/sssd.conf
chmod 0600 /etc/sssd/sssd.conf
systemctl start sssd
systemctl enable sssd

# === Lustre client =============================
# source: https://metebalci.com/blog/lustre-2.15.4-on-rhel-8.9-and-ubuntu-22.04/
# lustre-utils.sh script works perfectly

# --- zfs ---------------------------------------
dnf install -y https://zfsonlinux.org/epel/zfs-release-2-3$(rpm --eval "%{dist}").noarch.rpm
dnf install -y kernel-devel
dnf install -y zfs

modprobe -v zfs
dmesg # check output from zfs...

# --- Install lustre ----------------------------
# Copy lustre repo file
cat /etc/yum.repos.d/lustre.repo # add from file
dnf --enablerepo=lustre-server install -y lustre-dkms lustre-osd-zfs-mount lustre

modprobe -v lustre # loading module
dmesg # testing....
modprobe -v -r lustre # need to unload for lnet configuration

# --- Configure LNet ----------------------------
# OSB: We are only using tcp1 net interface
modprobe -v -r lnet
modprobe -v lnet
lnetctl lnet unconfigure
lnetctl lnet configure
lnetctl net add --net tcp1 --if enp0s25

lnetctl ping cerberus2@tcp1 # pinging myself, which should always work
lnetctl net show --verbose # should show the enp0s25 tcp1 net

# Enable LNet at boot
# lnetctl export /etc/sysconfig/lnet.conf
lnetctl export /etc/lnet.conf
systemctl enable lnet

# --- Load lustre module -----------------------
modprobe -v lustre
dmesg # Check outputs from lustre

# === Creating a fs =============================
# This script only creates a fs from a single 
# vitual group. Only an example. More to come...

# First, create the virtual group of devices to store 
sh lustre-utils.sh create_vg lustre /dev/sdb

# Should create a single manager target (mgt) for the whole node
sh lustre-utils.sh create_mgt zfs

# Create a fs with 1 mdt and 4 ost's with
# 2GB and 4GB each respectively
lustre-utils.sh create_fs s2common zfs 2 1 zfs 16 4

# === Testing the mounts ========================
sh lustre-utils.sh start_mgs
sh lustre-utils.sh start_fs s2common
sh lustre-utils.sh status

# === Mount fs on boot ==========================
echo "# Initialize lustre MGT" >> /etc/fstab
echo "mgt/lustre /lustre/mgt lustre defaults,_netdev,flock 0 0" >> /etc/fstab
echo "# Initialize s2common lustre fs" >> /etc/fstab
echo "# mount MDT" >> /etc/fstab
echo "s2common_mdt0/lustre /lustre/s2common/mdt0 lustre defaults,_netdev,flock 0 0" >> /etc/fstab
echo "# mount OSTs" >> /etc/fstab
echo "s2common_ost0/lustre /lustre/s2common/ost0 lustre defaults,_netdev,flock 0 0" >> /etc/fstab
echo "s2common_ost1/lustre /lustre/s2common/ost1 lustre defaults,_netdev,flock 0 0" >> /etc/fstab
echo "s2common_ost2/lustre /lustre/s2common/ost2 lustre defaults,_netdev,flock 0 0" >> /etc/fstab
echo "s2common_ost3/lustre /lustre/s2common/ost3 lustre defaults,_netdev,flock 0 0" >> /etc/fstab

# Testing the fstab mount
sh lustre-utils.sh stop_fs s2common
sh lustre-utils.sh stop_mgs
mount -a # This mounts the s2common fs now, and should work now...
