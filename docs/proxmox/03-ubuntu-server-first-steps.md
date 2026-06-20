# Ubuntu Server First Steps

This documents the first checks I do after installing an Ubuntu Server VM.

The goal is to make sure the server is updated, reachable, and ready before I install application services such as Docker.

## 1. Update the system

```bash
# Update package lists
sudo apt update

# Install available updates
sudo apt full-upgrade -y

# Remove packages that are no longer needed
sudo apt autoremove -y

# Reboot after updates
sudo reboot
```

## 2. Check hostname and system info

```bash
# Show hostname and basic system information
hostnamectl

# Show uptime and load
uptime
```

## 3. Check network configuration

```bash
# Show IP addresses
ip addr

# Show default route
ip route

# Check DNS resolver status
resolvectl status
```

## 4. Install basic tools

Some tools may already be installed, depending on the Ubuntu Server image.

```bash
# Check whether common admin tools are available
command -v curl
command -v wget
command -v git
command -v htop
```

If something is missing, I install only what I need:

```bash
# Install useful tools if they are missing
sudo apt install -y curl wget git htop ca-certificates
```

## 5. Check SSH access

```bash
# Check SSH service status
systemctl status ssh

# Check SSH server configuration syntax
sudo sshd -t
```

From another machine:

```bash
# Test SSH login from another machine
ssh <username>@<server-ip>
```

## 6. Check firewall status

```bash
# Check UFW firewall status
sudo ufw status verbose
```

If UFW is not used yet, I document that instead of pretending it is configured.

## 7. Check date, time, and timezone

Correct time is important for logs, TLS certificates, backups, monitoring, and troubleshooting.

```bash
# Show current date and time
date

# Show timezone and time synchronization status
timedatectl
```

If the timezone is wrong, set it:

```bash
# Set the server timezone to Berlin
sudo timedatectl set-timezone Europe/Berlin
```

If time synchronization is disabled, enable it:

```bash
# Enable automatic time synchronization
sudo timedatectl set-ntp true
```

Check again:

```bash
# Verify time and timezone again
date
timedatectl
```

## 8. Check disk, memory, and CPU

```bash
# Show disk usage
df -h

# Show block devices
lsblk

# Show memory usage
free -h

# Show CPU count
nproc
```

## 9. Check failed services

```bash
# Show failed systemd units
systemctl --failed
```

If there are failed units, I investigate them before installing more services.

## 10. Reboot and verify

```bash
# Reboot once after updates and basic setup
sudo reboot
```

After reboot:

```bash
# Check that the system came back cleanly
uptime
systemctl --failed
ip addr
```

## Final result

At the end of this runbook, the server should be:

* updated
* reachable by SSH
* using correct network settings
* showing correct time
* free of failed systemd units
* ready for the next setup step

## What I learned

A fresh server should be checked before adding services.

This makes later troubleshooting easier because I know the base system was working before Docker or application services were installed.

