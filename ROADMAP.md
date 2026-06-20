# Roadmap

This file tracks the current state and next improvements of the lab.

The README explains what the project is and what I learned. This roadmap is more practical: what is already documented, what I am improving now, and what I want to work on next.

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

## Improving now

* more restore tests
* per-service backup notes
* MariaDB backup and restore notes
* sanitized Docker Compose examples
* firewall rule documentation
* service dependency notes
* README and documentation consistency

## Next

* VLAN separation after managed switch setup
* monitoring notes with clearer alerting examples
* off-site or offline backup for the most important data
* simple checks for scripts, Compose files, Markdown, YAML, and secrets
* more restore examples for database-backed services
* cleaner reverse proxy / ACME workflow outside pfSense

## Future plans and learning goals

These are things I want to learn or improve as the lab becomes more mature.

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

## Notes

This roadmap is a work in progress. I update it as I complete tasks, improve existing documentation, and plan future lab improvements.
