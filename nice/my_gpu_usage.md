Checking gpu usage with `nvidia-smi dmon -s pumc -d 10`.
Using systemd to start the deamon to always log.
Using logrotate weekly to avoid large files.

Don't forget to `systemctl enable --now my_gpu_usage`.

## /usr/local/bin/my_gpu_usage.sh
```command
#!/bin/bash
# log NVIDIA metrics with timestamp every 10s
nvidia-smi dmon -s pumc -d 10 | awk '{ print strftime("%Y-%m-%d %H:%M:%S"), $0; fflush(); }'

```

## /etc/systemd/system/my_gpu_usage.service
```ini
[Unit]
Description=GPU monitoring using nvidia-smi dmon
After=multi-user.target
Wants=multi-user.target

[Service]
Type=simple
#ExecStart=/usr/bin/nvidia-smi dmon -s pumc -d 10

# Script with date/time
ExecStart=/usr/local/bin/my_gpu_usage.sh

Restart=always
RestartSec=5
StandardOutput=append:/var/log/my_gpu_usage/my_gpu_usage.log

[Install]
WantedBy=multi-user.target
```

## /etc/logrotate.d/my_gpu_usage
```conf
/var/log/my_gpu_usage/my_gpu_usage.log {
    weekly
    missingok
    notifempty
    rotate 53
    copytruncate
}
```
Test with `logrotate -d /etc/logrotate.d/my_gpu_usage`. Test forced rotate with `logrotate -f /etc/logrotate.d/my_gpu_usage`

