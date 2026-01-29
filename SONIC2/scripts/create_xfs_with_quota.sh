# bad: this creates an image on top of another mount
# result: inefficient as there is a stack of 2 formats
# can be usefull for testing nevertheless
fallocate -l 2048G $IMG_PATH

# format volume/image and add entry to fstab
mkfs xfs -F $IMG_PATH
mkdir -p $MOUNT_PATH
chmod 1755 $MOUNT_PATH
echo "$IMG_PATH $MOUNT_PATH xfs defaults,rw,sync,uquota 0 0" >> /etc/fstab

# quota: 160G soft and 200G hard, with 7 days of grace period
xfs_quota -x -c 'enable' $MOUNT_PATH
xfs_quota -x -c 'limit -d bsoft=160g bhard=200g' $MOUNT_PATH
xfs_quota -x -c 'timer -u bsoft=7days' $MOUNT_PATH

mount -a

# to make fstab mount these at boot
systemctl daemon-reload
