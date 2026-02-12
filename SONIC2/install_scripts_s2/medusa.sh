# tested on medusa5

# Base ===================================================================
dnf install -y epel-release
dnf update -y
grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=1 psi=1"
dnf groupinstall -y "Development Tools"
dnf install -y htop cmake

# TODO: configure htop globally with PSI (PSI already showing)

# Security/ssh ===========================================================
echo "AllowUsers root" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
systemctl restart sshd.service


# Network ================================================================
 # - set static ip or dhcp for speed network


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

# mount storages
#  - mount sonic_...
#  - mount sonic_home also as /home

# Rework local storage ===================================================
# Destroy previous /home volume
umount /home
vim /etc/fstab # remove /home mount line
lvdisplay # to find the name of the home logical volume
lvchange -an /dev/rl_cisteina/home # deactivate volume
lvremove /dev/rl_cisteina/home # kill volume

# Create and format new volumes
lvcreate -n scratch -L 1T rl_cisteina
lvcreate -n storage rl_cisteina -l 100%FREE
mkfs.ext4 /dev/rl_cisteina/scratch
mkfs.ext4 /dev/rl_cisteina/storage

# Mount volumes
mkdir /scratch
mkdir /storage
echo '/dev/rl_cisteina/scratch   /scratch   ext4   defaults   0 0' >> /etc/fstab
echo '/dev/rl_cisteina/storage   /storage   ext4   defaults   0 0' >> /etc/fstab
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
EOF

dnf install -y ansible

# modules
#  - install ansible and modules environment
#  - install modules from ansible
#  - test


# Slurm ==================================================================

# slurm client
#  - munge
#  - slurmd

# slurm PAM

# GRES 1 GPU
