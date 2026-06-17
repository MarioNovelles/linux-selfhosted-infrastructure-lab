# Install Proxmox VE

This document summarizes the main installation checks and design decisions for rebuilding the Proxmox VE host in my infrastructure lab.

It is intentionally sanitized and does not include real hostnames, IP addresses, credentials, storage serial numbers, backup targets, firewall rules, or VPN endpoints.

## Goal

The Proxmox host is dedicated to virtualization.

I avoid running application workloads directly on the Proxmox host. Docker services are planned to run inside an Ubuntu Server VM instead, which keeps the host cleaner and makes the Docker environment easier to back up, move, rebuild, and troubleshoot separately.

## Pre-Install Checklist

Before installing Proxmox VE, I would confirm:

* virtualization support is enabled in BIOS/UEFI
* the correct boot mode is selected
* the target installation disk can be erased
* hostname, management IP, gateway, and DNS values are planned
* the network cable and switch port are ready
* the storage plan is understood
* backups of any existing data are complete

The installer can overwrite the selected disk, so the target disk must be checked carefully.

## Installation Notes

Normal installation flow:

1. download the current Proxmox VE ISO
2. write the ISO to a USB drive
3. boot the host from the USB drive
4. install Proxmox VE to the selected disk
5. configure hostname, management IP, gateway, DNS, time zone, and root password

The exact ISO version, repository setup, and supported update path should be checked against the official Proxmox documentation before a real install.

## Network Plan

The Proxmox web interface should use a predictable static management IP.

Example values only:

```text
Hostname:        pve-example
Management IP:   192.0.2.10/24
Gateway:         192.0.2.1
DNS server:      192.0.2.1
Bridge:          vmbr0
```

A simple lab setup usually starts with one Linux bridge, commonly `vmbr0`, connected to the physical LAN interface.

## First Login

After installation, the web interface is normally accessed with HTTPS on port `8006`.

```text
https://proxmox-host.example.local:8006
https://192.0.2.10:8006
```

A browser certificate warning is expected after a fresh install because the default certificate is not trusted by the browser.

## First Checks

After logging in, I would verify:

```bash
hostnamectl
ip addr
ip route
cat /etc/resolv.conf
ping -c 4 1.1.1.1
ping -c 4 debian.org
df -h
lsblk
pvesm status
```

Checks to confirm:

* web interface is reachable
* hostname, management IP, gateway, and DNS are correct
* system time is correct
* expected disk and storage are visible
* network bridge exists
* updates can be checked

If IP ping works but DNS names fail, the issue is likely DNS-related.

## Updates

After installation, repository configuration should be reviewed before running regular updates.

General update flow:

```bash
apt update
apt full-upgrade
```

Before major updates, I would check whether important VMs are running, whether backups exist, and whether a reboot is required.

## Storage and Backup Notes

Before creating important VMs, I would confirm:

* local VM storage is available
* ISO storage is available
* free space is reasonable
* expected SSD/NVMe/HDD devices are visible
* no unexpected disk was overwritten

In this lab, active VM storage is planned for local SSD-backed storage. Large media, photos, shared files, and backups are better suited to dedicated NAS storage.

Before running important workloads, I would also document where VM backups are stored, how often they run, and how restore tests will be performed.

## Host Cleanliness

Good host-level responsibilities:

* virtualization
* VM management
* storage management
* network bridge management
* backups and snapshots
* host updates
* node health monitoring

Things I prefer to run inside VMs or dedicated systems instead:

* Docker application stacks
* web applications
* databases
* media services
* experimental services
* unrelated automation tools

## Security Notes

After installation, I would review root password strength, SSH access, firewall policy, update status, backup access, user permissions, and management network exposure.

The Proxmox management interface should not be exposed directly to the public internet. Remote administration should use VPN-style access or another controlled management path.

## Validation Checklist

* [ ] Proxmox web interface is reachable
* [ ] hostname is correct
* [ ] management IP is correct
* [ ] gateway is correct
* [ ] DNS resolution works
* [ ] updates can be checked
* [ ] storage appears correctly
* [ ] network bridge exists
* [ ] backup plan is documented
* [ ] management interface is not exposed publicly

