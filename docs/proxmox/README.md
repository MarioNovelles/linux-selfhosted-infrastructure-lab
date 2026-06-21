# Proxmox Notes

This folder documents the Proxmox VE layer of my self-hosted infrastructure lab.

The goal is to document the step-by-step build process clearly enough that the environment can be rebuilt, audited, or extended later without relying only on memory.

The documentation is split into small steps: Proxmox installation, Ubuntu VM creation, first server checks, guest-agent setup, automatic security updates, Docker installation, and optional tooling.

This documentation is intentionally sanitized. It does not publish real internal IP addresses, public IP addresses, hostnames, credentials, storage layouts, VM IDs, backup targets, or production configuration values.

## Documents

| Document                                                                   | Description                                                 |
| -------------------------------------------------------------------------- | ----------------------------------------------------------- |
| [`01-install-proxmox-ve.md`](./01-install-proxmox-ve.md)                   | Proxmox VE installation notes                               |
| [`02-install-ubuntu-vm.md`](./02-install-ubuntu-vm.md) | Ubuntu Server VM installation notes, including Proxmox VM options such as start at boot |
| [`03-ubuntu-server-first-steps.md`](./03-ubuntu-server-first-steps.md)     | First checks and basic setup after installing Ubuntu Server |
| [`04-enable-amd64v3-packages.md`](./04-enable-amd64v3-packages.md)         | Optional AMD64-v3 package notes                             |
| [`05-install-qemu-guest-agent.md`](./05-install-qemu-guest-agent.md)       | QEMU guest agent setup for Proxmox VMs                      |
| [`06-unattended-security-updates.md`](./06-unattended-security-updates.md) | Automatic security update notes with unattended-upgrades    |
| [`07-install-docker.md`](./07-install-docker.md)                           | Docker Engine installation notes                            |
| [`08-install-neovim-lazyvim.md`](./08-install-neovim-lazyvim.md)           | Neovim and LazyVim setup notes                              |

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

