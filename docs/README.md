# Documentation

This folder contains general documentation for the self-hosted infrastructure lab.

It includes architecture notes, firewall policy notes, runbooks, and troubleshooting case studies. The goal is to document the reasoning behind the lab setup, not just the final configuration.

## Architecture and Policy Notes

- [Docker Compose architecture plan](./docker-compose-architecture.md) — planned long-term structure for Docker Compose services
- [Firewall policy notes](./firewall-policy.md) — sanitized firewall rule intent, DNS enforcement, remote access policy, and IPv6 notes

## Runbooks

- [Linux service troubleshooting checklist](./runbooks/linux-service-troubleshooting-checklist.md) — repeatable checklist for investigating Linux service issues
- [Git workflow](./runbooks/git-workflow.md) — basic Git workflow used for reviewing, committing, and pushing repository changes

## Case Studies

- [Service unreachable troubleshooting flow](./case-studies/service-unreachable-troubleshooting.md) — sanitized troubleshooting case study for diagnosing an unreachable service

## Notes

Documentation in this folder is intentionally sanitized. It does not publish real internal IP addresses, public IP addresses, credentials, private domains, firewall exports, VPN endpoints, or production configuration.

