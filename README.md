# health_check.sh

A simple Linux server health check script for first-line infrastructure support and monitoring.

## What it checks

| Check | Source | Thresholds |
|-------|--------|-----------|
| CPU usage | `/proc/stat` | Warning: 70%, Critical: 90% |
| RAM usage | `/proc/meminfo` | Warning: 75%, Critical: 90% |
| Disk usage | `df` for mounted filesystems | Warning: 80%, Critical: 95% |
| Network connectivity | `ip route`, `ping` | Gateway reachability, Internet reachability |
| Uptime | `uptime -p`, `/proc/loadavg` | Informational |

Status output is color-coded:
- **OK** — green
- **WARNING** — yellow
- **CRITICAL** — red

## Requirements

- `bash`
- `df`
- `bc`
- `ip`
- `ping`

These tools are available on most Linux distributions by default.

## How to run

```bash
chmod +x health_check.sh
./health_check.sh
```

## Example output

```text
[ CPU ]
 CPU Usage         5.0%  [OK]

[ MEMORY ]
 RAM Usage        35.5%  [OK]

[ DISK ]
 /                  41%  [OK]

[ NETWORK ]
 Gateway: UP (194.147.78.1, 0.877 ms)
 Internet: UP (8.8.8.8, 21.3 ms)

[ UPTIME ]
 up 1 week, 2 days, 22 hours, 47 minutes
 Load average: 0.01 0.03 0.00
```

## Example use cases

- Manual incident triage
- Quick server health review before escalation
- Scheduled checks with `cron`

Example cron entry:

```bash
*/30 * * * * /root/health_check_script/health_check.sh >> /var/log/health_check.log 2>&1
```

## Portfolio note

Created as a portfolio artifact for monitoring, IT support, and infrastructure support roles.
