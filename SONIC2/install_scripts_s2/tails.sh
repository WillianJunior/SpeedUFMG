#!/bin/bash
# tails1

# Configurations
ME=tails1
MY_IP_DCC=150.164.203.31
MY_IP_SPEED=192.168.62.100
NET_INTF=enp2s0
GATEWAY_DCC=150.164.203.1
GATEWAY_SPEED=192.168.62.254

# Network
hostnamectl set-hostname $ME
nmcli con mod $NET_INTF ipv4.addresses "${MY_IP_DCC}/24"
nmcli con mod $NET_INTF ipv4.gateway "$GATEWAY"
nmcli con mod $NET_INTF +ipv4.addresses ${MY_IP_SPEED}/24
nmcli con mod $NET_INTF +ipv4.routes "192.168.62.0/24 $GATEWAY_SPEED"
nmcli con mod $NET_INTF ipv4.dns "$GATEWAY_DCC $GATEWAY_SPEED 8.8.8.8"
nmcli con mod $NET_INTF ipv4.method manual
nmcli con mod $NET_INTF connection.autoconnect yes
nmcli con down $NET_INTF && nmcli con up $NET_INTF

# Base
dnf install -y epel-release
dnf install -y htop
dnf config-manager --set-enabled powertools
dnf update
mkdir /home/nfs_imgs

# Security
echo "AllowUsers root" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
systemctl restart sshd.service


# Delete virtual volumes not necessary
lvremove ...
VG=rl_tirosina
ETC_LV=/dev/$VG/sonic_etc
MODULES_LV=/dev/$VG/sonic_modules
HOME_LV=/dev/$VG/sonic_home
lvcreate -L 30G -n sonic_etc $VG
lvcreate -L 330G -n sonic_modules $VG
lvcreate -l 100%FREE -n sonic_home $VG # remaining free space

# /setc (shared etc) 30GB
# on client: mounted over nfs, read-only, with fs-cache
SETC_MOUNT=/nfs/exports/sonic_etc
mkdir -p $SETC_MOUNT
chmod 1755 $SETC_MOUNT
mkfs.xfs -f -n ftype=1 $ETC_LV
echo "$ETC_LV $SETC_MOUNT xfs defaults,rw,sync 0 0" >> /etc/fstab
mkdir $SETC_MOUNT/slurm # TODO set chown e chmod
chmod 0755 $SETC_MOUNT/slurm

# /smodules (shared modules) 330 GB
# on client: mounted over nfs, read-only, with fs-cache
SMODULES_MOUNT=/nfs/exports/sonic_modules
mkdir -p $SMODULES_MOUNT
chmod 1755 $SMODULES_MOUNT
mkfs.xfs -f -n ftype=1 $MODULES_LV
echo "$MODULES_LV $SMODULES_MOUNT xfs defaults,rw,sync,noatime,nodiratime 0 0" >> /etc/fstab

mkdir $SMODULES_MOUNT/modulefiles
chmod 0755 $SMODULES_MOUNT/modulefiles
slurm
mkdir $SMODULES_MOUNT/Modules
chmod 0755 $SMODULES_MOUNT/Modules


# /home ~3.2TB (remaining...)
# on client: mounted over nfs, read-only, with fs-cache
SHOME_MOUNT=/nfs/exports/sonic_home
mkdir -p $SHOME_MOUNT
chmod 1777 $SHOME_MOUNT
mkfs.xfs -f -n ftype=1 $HOME_LV
echo "$HOME_LV $SHOME_MOUNT xfs defaults,rw,sync,uquota 0 0" >> /etc/fstab
xfs_quota -x -c 'enable' $SHOME_MOUNT
xfs_quota -x -c 'limit -d bsoft=160g bhard=200g' $SHOME_MOUNT
xfs_quota -x -c 'timer -u bsoft=7days' $SHOME_MOUNT

mount -a
systemctl daemon-reload


# LDAP ##############
dnf install -y openldap-clients sssd sssd-ldap oddjob-mkhomedir
authselect select sssd with-mkhomedir --force
systemctl enable --now oddjobd.service
echo "URI ldap://ldap.dcc.ufmg.br" >> /etc/openldap/ldap.conf
echo "[domain/default]
id_provider = ldap
autofs_provider = ldap
auth_provider = ldap
chpass_provider = ldap
ldap_uri = ldap://ldap.dcc.ufmg.br
ldap_id_use_start_tls = True
ldap_tls_cacertdir = /etc/openldap/certs
cache_credentials = True
ldap_tls_reqcert = allow

[sssd]
services = nss, pam, autofs
domains = default

[nss]
homedir_substring = /home
" > /etc/sssd/sssd.conf
chmod 0600 /etc/sssd/sssd.conf
systemctl enable --now sssd


# NFS
dnf install -y quota-rpc
systemctl enable --now rpc-rquotad.service # allows quota querying from remote host
xfs_quota -x -c 'state' # Check if quotas are enforced
dnf install -y nfs-utils
systemctl enable --now nfs-server
systemctl enable --now rpcbind
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-port=875/tcp # for rpc-rquotad
firewall-cmd --permanent --add-port=875/udp # for rpc-rquotad
firewall-cmd --reload

# edit /etc/idmapd.conf
# Domain = dcc.ufmg.br

echo "$SETC_MOUNT 192.168.62.0/24(r)" >> /etc/exports # allows any host in subnet 192.168.62.0/24
echo "$SMODULES_MOUNT 192.168.62.0/24(r)" >> /etc/exports # allows any host in subnet 192.168.62.0/24
echo "$SHOME_MOUNT 192.168.62.0/24(rw)" >> /etc/exports # allows any host in subnet 192.168.62.0/24
exportfs -rv

# === on client side ============================
apt install cachefilesd
systemctl enable --now cachefilesd


mkdir /sonic_etc
mkdir /sonic_modules
mkdir /sonic_home
echo "192.168.62.100:/nfs/exports/sonic_etc /sonic_etc nfs defaults 0 0" >> /etc/fstab
echo "192.168.62.100:/nfs/exports/sonic_modules /sonic_modules nfs defaults 0 0" >> /etc/fstab
echo "192.168.62.100:/nfs/exports/sonic_home /sonic_home nfs defaults 0 0" >> /etc/fstab






