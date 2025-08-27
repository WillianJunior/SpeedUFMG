# Reboot node and return it to the queue
scontrol reboot gorgona6
scontrol update NodeName=gorgona[6] State=Resume

# Create reservation
scontrol create reservation user=username nodes=gorgona4 starttime=now endtime=2024-03-16 flags=magnetic reservationname=r1

# Print all allocations in the last 30 days (canceled with 0 runtime not here)
# Printing: JobID|DayOfStart|User|Nodes|ElapsedTimeInSecs
sacct --starttime=$(date -d '30 days ago' +%Y-%m-%d) --format=JobID,Start,User,State,NNodes,CPUTimeRAW --noheader --allocations | awk '$1 ~ /^[0-9]+$/ && $2 != "None" { split($2, d, "T"); $2=d[1]; print }' | awk '{$6 = $6 / 32; print}'

# Print total time in seconds spent by each user in the last 30 days. last column is the % of the last 30 days the user has used
sacct -S $(date -d '30 days ago' +%Y-%m-%d) --format=User,CPUTimeRAW -n -P --allocations | awk -F'|' '{cpu[$1]+=$2} END {for (u in cpu) print u, cpu[u]}' | sort -n -k2 | awk '{$2=$2/32/3600; $3=sprintf("%.2f%%", $2/(6*24*30)*100); print}'


# Returns the CPU usage for jobs in the last 30 days
susage(){
  DAYS="$1"
  echo "JobID User Elapsed Timelimit AveCPU"; sacct -S "$(date -d '$DAYS days ago' +%Y-%m-%d)" --format=JobID,User,Elapsed,Timelimit,AveCPU --parsable2 --noheader | awk -F'|' '{if ($1 ~ /^[0-9]+$/) {user[$1]=$2; timelimit[$1]=$4} else if ($1 ~ /\.batch$/) {split($1,a,"."); jobid=a[1]; print jobid, user[jobid], $3, timelimit[jobid], $5}}'
}

# Returns jobs which used a minimum of MIN_USAGE average CPU time
sminusage(){
  DAYS="$1"
  MIN_USAGE="$2"   # format: 00:01:00 
  susage $DAYS | awk -v min="$MIN_TIME" '{split($5,t,":"); et=t[1]*3600+t[2]*60+t[3]; split(min,m,":"); mt=m[1]*3600+m[2]*60+m[3]; if(et>mt) print}'
}



