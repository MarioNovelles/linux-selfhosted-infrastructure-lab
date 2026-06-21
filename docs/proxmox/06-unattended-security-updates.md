# Configure Unattended Upgrades on Ubuntu Server

This note documents how I check and configure automatic security updates on an Ubuntu Server VM.

## Goal

Keep the server safer by applying Ubuntu security updates automatically, while still checking logs and reboot behavior manually.

## Important files

```text
/etc/apt/apt.conf.d/20auto-upgrades
/etc/apt/apt.conf.d/50unattended-upgrades
/var/log/unattended-upgrades/
```

## Check that unattended-upgrades is installed

```bash
# Check whether unattended-upgrades is installed
dpkg -l unattended-upgrades
```

If it is missing:

```bash
# Install unattended-upgrades
sudo apt install unattended-upgrades
```

## Check automatic update settings

```bash
# Show the automatic update configuration
cat /etc/apt/apt.conf.d/20auto-upgrades
```

Expected basic settings:

```text
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

This means:

```text
Update-Package-Lists "1" = refresh package lists daily
Unattended-Upgrade "1" = run unattended upgrades daily
```

## Check unattended-upgrades configuration

```bash
# Open the main unattended-upgrades configuration
sudo nvim /etc/apt/apt.conf.d/50unattended-upgrades
```

Things I check:

```text
Allowed origins
Package blacklist
Automatic reboot behavior
Mail/report options
```

For my lab, I prefer security updates automatically, but I do not want unexpected automatic reboots unless I configure that intentionally.

## Test without changing anything

```bash
# Simulate unattended upgrades without installing anything
sudo unattended-upgrade -v --dry-run
```

This is useful because it shows what unattended-upgrades would do before it actually changes the system.

## Check logs

```bash
# List unattended-upgrades logs
ls -lah /var/log/unattended-upgrades/

# Read the main unattended-upgrades log
sudo less /var/log/unattended-upgrades/unattended-upgrades.log
```

## Check if a reboot is needed

```bash
# Check whether Ubuntu says a reboot is required
test -f /var/run/reboot-required && cat /var/run/reboot-required
```

If the file exists, I plan a reboot during a safe time.

## Notes

Unattended upgrades help reduce the risk of missing security updates.

They are not a replacement for maintenance planning. I still need to check logs, understand reboot requirements, and be careful with systems that run important services.

Reference: https://ubuntu.com/server/docs/how-to/software/automatic-updates/
