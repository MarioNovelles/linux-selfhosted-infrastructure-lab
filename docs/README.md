# Documentation

This folder contains the main documentation for the self-hosted infrastructure lab.

It includes architecture notes, firewall policy notes, runbooks, restore tests, troubleshooting notes, and case studies.

## Architecture and Policy Notes

- [Architecture overview and design decisions](./architecture.md) — documents the lab roles, Proxmox and TrueNAS split, service placement, storage approach, backup assumptions, and major trade-offs.
- [Docker Compose architecture plan](./docker-compose-architecture.md) — planned long-term structure for Docker Compose services.
- [Firewall policy notes](./firewall-policy.md) — sanitized firewall rule intent, DNS enforcement, remote access policy, and IPv6 notes.

## Runbooks

- [Linux service troubleshooting checklist](./runbooks/linux-service-troubleshooting-checklist.md) — repeatable checklist for investigating Linux service issues.
- [Git workflow](./runbooks/git-workflow.md) — basic Git workflow used for reviewing, committing, and pushing repository changes.
- [Cloudflare DDNS for WireGuard remote access](./runbooks/cloudflare-ddns-wireguard.md) — dynamic DNS approach used earlier for WireGuard access before CGNAT.
- [Tailscale subnet router failover](./runbooks/tailscale-subnet-router-failover.md) — second Tailscale subnet router on `ubuntu-docker` for LAN access redundancy.

## Case Studies

- [Service unreachable troubleshooting flow](./case-studies/service-unreachable-troubleshooting.md) — sanitized troubleshooting case study for diagnosing an unreachable service.

## Troubleshooting

* [General troubleshooting notes](./troubleshooting.md) — general approach for investigating Linux, Docker, DNS, and service issues.
* [GRUB failed systemd unit](./troubleshooting/grubenv-systemd-failed-unit.md) — real lab troubleshooting note for a failed `grub2-common.service` unit caused by a corrupted GRUB environment block.

## Related Repository Sections

- [DNS filtering notes](../dns-filtering/README.md)
- [Maintenance scripts](../scripts/README.md)
- [Sanitized examples](../examples/README.md)

## Notes

Documentation in this folder is intentionally sanitized. It does not publish real internal IP addresses, public IP addresses, credentials, private domains, firewall exports, VPN endpoints, or production configuration values.

