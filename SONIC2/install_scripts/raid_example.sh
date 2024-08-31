#!/bin/bash
# Tested on:
# OS:     Rocky 8.10
# Kernel: 4.18.0-553.16.1.el8_10.x86_64

# must create hostid for zpool
systemd-machine-id-setup

# Creating logical volumes as an example.
# Ideally, each dev should be a whole disk
lvcreate --yes --wipesignatures y --zero y -L 1G -n r1test2_mdt0 lustre
lvcreate --yes --wipesignatures y --zero y -L 1G -n r1test2_dev0_ost0 lustre
lvcreate --yes --wipesignatures y --zero y -L 1G -n r1test2_dev1_ost0 lustre
lvcreate --yes --wipesignatures y --zero y -L 1G -n r1test2_dev2_ost0 lustre
lvcreate --yes --wipesignatures y --zero y -L 1G -n r1test2_dev3_ost0 lustre

# Create the zpool with the mirror configuration
zpool create -o multihost=on -O canmount=off -O recordsize=1024K -o cachefile=none \
  r1test2_ost0_pool mirror \
  lustre/r1test2_dev0_ost0 lustre/r1test2_dev1_ost0 \
  spare lustre/r1test2_dev2_ost0
# Create the zpool with the raidz configuration
zpool create -o multihost=on -O canmount=off -O recordsize=1024K -o cachefile=none \
  r1test2_ost0_pool raidz1 lustre/r1test2_dev0_ost0 lustre/r1test2_dev1_ost0 lustre/r1test2_dev2_ost0 \
  spare lustre/r1test2_dev3_ost0

# Learning time:
# raidz-k is just raid5 with k parity disks
# thus, raidz1 needs 2+1 disks, raidz2 needs 2+2 disks ...

# checking pool status
zpool status r1test2_ost0_pool

# Formating for lustre
mkfs.lustre --mdt --reformat --fsname=r1test2 --index=0 \
  --mgsnode=alexandria1@tcp1 --backfstype=zfs  \
  r1test2_mdt0/lustre lustre/r1test2_mdt0
mkfs.lustre --ost --reformat --fsname=r1test2 --index=0 \
  --mgsnode alexandria1@tcp1 --backfstype=zfs \
  r1test2_ost0_pool/ost0

# Notes: 
#  - check lnet interface of mgs node, which must match
#  - care for index!. After a target is created with a given index, the index CANNOT BE REUSED!!!
#    even if the previous target was destroyed by zpool destroy/lvremove. It returns an
#    error at mount time: "The target service's index is already in use."

# Mounting
mkdir -p /lustre/r1test2/mdt0
mkdir -p /lustre/r1test2/ost0
mount -t lustre r1test2_mdt0/lustre /lustre/r1test2/mdt0
mount -t lustre r1test2_ost0_pool/ost0 /lustre/r1test2/ost0/

# Maintenance
zpool status r1test2_ost0_pool
#   pool: r1test2_ost0_pool
#  state: ONLINE
# config:

# 	NAME                   STATE     READ WRITE CKSUM
# 	r1test2_ost0_pool      ONLINE       0     0     0
# 	  raidz1-0             ONLINE       0     0     0
# 	    r1test2_dev0_ost0  ONLINE       0     0     0
# 	    r1test2_dev1_ost0  ONLINE       0     0     0
# 	    r1test2_dev2_ost0  ONLINE       0     0     0
# 	spares
# 	  r1test2_dev3_ost0    AVAIL   

# Assuming a device dev1 is bad, it should automatically be replaced by the spare by zpool
# However, let's assume that we want to decomission dev1 and replace it with the spare

zpool replace r1test2_ost0_pool lustre/r1test2_dev1_ost0 lustre/r1test2_dev3_ost0
zpool status r1test2_ost0_pool
#   pool: r1test2_ost0_pool
#  state: ONLINE
# status: One or more devices is currently being resilvered.  The pool will
# 	continue to function, possibly in a degraded state.
# action: Wait for the resilver to complete.
#   scan: resilver in progress since Sat Aug 31 12:32:44 2024
# 	16.2M scanned at 0B/s, 16.2M issued at 6.01M/s, 16.2M total
# 	10.5M resilvered, 100.00% done, no estimated completion time
# config:

# 	NAME                     STATE     READ WRITE CKSUM
# 	r1test2_ost0_pool        ONLINE       0     0     0
# 	  raidz1-0               ONLINE       0     0     0
# 	    r1test2_dev0_ost0    ONLINE       0     0     0
# 	    spare-1              ONLINE       0     0     0
# 	      r1test2_dev1_ost0  ONLINE       0     0     0
# 	      r1test2_dev3_ost0  ONLINE       0     0     0  (resilvering)
# 	    r1test2_dev2_ost0    ONLINE       0     0     0
# 	spares
# 	  r1test2_dev3_ost0      INUSE     currently in use

# errors: No known data errors

# The above would be the result of dev1 failing

# Now we detach dev1 to replace the actual disk later
zpool detach r1test2_ost0_pool lustre/r1test2_dev1_ost0
zpool status r1test2_ost0_pool
#   pool: r1test2_ost0_pool
#  state: ONLINE
#   scan: resilvered 10.5M in 00:00:02 with 0 errors on Sat Aug 31 12:32:46 2024
# config:

# 	NAME                   STATE     READ WRITE CKSUM
# 	r1test2_ost0_pool      ONLINE       0     0     0
# 	  raidz1-0             ONLINE       0     0     0
# 	    r1test2_dev0_ost0  ONLINE       0     0     0
# 	    r1test2_dev3_ost0  ONLINE       0     0     0
# 	    r1test2_dev2_ost0  ONLINE       0     0     0

# errors: No known data errors

# Let's return the spare disk, since it is now somehow fixed
zpool add r1test2_ost0_pool spare lustre/r1test2_dev1_ost0
zpool status r1test2_ost0_pool
#   pool: r1test2_ost0_pool
#  state: ONLINE
#   scan: resilvered 10.5M in 00:00:02 with 0 errors on Sat Aug 31 12:32:46 2024
# config:

# 	NAME                   STATE     READ WRITE CKSUM
# 	r1test2_ost0_pool      ONLINE       0     0     0
# 	  raidz1-0             ONLINE       0     0     0
# 	    r1test2_dev0_ost0  ONLINE       0     0     0
# 	    r1test2_dev3_ost0  ONLINE       0     0     0
# 	    r1test2_dev2_ost0  ONLINE       0     0     0
# 	spares
# 	  r1test2_dev1_ost0    AVAIL 

# What if a new disk was added?
# The new disk arrived, we installed it
lvcreate --yes --wipesignatures y --zero y -L 1G -n r1test2_dev4_ost0 lustre # Creating a new dev as an example

# ... now we can just add it to the pool
zpool add r1test2_ost0_pool spare lustre/r1test2_dev4_ost0
zpool status r1test2_ost0_pool
#   pool: r1test2_ost0_pool
#  state: ONLINE
#   scan: resilvered 10.5M in 00:00:02 with 0 errors on Sat Aug 31 12:32:46 2024
# config:

# 	NAME                   STATE     READ WRITE CKSUM
# 	r1test2_ost0_pool      ONLINE       0     0     0
# 	  raidz1-0             ONLINE       0     0     0
# 	    r1test2_dev0_ost0  ONLINE       0     0     0
# 	    r1test2_dev3_ost0  ONLINE       0     0     0
# 	    r1test2_dev2_ost0  ONLINE       0     0     0
# 	spares
# 	  r1test2_dev4_ost0    AVAIL   
# 	  r1test2_dev1_ost0    AVAIL  




