# tested on medusa5
# BAD:
# 1. using static IP on SPEED
# 2. using CRC IP for internet
# 3. mounting /home with /dev/mapper/rl_cisteina-scratch -> TODO: use the correct /home across all nodes
# 4. mounting sonic_home -> TODO: should be /home
# Change to ansible

# Base ===================================================================
dnf install -y epel-release
dnf update -y
grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=1 psi=1"
dnf groupinstall -y "Development Tools"
dnf install -y htop cmake
dnf install -y ansible

# TODO: configure htop globally with PSI (PSI already showing)

# Security/ssh ===========================================================
echo "AllowUsers root" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
systemctl restart sshd.service


# Network ================================================================
export ME=medusa5
export MY_IP_SPEED=192.168.62.101
export NET_INTF=eno2
export GATEWAY_SPEED=192.168.62.254

hostnamectl set-hostname $ME
nmcli con mod $NET_INTF +ipv4.addresses ${MY_IP_SPEED}/24
nmcli con mod $NET_INTF +ipv4.routes "192.168.62.0/24 $GATEWAY_SPEED"
nmcli con mod $NET_INTF ipv4.method auto # currently the 192.168.62.0/24 network doesn't forward to the internet, thus the CRC IP is needed.
nmcli con mod $NET_INTF connection.autoconnect yes
nmcli con down $NET_INTF && nmcli con up $NET_INTF

# TODO ===============> use the speed DHCP

# LDAP ===================================================================
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


# Mount global storages ==================================================
dnf install -y  nfs-utils

mkdir /sonic_etc
mkdir /sonic_modules
mkdir /sonic_home

echo "192.168.62.100:/nfs/exports/sonic_etc /sonic_etc nfs defaults,_netdev 0 0" >> /etc/fstab
echo "192.168.62.100:/nfs/exports/sonic_modules /sonic_modules nfs defaults,_netdev 0 0" >> /etc/fstab
echo "192.168.62.100:/nfs/exports/sonic_home /sonic_home nfs defaults,_netdev 0 0" >> /etc/fstab

systemctl daemon-reload
mount -a


# Rework local storage ===================================================
umount /home
vim /etc/fstab # remove /home mount line
lvdisplay # to find the name of the home logical volume
lvchange -an /dev/rl_cisteina/home # deactivate volume
lvremove /dev/rl_cisteina/home # kill volume
lvcreate -n scratch -L 1T rl_cisteina
lvcreate -n storage rl_cisteina -l 100%FREE

# Format volumes
mkfs.xfs /dev/rl_cisteina/scratch
mkfs.xfs /dev/rl_cisteina/storage

# Mount volumes
mkdir /scratch
mkdir /storage
echo '/dev/rl_cisteina/scratch   /scratch   xfs   defaults   0 0' >> /etc/fstab
echo '/dev/rl_cisteina/storage   /storage   xfs   defaults   0 0' >> /etc/fstab
systemctl daemon-reload
mount -a

# Modules ================================================================
# Install and source module across all users
dnf install -y environment-modules
tee /etc/profile.d/modules.sh > /dev/null <<'EOF'
# Environment Modules initialization
if [ -f /usr/share/Modules/init/bash ]; then
    source /usr/share/Modules/init/bash
fi
export MODULEPATH=/sonic_modules/dcc-sonic-modules/modulefiles
EOF


modules
 - install modules from ansible
 - test


# Slurm ==================================================================

slurm client
 - munge
 - slurmd

slurm PAM

GRES 1 GPU
