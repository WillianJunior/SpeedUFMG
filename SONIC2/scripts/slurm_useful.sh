acc_slurm_wait_stats() {
    local starttime="$1"
    local endtime="$2"

    sacct --starttime="$starttime" --endtime="$endtime" \
          --format=Partition,Submit,Start \
          --parsable2 --noheader |
    awk -F'|' '
    function to_epoch(ts, cmd, e) {
        gsub("T"," ",ts)
        cmd = "date -d \"" ts "\" +%s"
        cmd | getline e
        close(cmd)
        return e
    }
    $2 != "" && $3 != "" &&
    $2 != "None" && $3 != "None" &&
    $2 != "Unknown" && $3 != "Unknown" {

        wait = (to_epoch($3) - to_epoch($2)) / 3600.0

        part = $1
        if (!(part in min) || wait < min[part]) min[part] = wait
        if (!(part in max) || wait > max[part]) max[part] = wait

        sum[part] += wait
        cnt[part]++
    }
    END {
        printf "%-20s %12s %12s %12s %10s\n",
               "Partition", "Min(hr)", "Avg(hr)", "Max(hr)", "Jobs"

        for (p in cnt)
            printf "%-20s %12.2f %12.2f %12.2f %10d\n",
                   p, min[p], sum[p]/cnt[p], max[p], cnt[p]
    }'
}

acc_slurm_user_node_hours() {
    local starttime="$1"
    local endtime="$2"

    sacct --starttime="$starttime" --endtime="$endtime" \
          --format=User,Submit,Start,Elapsed,AllocNodes,State \
          --parsable2 --noheader |
    awk -F'|' '
    function to_epoch(ts, cmd, e) {
        if (ts == "" || ts == "Unknown" || ts == "None") return -1
        gsub("T"," ",ts)
        cmd = "date -d \"" ts "\" +%s"
        cmd | getline e
        close(cmd)
        return e
    }

    function to_seconds(t, a, h, m, s, d) {
        d = 0
        if (t ~ /-/) {
            split(t, a, "-"); d = a[1]; t = a[2]
        }
        split(t, a, ":")
        if (length(a) == 3) { h=a[1]; m=a[2]; s=a[3] }
        else if (length(a) == 2) { h=0; m=a[1]; s=a[2] }
        else return 0
        return d*86400 + h*3600 + m*60 + s
    }

    $1 != "" && $1 != "root" && $5 > 0 && $2 != "Unknown" && $3 != "Unknown" {

        user = $1

        # node-hours
        elapsed = to_seconds($4)
        node_hours = (elapsed * $5) / 3600.0

        # waiting time (Submit -> Start)
        submit = to_epoch($2)
        start  = to_epoch($3)

        wait = 0
        if (submit > 0 && start > 0 && start >= submit)
            wait = (start - submit) / 3600.0

        sum[user] += node_hours
        cnt[user]++

        wait_sum[user] += wait
        if (!(user in wait_max) || wait > wait_max[user])
            wait_max[user] = wait
    }

    END {
        for (u in sum)
            printf "%-20s %15.2f %10d %15.2f %15.2f\n",
                   u,
                   sum[u],
                   cnt[u],
                   wait_sum[u]/cnt[u],
                   wait_max[u]
    }' |
    sort -k2 -nr |
    awk 'BEGIN {
        printf "%-20s %15s %10s %20s %20s\n",
               "User","NodeHours","Jobs","AvgWait(hr)","MaxWait(hr)"
    }
    { print }'
}
