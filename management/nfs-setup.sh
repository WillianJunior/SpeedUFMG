# Tested for Rocky 8.10

# Block non-root ssh sessions
echo "AllowUsers root" >> /etc/ssh/sshd_config

FS_NAME=snfs1
FS_IMG=/home/nfs_imgs/${FS_NAME}.img
FS_MOUNT=/nfs/exports/${FS_NAME}

# Create virtual device
mkdir /home/nfs_imgs
fallocate -l 2048G $FS_IMG
mkfs.xfs -f -n ftype=1 $FS_IMG

# Mount virtual dev
mkdir -p $FS_MOUNT
chmod 1777 $FS_MOUNT
echo "$FS_IMG $FS_MOUNT xfs loop,rw,sync,usrquota,grpquota,prjquota 0 0" >> /etc/fstab
systemctl daemon-reload
mount -a

# Setup quotas
dnf install -y quota-rpc
systemctl enable --now rpc-rquotad.service # allows quota querying from remote host
xfs_quota -x -c 'state' # Check if quotas are enforced
# TODO: find a way to check project quotas remotely

# Create speed base project
SPEED_PATH=$FS_MOUNT/speed
mkdir $SPEED_PATH
chgrp speed $SPEED_PATH
chmod 1777 $SPEED_PATH
PROJ_ID=2077 # speed group id
PROJ_NAME=speed
echo "$PROJ_ID:$SPEED_PATH" >> /etc/projects
echo "$PROJ_NAME:$PROJ_ID" >> /etc/projid
xfs_quota -x -c "project -s $PROJ_NAME" $FS_MOUNT
xfs_quota -x -c "limit -p bhard=2t bsoft=2t $PROJ_NAME" $FS_MOUNT
xfs_quota -x -c 'report -p' $FS_MOUNT # check quota

# Setup NFS server
dnf install -y nfs-utils
systemctl enable --now nfs-server
systemctl enable --now rpcbind
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-port=875/tcp # for rpc-rquotad
firewall-cmd --permanent --add-port=875/udp # for rpc-rquotad
firewall-cmd --reload
echo "$FS_MOUNT 150.164.203.0/24(rw)" >> /etc/exports # allows any host in subnet 150.164.203.0/24
exportfs -rv

### ==========================================================================

# For clients (automounts at boot)
apt install -y nfs-common
mkdir /snfs1
echo "150.164.203.121:/nfs/exports/snfs1 /snfs1 nfs defaults 0 0" >> /etc/fstab
mount -a
systemctl daemon-reload
ls /snfs1
