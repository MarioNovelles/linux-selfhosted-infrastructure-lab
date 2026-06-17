# Infrastructure Build Documentation

This section documents the step-by-step build process for my self-hosted infrastructure lab.

The documentation is split by layer so the environment can be rebuilt, audited, or extended more easily.

## Proxmox VE

| Document                              | Description                                                                                                                           |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `01-install-proxmox-ve.md`            | Proxmox VE installation, initial network configuration, repositories, hostname, updates, and storage validation                       |
| `02-create-ubuntu-docker-vm.md`       | Creation of the Ubuntu Server VM used as the Docker Compose host                                                                      |
| `03-configure-ubuntu-docker-host.md`  | Ubuntu VM post-install configuration, SSH access, QEMU Guest Agent, optional amd64v3 configuration, Docker Engine, and Docker Compose |
| `04-proxmox-troubleshooting-notes.md` | Notes for common issues such as DNS failures, gateway problems, SSH access, VM networking, disk usage, and memory/swap monitoring     |

## Design Principles

* Keep the Proxmox host clean and dedicated to virtualization.
* Run Docker inside an Ubuntu Server VM instead of directly on the Proxmox host.
* Store active application data, databases, metadata, logs, and caches on local SSD-backed VM storage.
* Store large media files, photos, backups, and shared data on dedicated NAS storage.
* Prefer simple, repeatable configurations over unnecessary complexity.
* Document each layer separately so the environment can be rebuilt from scratch.

