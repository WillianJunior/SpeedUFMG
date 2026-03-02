# tested on medusa5
# BAD:
# 1. using static IP on SPEED
# 2. using CRC IP for internet
# 3. mounting /home with /dev/mapper/rl_cisteina-scratch -> TODO: use the correct /home across all nodes
# 4. mounting sonic_home -> TODO: should be /home
# Change to ansible

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

# Load htop config from cluster, apply to root, and set skeleton
cp /sonic_etc/skel/.config/htop/htoprc ~/.config/htop/htoprc 
mkdir -p /etc/skel/.config/htop
cp ~/.config/htop/htoprc /etc/skel/.config/htop/
chmod 644 /etc/skel/.config/htop/htoprc


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


medusa4 e 6 pararam aqui... ===================================

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

# Allow slurm controller to send requests
firewall-cmd --permanent --add-port=6817-6818/tcp
firewall-cmd --reload

SLURM_UID=38000
SLURM_GID=38010
MUNGE_UID=48000
MUNGE_GID=48010
useradd -r -u $SLURM_UID -g $SLURM_GID -d /var/lib/slurm -s /sbin/nologin slurm
useradd -r -u $MUNGE_UID -g $MUNGE_GID -d /var/lib/munge -s /sbin/nologin munge



dnf install -y munge munge-libs munge-devel
# copy munge key file

chmod 0700 /etc/munge/
chmod 0711 /var/lib/munge/
chmod 0700 /var/log/munge/
mkdir /run/munge
chmod 0755 /run/munge
touch /var/log/munge/munged.log
chown munge /etc/munge/ /var/lib/munge/ /var/log/munge/ /run/munge /var/log/munge/munged.log
chgrp munge /etc/munge/ /var/lib/munge/ /var/log/munge/ /run/munge /var/log/munge/munged.log


dnf install -y pam-devel perl-ExtUtils-MakeMaker readline-devel systemd-devel dbus-devel

wget https://download.schedmd.com/slurm/slurm-23.02.4.tar.bz2
tar --bzip -x -f slurm-23.02.4.tar.bz2; 
cd slurm-23.02.4
mkdir /usr/local/slurm
mkdir /lib/security
./configure --prefix=/usr/local/slurm/ --without-hdf5 --enable-pam --with-pam_dir=/lib/security --sysconfdir=/etc/slurm


make -j
make install
make contrib -j
cd contribs/pam_slurm_adopt/
make install
cd ../..
ldconfig -n /usr/local/slurm/lib/


mkdir /usr/local/slurm/etc

echo 'export PATH=/usr/local/slurm/bin:$PATH' | tee /etc/profile.d/slurm.sh > /dev/null
chmod +x /etc/profile.d/slurm.sh

echo "d /run/slurm 0770 slurm slurm -" > /etc/tmpfiles.d/slurm.conf
systemd-tmpfiles --create

ln -s /sonic_etc/slurm /etc/slurm

cp etc/slurmd.service /etc/systemd/system/
systemctl enable --now slurmd.service


# Security/ssh/pam =======================================================
# if .so from pam are not at lib64
ln -s /usr/lib/security/pam_*slurm* /usr/lib64/security/

# remove/commit the following line from /etc/ssh/sshd_config
# Include /etc/ssh/sshd_config.d/*.conf

# prepend in /etc/pam.d/sshd:
# account required pam_slurm_adopt.so
# auth required pam_succeed_if.so user ingroup speed
# auth sufficient pam_permit.so

# remove/comment in /etc/pam.d/sshd:
# auth       substack     password-auth
# auth       include      postlogin






# TODO: resolver gres 1gpu 32cores

GRES 1 GPU
