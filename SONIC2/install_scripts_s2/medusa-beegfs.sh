# Tested on medusa4

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



# ========================================================================
# ========================================================================
# ========================================================================
# ========================================================================
# start beegfs...


# Disable SELinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config

# === MANAGER =================================================

# Install deps
curl -fsSL https://www.beegfs.io/release/beegfs_8.2/dists/beegfs-rhel9.repo | tee /etc/yum.repos.d/beegfs.repo
dnf install -y beegfs-mgmtd beegfs-meta beegfs-storage beegfs-client beegfs-tools

# Generate auth key. Use same for other nodes...
openssl rand -hex 32 | sudo tee /etc/beegfs/conn.auth

# Create beegfs user
groupadd --system beegfs
useradd --system --gid beegfs --home-dir /var/lib/beegfs --shell /sbin/nologin beegfs

# Setup management service
mkdir -p /var/lib/beegfs/mgmtd
echo "storeMgmtdDirectory = /var/lib/beegfs/mgmtd" > /etc/beegfs/beegfs-mgmtd.conf
echo "connAuthFile = /etc/beegfs/conn.auth" >> /etc/beegfs/beegfs-mgmtd.conf
/opt/beegfs/sbin/beegfs-mgmtd --init

echo "tls-disable = true" >> /etc/beegfs/beegfs-mgmtd.toml
chown -R beegfs:beegfs /var/lib/beegfs
chmod 700 /var/lib/beegfs
systemctl enable --now beegfs-mgmtd.service

# Setup metadata service
mkdir -p /storage/beegfs/metadata
chown -R beegfs:beegfs /storage/beegfs/metadata
chmod 700 /storage/beegfs/metadata
echo "sysMgmtdHost = medusa4" > /etc/beegfs/beegfs-meta.conf
echo "storeMetaDirectory = /storage/beegfs/metadata" >> /etc/beegfs/beegfs-meta.conf
echo "connAuthFile = /etc/beegfs/conn.auth" >> /etc/beegfs/beegfs-meta.conf
systemctl enable --now beegfs-meta

# Setup storage service
mkdir -p /storage/beegfs/storage
chown -R beegfs:beegfs /storage/beegfs/storage
chmod 700 /storage/beegfs/storage
echo "sysMgmtdHost = medusa4" > /etc/beegfs/beegfs-storage.conf
echo "storeStorageDirectory = /storage/beegfs/storage" >> /etc/beegfs/beegfs-storage.conf
echo "connAuthFile = /etc/beegfs/conn.auth" >> /etc/beegfs/beegfs-storage.conf
systemctl enable --now beegfs-storage

# === \MANAGER ================================================


TODO: 
 - install/configure client
 - mount and test storage
 - create a medusa pool
 - add another medusa to the pool


