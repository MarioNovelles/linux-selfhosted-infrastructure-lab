# Proxmox Notes

This folder documents the Proxmox VE layer of my self-hosted infrastructure lab.

The goal is to document the step-by-step build process clearly enough that the environment can be rebuilt, audited, or extended later without relying only on memory.

The documentation is split by layer: Proxmox host installation, Ubuntu VM creation, Docker host configuration, and troubleshooting notes.

This documentation is intentionally sanitized. It does not publish real internal IP addresses, public IP addresses, hostnames, credentials, storage layouts, VM IDs, backup targets, or production configuration values.

## Documents

| Document                                                                       | Description                                                                                                                       |
| ------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| [`01-install-proxmox-ve.md`](./01-install-proxmox-ve.md)                       | Proxmox VE installation, initial network configuration, repositories, hostname, updates, and storage validation                   |
| [`02-create-ubuntu-docker-vm.md`](./02-create-ubuntu-docker-vm.md)             | Creation of the Ubuntu Server VM used as the Docker Compose host                                                                  |
| [`03-configure-ubuntu-docker-host.md`](./03-configure-ubuntu-docker-host.md)   | Ubuntu VM post-install configuration, SSH access, QEMU Guest Agent, Docker Engine, Docker Compose, and host preparation           |
| [`04-proxmox-troubleshooting-notes.md`](./04-proxmox-troubleshooting-notes.md) | Notes for common issues such as DNS failures, gateway problems, SSH access, VM networking, disk usage, and memory/swap monitoring |

## Design Principles

* Keep the Proxmox host clean and dedicated to virtualization.
* Run Docker inside an Ubuntu Server VM instead of directly on the Proxmox host.
* Store active application data, databases, metadata, and performance-sensitive working data on local SSD-backed VM storage.
* Store large media files, photos, backups, and shared data on dedicated NAS storage.
* Prefer simple, repeatable configurations over unnecessary complexity.
* Document each layer separately so the environment can be rebuilt from scratch.

## Scope

This section focuses on practical rebuild notes for my lab.

It is not meant to replace official Proxmox documentation. Instead, it documents the operational steps, design choices, and troubleshooting notes that matter for this environment.

