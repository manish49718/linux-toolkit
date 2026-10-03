# Linux Server Automation Toolkit

A set of Bash scripts that monitor server health, back up important data, restart crashed services, and log everything to a central file. Everything runs automatically using cron.

## Features

- **System monitoring:** checks CPU, memory and disk usage and warns when a limit is crossed
- **Automated backups:** compresses a folder into a timestamped `.tar.gz` file
- **Retention policy:** deletes backups older than a set number of days so the disk never fills up
- **Service watchdog:** checks that important services (e.g. `ssh`, `cron`) are running and restarts them if they stop
- **Central logging:** every script writes timestamped messages to one log file
- **Scheduling:** cron runs the scripts automatically

## Project structure

```
toolkit/
├── config.sh          # all settings (limits, paths, service names)
├── common.sh          # shared logging function
├── monitor.sh         # CPU / memory / disk check
├── backup.sh          # backup + old backup cleanup
├── service_check.sh   # service health check and restart
└── logs/
    └── toolkit.log    # log output (ignored by git)
```

## Requirements

- Linux (tested on Ubuntu on AWS EC2)
- Bash, `tar`, `cron`, `systemctl`
- `sudo` access (needed only for restarting services)

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/linux-automation-toolkit.git ~/toolkit
cd ~/toolkit
mkdir -p logs
chmod +x monitor.sh backup.sh service_check.sh
mkdir -p ~/important_data
echo "test file" > ~/important_data/notes.txt
```

## Configuration

Edit `config.sh` to change the settings:

| Variable | Meaning | Default |
|---|---|---|
| `CPU_LIMIT` | Warn when CPU usage is at or above this % | 80 |
| `MEM_LIMIT` | Warn when memory usage is at or above this % | 80 |
| `DISK_LIMIT` | Warn when disk usage is at or above this % | 80 |
| `BACKUP_FROM` | Folder to back up | `$HOME/important_data` |
| `BACKUP_TO` | Folder where backups are stored | `$HOME/backups` |
| `KEEP_DAYS` | Delete backups older than this many days | 7 |
| `SERVICES` | Space-separated list of services to watch | `ssh cron` |

## Usage

Run any script manually:

```bash
./monitor.sh
./backup.sh
./service_check.sh
```

### Schedule with cron

Open the crontab with `crontab -e` and add (replace `ubuntu` with your username):

```
*/5 * * * * /home/ubuntu/toolkit/monitor.sh >> /home/ubuntu/toolkit/logs/cron.out 2>&1
0 2 * * * /home/ubuntu/toolkit/backup.sh >> /home/ubuntu/toolkit/logs/cron.out 2>&1
```

The service checker restarts services, so it needs root. Add it with `sudo crontab -e`:

```
*/5 * * * * /home/ubuntu/toolkit/service_check.sh >> /home/ubuntu/toolkit/logs/cron.out 2>&1
```

| Script | Schedule |
|---|---|
| `monitor.sh` | every 5 minutes |
| `backup.sh` | daily at 2:00 AM |
| `service_check.sh` | every 5 minutes (root crontab) |

## Viewing logs

```bash
tail -20 logs/toolkit.log        # latest entries
grep WARN logs/toolkit.log       # warnings only
grep ERROR logs/toolkit.log      # errors only
```

### Sample output

```
2026-10-02 13:20:01 [INFO] CPU is fine: 3%
2026-10-02 13:20:01 [INFO] Memory is fine: 41%
2026-10-02 13:20:01 [INFO] Disk is fine: 28%
2026-10-02 13:20:05 [INFO] Backup created: /home/ubuntu/backups/backup_2026-10-02_132005.tar.gz
2026-10-02 13:20:05 [INFO] Deleted backups older than 7 days
2026-10-02 13:25:01 [ERROR] cron is DOWN. Restarting...
```

## Restoring from a backup

```bash
mkdir ~/restore
tar -xzf ~/backups/backup_YYYY-MM-DD_HHMMSS.tar.gz -C ~/restore
```

## How it works

1. Each script loads `common.sh`, which loads `config.sh`, so settings and the `log` function are available everywhere.
2. `monitor.sh` reads CPU, memory and disk values with `vmstat`, `free` and `df`, and compares them with the limits.
3. `backup.sh` uses `tar` to create a compressed archive, checks that it succeeded, then uses `find -mtime` to delete old backups.
4. `service_check.sh` loops over `SERVICES`, uses `systemctl is-active` to check each one, and restarts any that are down.
5. Cron runs the scripts on a schedule.

## Testing failure cases

- Set `BACKUP_FROM` to a folder that doesn't exist: the backup logs an ERROR and exits with code 1.
- Run `sudo systemctl stop cron`, then `./service_check.sh`: the service is detected as down and restarted.

## Possible improvements

- Email or Slack alerts for WARN and ERROR messages
- Upload backups to AWS S3 so they survive a server failure
- Rotate logs with `logrotate`
- Add a `--dry-run` option
- Deploy to many servers using Ansible

## Skills demonstrated

Bash scripting, Linux administration, cron scheduling, log management, backup strategy, error handling with exit codes, AWS EC2.
