## Checking network usage
sar -n DEV 1

## Checking IO usage
iostat -x 1 -m

## Checking which process is using IO
iotop -o

# IO Tests

## `tails1`
disk IO for tails1 (real world usage from `iostat`, 100% util): 19 MB/s

## `gorgona3`

### Sequential write 

max disk IO for gorgona3 nvme 149 MB/s

max disk IO for gorgona3 sda 52 MB/s

### Random write:

max disk IO for gorgona3 nvme 95.7 MB/s

max disk IO for gorgona3 sda 1.2 MB/s

### Test script
fio --name=random-write-test     --ioengine=libaio     --direct=1     --rw=write     --bs=4k     --size=1G     --numjobs=1     --runtime=60     --group_reporting     --filename=/tmp/fio-testfile
