#!/bin/bash
# Tested on:
# OS:     Rocky 8.10
# Kernel: 4.18.0-553.16.1.el8_10.x86_64

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
hostnamectl set-hostname cerberus2

# Set static ip
ip addr add 169.254.231.10 dev enp0s25

# Enable NAT interface on boot
# change in /etc/sysconfig/network-scripts/ifcfg-enp0s25
# ONBOOT=yes

# === DHCP ======================================
dnf install dhcp-server.x86_64 -y
# Copy config file
cat /etc/dhcp/dhcpd.conf
systemctl start dhcpd
systemctl enable dhcpd

# === SSH =======================================
# Add public key manager script
cat /bin/hello.sh

# Non-root users can only manage public keys
echo "Match User *,!root" >> /etc/ssh/sshd_config
echo "  ForceCommand /bin/hello.sh" >> /etc/ssh/sshd_config

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

# Copy lustre repo file
cat /etc/yum.repos.d/lustre.repo # add from file
dnf --nogpgcheck --enablerepo=lustre-client install -y lustre-client-dkms lustre-client

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

# --- Mount lustre fs's ------------------------
mkdir -p /lustre/s2common
mkdir -p /lustre/s2_scr1
# Enable s2common fs at boot
echo "alexandria1@tcp1:/s2common /lustre/s2common/ lustre defaults,_netdev,flock 0 0" >> /etc/fstab
echo "alexandria1@tcp1:/s2_scr1 /lustre/s2_scr1/ lustre defaults,_netdev,flock 0 0" >> /etc/fstab
mount -a # This mounts the fs's now, and should work now...



