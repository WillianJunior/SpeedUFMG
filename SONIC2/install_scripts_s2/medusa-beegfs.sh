# tested on medusa[4,6]
beegfs configuration

# Network ================================================================
# export ME=medusa5
export MY_IP_SPEED=192.168.62.101
export NET_INTF=eno2
export GATEWAY_SPEED=192.168.62.254

# hostnamectl set-hostname $ME
nmcli con mod $NET_INTF +ipv4.addresses ${MY_IP_SPEED}/24
nmcli con mod $NET_INTF +ipv4.routes "192.168.62.0/24 $GATEWAY_SPEED"
nmcli con mod $NET_INTF ipv4.method auto # currently the 192.168.62.0/24 network doesn't forward to the internet, thus the CRC IP is needed.
nmcli con mod $NET_INTF connection.autoconnect yes
nmcli con down $NET_INTF && nmcli con up $NET_INTF

# Security ================================================================
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "UsePAM yes" >> /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl restart sshd.service


# Base ===================================================================
dnf install -y epel-release
dnf update -y
grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=1 psi=1"
dnf groupinstall -y "Development Tools"
dnf install -y htop cmake
dnf install -y ansible

# TODO: configure htop globally with PSI (PSI already showing)

# TODO ===============> use the speed DHCP


# TODO ============== copy host files


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
mkdir /snfs1

echo "tails1:/nfs/exports/sonic_etc /sonic_etc nfs defaults,_netdev 0 0" >> /etc/fstab
echo "tails1:/nfs/exports/sonic_modules /sonic_modules nfs defaults,_netdev 0 0" >> /etc/fstab
echo "tails1:/nfs/exports/sonic_home /sonic_home nfs defaults,_netdev 0 0" >> /etc/fstab
echo "sonik2:/nfs/exports/snfs1 /snfs1 nfs defaults,acl,_netdev 0 0" >> /etc/fstab

systemctl daemon-reload
mount -a


# Rework local storage ===================================================
umount /home
vim /etc/fstab # remove /home mount line
lvdisplay # to find the name of the home logical volume
export VOLUME=rl
export VOLUME_OLD=/dev/$VOLUME/home
lvchange -an $VOLUME_OLD # deactivate volume
lvremove $VOLUME_OLD # kill volume
lvcreate -n scratch -L 1T $VOLUME
lvcreate -n storage $VOLUME -l 100%FREE

# Format volumes
mkfs.xfs /dev/$VOLUME/scratch
mkfs.xfs /dev/$VOLUME/storage

# Mount volumes
mkdir /scratch
mkdir /storage
echo "/dev/$VOLUME/scratch   /home      xfs   defaults   0 0" >> /etc/fstab # temporary... change mount to /scratch later
echo "/dev/$VOLUME/storage   /storage   xfs   defaults   0 0" >> /etc/fstab
systemctl daemon-reload
mount -a

# Disable SELinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config

# === BeeGFS =================================================

# Full server with management, metadata, storage, and client =====================
# Install deps
curl -fsSL https://www.beegfs.io/release/beegfs_8.2/dists/beegfs-rhel9.repo | tee /etc/yum.repos.d/beegfs.repo
dnf install -y beegfs-mgmtd beegfs-meta beegfs-storage beegfs-client beegfs-tools

# Generate auth key. Use same for other nodes...
dd if=/dev/random of=/etc/beegfs/conn.auth bs=128 count=1
chown root:root /etc/beegfs/conn.auth
chmod 400 /etc/beegfs/conn.auth

# Create configs for mgmt, meta, storage
/opt/beegfs/sbin/beegfs-mgmtd --init --tls-disable true --auth-file /etc/beegfs/conn.auth
echo "tls-disable = true" >> /etc/beegfs/beegfs-mgmtd.toml
/opt/beegfs/sbin/beegfs-setup-meta -p /storage/beegfs/meta -s 4 -m medusa4 -f
/opt/beegfs/sbin/beegfs-setup-storage -p /storage/beegfs/storage -s 4 -m medusa4 -f

# Open ports
firewall-cmd --add-port=8003/tcp --permanent # storage
firewall-cmd --add-port=8005/tcp --permanent # meta
firewall-cmd --add-port=8008/tcp --permanent # mgmt
firewall-cmd --add-port=8010/tcp --permanent # mgmt
firewall-cmd --add-port=8003/udp --permanent # storage
firewall-cmd --add-port=8005/udp --permanent # meta
firewall-cmd --add-port=8008/udp --permanent # mgmt
firewall-cmd --reload

systemctl enable --now beegfs-mgmtd.service beegfs-meta.service beegfs-storage.service

# Check nodes/targets
export BEEGFS_TLS_DISABLE='true'
export BEEGFS_MGMTD_ADDR=medusa4:8010
beegfs node list

# Set targets alisases
beegfs target list
beegfs target set-alias target_0-69A244A0-4 target_medusa4_storage
beegfs target set-alias target_0-69A25721-6 target_medusa6_storage

# Mount client locally for testing
echo "/snfs2 /etc/beegfs/beegfs-client.conf" > /etc/beegfs/beegfs-mounts.conf
/opt/beegfs/sbin/beegfs-setup-client -m medusa4
systemctl enable --now beegfs-client

# Disable stripping:
#  1. Nodes tend to fail a lot here... On failure, better to lose the files on a single node than to corrupt files of multiple nodes
#  2. On node failure, easier to fix/manage.
#  3. Read/write performance: spikes... If lucky, file is in the same node (basically bare metal performance), it not, network bound...
beegfs entry set --num-targets 1 /snfs2


# Show all nodes (clients included)
beegfs node list

# LAST: disable new servers from entering
echo "registration-disable = true" >> /etc/beegfs/beegfs-mgmtd.toml
systemctl status beegfs-mgmtd.service 

# +++ On node failure +++++++++++++++
# Can delete storage targets and return them later with the same name. no file lost
beegfs target list --state                   # check targets
beegfs target delete target_medusa6_storage  # delete the target

# Before recovering, stop all clients on each node...
systemctl stop beegfs-client

# When the target connects to mgmt, it has a target alias. Just set the old alias
beegfs target set-alias target_0-69A25721-6 target_medusa6_storage  


# Just storage ===========================
dnf install beegfs-storage -y
firewall-cmd --add-port=8003/udp --permanent
firewall-cmd --add-port=8003/tcp --permanent
firewall-cmd --reload
/opt/beegfs/sbin/beegfs-setup-storage -p /storage/beegfs/storage -s 4 -m medusa4 -f
systemctl enable --now beegfs-storage

# Just client (rocky) =================
curl -fsSL https://www.beegfs.io/release/beegfs_8.2/dists/beegfs-rhel9.repo | tee /etc/yum.repos.d/beegfs.repo
dnf install -y beegfs-client
echo "/snfs2 /etc/beegfs/beegfs-client.conf" > /etc/beegfs/beegfs-mounts.conf
/opt/beegfs/sbin/beegfs-setup-client -m medusa4
# COPY AUTH KEY
systemctl enable --now beegfs-client


# Just client (ubuntu) ================
wget https://www.beegfs.io/release/beegfs_8.2/gpg/GPG-KEY-beegfs -O /etc/apt/trusted.gpg.d/beegfs.asc
wget https://www.beegfs.io/release/beegfs_8.2/dists/beegfs-noble.list -O /etc/apt/sources.list.d/beegfs.list
apt update
apt install beegfs-client -y
/opt/beegfs/sbin/beegfs-setup-client -m medusa4
echo "/snfs2 /etc/beegfs/beegfs-client.conf" > /etc/beegfs/beegfs-mounts.conf
# COPY AUTH KEY
# ADD HOSTS
systemctl enable --now beegfs-client
ls /snfs2/root

