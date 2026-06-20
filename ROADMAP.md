# Roadmap

This roadmap tracks the current state, lessons learned, current focus, and future improvements for my homelab.

The README gives a quick overview of the project. This file is more detailed and helps me keep the lab organized as it grows.

## Practical experience built

This project helped me build practical experience in:

* Linux server administration
* virtualization with Proxmox
* Docker Compose service deployment
* reverse proxy and TLS management
* DNS, DHCP, VPN, firewall, and routing concepts
* storage and backup planning with TrueNAS and Proxmox Backup Server
* monitoring and uptime checks
* security-aware self-hosting
* technical documentation
* troubleshooting services systematically
* explaining technical infrastructure clearly

## Concrete lessons

* Troubleshooting is easier when I check one layer at a time: DNS, firewall, reverse proxy, backend service, logs, and host resources.
* Backups are only useful if recovery is planned and tested.
* Publicly exposing admin interfaces is not worth the risk; VPN-first access is safer for internal services.
* Documentation helps avoid repeating the same investigation when an issue comes back later.
* Separating implemented, planned, and experimental components prevents overclaiming and makes the project easier to explain.
* Copying only Compose files and `.env` files is not always enough for database-backed services.
* A service can start successfully but still not be fully restored if the application data is missing.

## Done or documented

* Linux homelab architecture
* Proxmox, TrueNAS, Docker, and backup roles
* Docker Compose service layout
* DNS filtering with Pi-hole and Unbound
* Git workflow
* Security notes
* Backup strategy
* Troubleshooting overview
* Service documentation checklist
* Uptime Kuma cold restore test
* README cleanup and documentation consistency improvements

## Improving now

* practical MariaDB administration skills
* practical Apache administration skills
* LPIC-1 preparation
* more restore tests
* per-service backup notes
* MariaDB backup and restore notes
* sanitized Docker Compose examples
* firewall rule documentation
* service dependency notes
* monitoring and alerting notes
* keeping documentation clear and consistent

## Next

* expand backup and restore testing
* publish more sanitized configuration examples
* improve monitoring and alerting examples
* keep internal services behind VPN-style access
* harden intentionally exposed services
* plan VLAN-based segmentation with managed switch hardware
* reduce pfSense service coupling
* evaluate Pi-hole for DNS filtering
* improve reverse proxy and ACME workflow outside pfSense
* build a clean portfolio of practical Linux and networking projects

## Future plans and learning goals

These are things I want to learn or improve as the lab becomes more mature.

The goal is to build better habits over time: safer changes, tested recovery, clearer documentation, better monitoring, and more repeatable infrastructure.

- automate repeatable Linux server setup with Ansible
- add restore tests for every important service
- document a simple disaster recovery plan
- add centralized logging for easier troubleshooting
- improve firewall zone documentation
- separate management, servers, clients, IoT, and guests with VLANs
- improve patching notes with rollback steps
- document service dependencies more clearly
- improve Linux hardening notes
- write short incident notes after real problems
- track storage, backup, and resource growth
- improve secrets handling beyond plain `.env` files
- test changes in a temporary environment before using them live
- learn proper database backup and restore for MariaDB and PostgreSQL
- improve infrastructure automation step by step
- add simple checks for scripts, Compose files, YAML, Markdown, and secrets

## Notes

This roadmap is a work in progress.

I update it as I complete tasks, improve existing documentation, and plan future lab improvements. The goal is to keep the lab understandable, recoverable, and useful for learning real Linux system administration habits.

