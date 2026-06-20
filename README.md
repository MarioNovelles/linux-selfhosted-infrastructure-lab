# Linux Self-Hosted Infrastructure Lab

Practical self-hosted infrastructure lab focused on Linux administration, networking, virtualization, Docker-based services, firewalls, DNS, VPN access, reverse proxies, backups, monitoring, and troubleshooting.

> **Security note:** > This repository intentionally omits or redacts sensitive details such as public IP addresses, real domains, credentials, private keys, full firewall rules, secrets, and production configuration values. Some documents use sanitized example IP addresses when they help explain the setup.


---

## Summary

This repository documents a private, self-managed infrastructure environment that I use to build hands-on skills relevant to IT support, Linux system administration, networking, infrastructure operations, and self-hosted service management.

This lab is built around practical infrastructure work, not just running applications. I use it to practice installing, maintaining, documenting, and troubleshooting Linux-based services in a realistic home and small-business-style environment.

The current lab includes Linux servers, Proxmox virtualization, TrueNAS storage, Proxmox Backup Server, Docker Compose services, Cloudflare DNS, Tailscale VPN-style access, monitoring, VoIP, local AI experimentation, and pfSense as the central edge firewall/router platform.

pfSense handles routing, firewalling, DHCP, pfBlockerNG DNS/IP filtering fallback, Suricata IDS/IPS visibility, and selected edge services. DNS is being decoupled into a dedicated Pi-hole + Unbound resolver, with pfSense and pfBlockerNG kept as a fallback DNS filtering path because DNS is critical infrastructure. Docker-based services are being moved toward a dedicated Traefik reverse proxy layer instead of relying only on pfSense HAProxy.

Some components are implemented, some were previously tested, and others are planned or being improved. The goal of this repository is to show practical learning, structured troubleshooting, security awareness, and documentation habits without publishing sensitive configuration details.

---

## What This Demonstrates

This project demonstrates practical experience with:

- Installing and maintaining Linux server environments
- Running self-hosted services with Docker Compose
- Managing reverse proxy access with Traefik and previously pfSense HAProxy
- Managing DNS, DHCP, recursive DNS, filtering, and ACME/TLS certificate workflows
- Operating pfSense-based firewalling, DHCP, pfBlockerNG fallback DNS/IP filtering, Suricata visibility, ACME certificate workflows, and previous HAProxy reverse proxy routing
- Designing DNS redundancy with Pi-hole + Unbound as the primary resolver and pfSense + pfBlockerNG as the fallback DNS path
- Using VPN tools for secure remote access
- Working with Proxmox VE, Proxmox Backup Server, and TrueNAS
- Troubleshooting Linux services, containers, DNS, firewall, and connectivity issues
- Planning backups and recovery workflows
- Documenting infrastructure decisions clearly

---

## Repository Status

This repository is a portfolio and documentation project.

| Status | Meaning |
|---|---|
| Implemented | Currently running or previously built/tested in my lab |
| In progress | Being configured, documented, or improved |
| Planned | Studied or planned, but not yet fully implemented |
| Omitted | Not included in this repository or not relevant to this version |

---

## High-Level Architecture

The lab is organized around separate infrastructure roles: routing/firewalling, virtualization, storage, backups, application services, monitoring, VoIP, and experimentation.

![Home Lab Architecture Overview](./docs/images/home-lab-architecture-overview-public-version.png)

The diagram above is a sanitized public overview. It avoids real domains, IP addresses, credentials, exact firewall rules, and sensitive internal details.

For the detailed topology, service placement, storage design, and architecture trade-offs, see [Architecture](./docs/architecture.md).

<pre>
Internet
   |
   v
Firewall / Router
(pfSense)
   |
   +-- OpenWrt access point
   |     - Main Wi-Fi
   |     - Separate guest Wi-Fi
   |
   v
Home / lab network
   |
   v
Planned managed VLAN switch
(not currently deployed)
   |
   +-- Virtualization host
   |     - Linux VMs
   |     - Docker services
   |     - Monitoring services
   |
   +-- Storage server
   |     - File storage
   |     - Snapshots
   |     - Backup targets
   |
   +-- Backup server
   |     - VM/container backups
   |     - Restore points
   |
   +-- VoIP server
   |
   +-- AI / experimentation node
   |
   +-- Lightweight nodes
         - DNS filtering / fallback services
         - Sensors / testing
</pre>

---

## Repository Navigation

This repository has grown into several sections. The structure below helps locate documentation, scripts, runbooks, and sanitized service examples more quickly.

* [`README.md`](./README.md) — main overview of the lab
* [`dns-filtering/`](./dns-filtering/README.md) — DNS filtering notes, blocklists, allowlists, regex rules, and DNS enforcement notes
  * [`pihole-unbound-recursive-dns.md`](./dns-filtering/pihole-unbound-recursive-dns.md)
  * [`blocklists.md`](./dns-filtering/blocklists.md)
  * [`allowlists.md`](./dns-filtering/allowlists.md)
  * [`regex.txt`](./dns-filtering/regex.txt)
  * [`encrypted-dns-providers.txt`](./dns-filtering/encrypted-dns-providers.txt)
  * [`ip-blocklists.md`](./dns-filtering/ip-blocklists.md)
  * [`dns-redirect.md`](./dns-filtering/dns-redirect.md)
* [`docs/`](./docs/README.md) — general documentation, architecture notes, runbooks, security notes, and case studies
  * [`architecture.md`](./docs/architecture.md) — high-level lab architecture
  * [`docker-compose-architecture.md`](./docs/docker-compose-architecture.md) — Docker Compose layout, `/srv/docker` structure, and ownership model
  * [`backup-strategy.md`](./docs/backup-strategy.md) — backup planning and restore strategy
  * [`firewall-policy.md`](./docs/firewall-policy.md) — firewall policy notes
  * [`security.md`](./docs/security.md) — security and hardening notes
  * [`services.md`](./docs/services.md) — service inventory and service notes
  * [`troubleshooting.md`](./docs/troubleshooting.md) — general troubleshooting notes
  * [`case-studies/`](./docs/case-studies/) — documented troubleshooting and infrastructure case studies
    * [`service-unreachable-troubleshooting.md`](./docs/case-studies/service-unreachable-troubleshooting.md)
  * [`runbooks/`](./docs/runbooks/) — repeatable administration procedures
    * [`cloudflare-ddns-wireguard.md`](./docs/runbooks/cloudflare-ddns-wireguard.md)
    * [`docker-compose-migration.md`](./docs/runbooks/docker-compose-migration.md)
    * [`git-workflow.md`](./docs/runbooks/git-workflow.md)
    * [`linux-command-line-workflow.md`](./docs/runbooks/linux-command-line-workflow.md)
    * [`linux-service-troubleshooting-checklist.md`](./docs/runbooks/linux-service-troubleshooting-checklist.md)
  * [`proxmox/`](./docs/proxmox/) — Proxmox VE installation and virtualization notes
    * [`01-install-proxmox-ve.md`](./docs/proxmox/01-install-proxmox-ve.md)
    * [`02-install-ubuntu-vm.md`](./docs/proxmox/02-install-ubuntu-vm.md)
    * [`03-enable-amd64v3-packages.md`](./docs/proxmox/03-enable-amd64v3-packages.md)
    * [`04-install-neovim-lazyvim.md`](./docs/proxmox/04-install-neovim-lazyvim.md)
  * [`images/`](./docs/images/) — architecture diagrams and supporting visuals
* [`examples/`](./examples/README.md) — sanitized example configurations and service examples
  * [`traefik/`](./examples/traefik/README.md) — Traefik reverse proxy example with `whoami` validation and Uptime Kuma routing
    * [`compose.example.yml`](./examples/traefik/compose.example.yml)
    * [`.env.example`](./examples/traefik/.env.example)
    * [`whoami.example.yml`](./examples/traefik/whoami.example.yml)
  * [`uptime-kuma/`](./examples/uptime-kuma/README.md) — Uptime Kuma monitoring example with embedded and external MariaDB variants
    * [`compose.embedded-mariadb.example.yml`](./examples/uptime-kuma/compose.embedded-mariadb.example.yml)
    * [`compose.external-mariadb.example.yml`](./examples/uptime-kuma/compose.external-mariadb.example.yml)
    * [`.env.example`](./examples/uptime-kuma/.env.example)
  *  More examples are planned and will be added when they are tested and documented.
* [`scripts/`](./scripts/README.md) — maintenance and administration scripts
  * [`update-laptop.sh`](./scripts/update-laptop.sh)
  * [`update-ubuntu-server.sh`](./scripts/update-ubuntu-server.sh)
  * [`start-jellyfin.sh`](./scripts/start-jellyfin.sh)
  * [`system/lab-login-summary.sh`](./scripts/system/lab-login-summary.sh)
* [`.gitignore`](./.gitignore) — prevents secrets, local Compose files, runtime data, and sensitive files from being committed

---

## Infrastructure Components and Platforms

This section lists the infrastructure building blocks: platforms, network/security components, deployment tooling, storage, backup, and edge services. Application workloads are listed separately below. The table is ordered roughly from the network edge and access layer through virtualization, storage, deployment tooling, and planned decoupling experiments.

| Component | Status | Purpose | Notes |
|---|---|---|---|
| pfSense | Implemented | Edge firewall/router and DHCP platform | Central platform for routing, firewalling, DHCP, pfBlockerNG fallback DNS/IP filtering, Suricata visibility, and selected edge services |
| pfBlockerNG | Implemented | Fallback DNS/IP filtering | Kept active in pfSense as a fallback DNS filtering path if the primary Pi-hole resolver is unavailable |
| HAProxy | Previously implemented | Reverse proxy | Previously managed through the pfSense HAProxy package; Docker services are being moved toward Traefik to reduce reverse proxy coupling to pfSense |
| Pi-hole | In progress | Primary DNS filtering and local DNS | Dedicated DNS VM planned/being configured as the primary resolver and local DNS layer |
| Unbound | In progress | Recursive DNS resolver | Used with Pi-hole so DNS queries are resolved recursively instead of forwarded to public upstream resolvers |
| Traefik | In progress | Docker reverse proxy | Used as the dedicated reverse proxy layer for Docker services, validated with whoami and Uptime Kuma routing |
| Suricata | Implemented | IDS/IPS visibility | Managed through pfSense for traffic alerts and security monitoring |
| ACME / Let's Encrypt | Implemented | TLS certificates | Managed through the pfSense ACME package; future improvement is evaluating a dedicated ACME workflow outside pfSense |
| OpenWrt | Implemented | Wireless access point role | Used as a dumb WAP with main Wi-Fi and separate guest Wi-Fi |
| Cloudflare DNS | Implemented | DNS and domain management | Used for DNS/domain routing |
| Tailscale | Implemented | VPN-style remote access | Used because the current connection is behind CGNAT |
| WireGuard | Previously implemented | VPN access | Used in the past; currently less central because of CGNAT |
| Proxmox VE | Implemented | Virtualization platform | Used for virtualized services and lab systems |
| TrueNAS | Implemented | Storage platform | Used for storage and snapshots |
| Proxmox Backup Server | Implemented | Backup and restore platform | Used for VM/container backup workflows |
| Docker | Implemented | Container runtime | Used for self-hosted services |
| Docker Compose | Implemented | Service deployment | Used to define and operate multi-container services |
| Headscale | Planned | Self-hosted Tailscale control server | Planned for future experimentation |

---

## Self-Hosted Applications and Workloads

This section lists the applications and service-like workloads that run on top of the infrastructure components above. The table is grouped by purpose: productivity/data, web/information services, monitoring, media, communication, AI/automation experimentation, and planned applications.

| Workload | Status | Purpose |
|---|---|---|
| Nextcloud | Implemented | File access and collaboration |
| Syncthing | Implemented | File synchronization |
| Vaultwarden | Implemented | Password manager service |
| Joplin | Implemented | Notes / documentation workflow |
| WordPress | Implemented | Web hosting practice |
| SearXNG | Implemented | Self-hosted search |
| Uptime Kuma | Implemented | Uptime and availability monitoring |
| Grafana | Implemented | Monitoring dashboards and metrics visualization |
| Prometheus | Implemented | Metrics collection |
| Jellyfin | Implemented | Media service |
| Jellyseerr | Implemented | Media request workflow |
| Navidrome | Implemented | Music streaming |
| Audiobookshelf | Implemented | Audiobook management |
| Calibre-Web | Implemented | E-book library |
| Media-related services | Implemented | Used to practice container management, storage paths, permissions, service dependencies, and troubleshooting |
| FreePBX | Implemented | VoIP server and telephony experimentation |
| Ollama | Implemented | Local AI experimentation |
| Open WebUI | Implemented | Local AI web interface for Ollama |
| OpenClaw | Previously implemented | Agentic AI experimentation |
| Hermes Agent | Implemented | Local agentic automation experimentation |
| Immich | Planned | Photo management |
| Home Assistant | Planned | Smart home automation |

---

## Network Design

The current network uses pfSense and OpenWrt-based components. OpenWrt provides wireless access point functionality, while pfSense handles firewall/router duties.

In this setup, pfSense also manages several edge and security services through packages: pfBlockerNG for DNS/IP filtering, Suricata for IDS/IPS visibility, ACME for Let's Encrypt certificate workflows, and HAProxy for reverse proxy routing.

### DNS Redundancy

DNS is treated as critical infrastructure in this lab.

The primary DNS path is being moved to a dedicated Pi-hole + Unbound DNS VM. Pi-hole provides DNS filtering, query visibility, and local DNS records, while Unbound provides recursive DNS resolution without relying on public forwarders.

pfSense with pfBlockerNG DNSBL remains active as a fallback DNS resolver. This avoids making DNS dependent on a single VM and keeps DNS filtering available during Pi-hole maintenance or failure.

```text
Primary DNS:   Pi-hole + Unbound
Fallback DNS:  pfSense DNS Resolver + pfBlockerNG DNSBL
```

As a future improvement, I want to reduce how many supporting services are tightly coupled to pfSense. The goal is to keep pfSense focused on routing, firewalling, and edge security, while moving some service-level functions to dedicated hosts or VMs where appropriate. This includes evaluating Pi-hole for DNS filtering and evaluating a dedicated reverse proxy / certificate workflow, for example with Traefik or a Linux-hosted HAProxy and ACME setup.

VLAN-based segmentation is planned for the next stage after adding a managed switch. The planned design separates different types of systems into logical zones instead of treating the whole network as one flat environment.

Planned or designed network zones:

| Zone | Purpose | Status |
|---|---|---|
| Management | Infrastructure administration interfaces | Planned |
| Trusted LAN | Personal trusted devices | Planned |
| Servers | Self-hosted application services | Planned |
| Storage | NAS/storage and backup traffic | Planned |
| IoT | Less trusted smart devices | Planned |
| Cameras | Camera/security devices | Planned |
| VoIP | FreePBX and phone-related traffic | Planned |
| AI / Experimental | AI and lab/testing workloads | Planned |
| Guest | Guest access | Planned |
| Backup | Backup and recovery traffic | Planned |

The intended design follows a least-privilege mindset: administrative interfaces should not be exposed publicly, and access between zones should only be allowed where needed.

Example allowed traffic patterns, expressed generically:

- Admin workstation to infrastructure management interfaces
- Virtualization host to storage/backup services
- VPN clients to selected internal services
- Monitoring system to service health endpoints
- VoIP devices to the VoIP server

Exact firewall rules, internal addresses, and real network details are intentionally not published.

To avoid VPN routing conflicts, the home network was moved away from very common private ranges such as `192.168.1.0/24` to a less common private subnet. The exact subnet is intentionally not published.

### Wi-Fi and Guest Network

Wireless access is provided through an OpenWrt router configured as a dumb wireless access point.

The access point provides:

- Main Wi-Fi for trusted devices
- Separate guest Wi-Fi for visitors
- Guest access intended to reduce exposure of trusted devices and internal services
- Central routing/firewall handling through pfSense

The guest Wi-Fi is documented at a high level only. Real SSIDs, passwords, MAC addresses, internal addressing, and exact access rules are intentionally not published.

### Client and Endpoint Devices

The lab also includes different types of client and endpoint devices, because troubleshooting and network design are not only server-side tasks.

Endpoint types include:

| Endpoint Type | Purpose | Notes |
|---|---|---|
| Desktop workstation | Main administration and daily-use system | Used for SSH access, documentation, Git workflows, testing, and service administration |
| Laptop | Mobile client and secondary admin device | Used for testing access from another client and working from different network locations |
| Smartphone | Mobile access and user-device testing | Useful for checking VPN access, mobile web access, notifications, and real user behavior |
| Road warrior / remote access devices | Trusted remote laptop, smartphone, or tablet access | Connect back to selected internal services through VPN-style access, currently mainly Tailscale because of CGNAT |
| IoT / smart devices | Less trusted endpoint category | Intended to be separated more clearly with future VLAN-based segmentation |
| Guest devices | Visitor access | Intended to stay separated from trusted devices and internal services |
| VoIP clients / phones | Telephony endpoint category | Related to FreePBX and planned VoIP network separation |

Road warrior devices, also called remote access devices in this lab, are trusted remote clients such as laptops, smartphones, or tablets that connect back to selected internal services through VPN-style access. In the current setup, Tailscale is used for this because the internet connection is behind CGNAT, while WireGuard was previously used. These devices are treated differently from local trusted LAN clients because they may connect from external or less trusted networks.

The goal is to treat different endpoint types according to their trust level. Administrative systems, trusted personal devices, guest clients, IoT devices, and VoIP devices should not all have the same level of access to internal services.

At the moment, this is documented at a high level only. Real device names, MAC addresses, SSIDs, user information, internal addresses, and exact access rules are intentionally not published.

---

## Main Technologies

### Linux and Platforms

- Debian
- Ubuntu Server
- Proxmox VE
- Proxmox Backup Server
- TrueNAS
- Raspberry Pi OS

### Networking and Security

- pfSense as the edge firewall/router platform
- pfSense packages: pfBlockerNG, Suricata, ACME, and HAProxy
- OpenWrt
- DHCP
- DNS
- pfBlockerNG
- Tailscale
- WireGuard
- Firewall policy design
- SSH hardening
- TLS certificates
- Cloudflare DNS
- ACME / Let's Encrypt
- HAProxy
- Suricata
- Basic defensive security lab practice with Kali Linux, nmap, Wireshark, and authorized network/service exposure checks
- Pi-hole
- Unbound recursive DNS
- Redundant DNS resolver design

### Containers and Services

- Docker
- Docker Compose
- Uptime Kuma
- Grafana
- Prometheus
- Nextcloud
- Syncthing
- Vaultwarden
- Joplin
- Jellyfin
- SearXNG
- Ollama
- Open WebUI
- FreePBX
- Traefik

### Administration and Troubleshooting Tools

- systemd
- journalctl
- cron
- SSH key-based administration / scp / rsync
- Bash scripting
- ping
- dig
- nslookup
- traceroute
- nmap
- tcpdump
- Wireshark

---

## What I Built

- Installed and maintained Linux server environments
- Deployed self-hosted applications using Docker Compose
- Configured reverse proxy access for multiple services using the pfSense HAProxy package
- Managed DNS records and domain routing through Cloudflare
- Managed TLS certificates using the pfSense ACME package / Let's Encrypt workflows
- Configured VPN-style remote access using Tailscale and previously WireGuard
- Configured routing, DHCP/DNS, DNS/IP filtering with pfBlockerNG, Suricata visibility, firewall concepts, and service access rules with pfSense
- Used OpenWrt as a wireless access point
- Built and operated storage workflows with TrueNAS and snapshots
- Used Proxmox VE for virtualization and Proxmox Backup Server for backup workflows
- Used Uptime Kuma, Grafana, and Prometheus for monitoring and visibility
- Used logs, service status checks, and network tools to troubleshoot problems
- Created simple Bash scripts for maintenance tasks
- Documented service roles, architecture decisions, and recovery planning
- Designed a redundant DNS filtering setup with Pi-hole + Unbound as the primary DNS path and pfSense + pfBlockerNG as fallback
- Began decoupling reverse proxy routing from pfSense by deploying Traefik for Docker-based services
- Validated Docker reverse proxy routing with Traefik, a whoami test service, and Uptime Kuma

---

## Backup and Recovery Strategy

The backup design separates service recovery, file recovery, configuration recovery, and disaster recovery.

| Backup Layer | Purpose | Status |
|---|---|---|
| Proxmox Backup Server | VM/container backup and restore workflows | Implemented |
| TrueNAS snapshots | Local rollback for storage datasets | Implemented |
| Exported configuration backups | Recovery of pfSense, TrueNAS, Docker, and application configurations | Implemented |
| Offsite encrypted backups | Protection for important small files and configuration data | Implemented for selected critical data |
| Offline backup media | Protection against ransomware or accidental deletion | Planned |
| Restore testing | Verification that backups can actually be restored | Planned |

### Data Priority

| Data Type | Backup Priority |
|---|---|
| Password vault, documents, photos, configuration files | Critical |
| Service databases and application configs | High |
| Media metadata and application state | Medium |
| Temporary files, caches, transcodes, generated data | Low / disposable |

The long-term goal is not only to create backups, but to test restores and document recovery steps.

---

## Security Practices

Security is treated as a core design goal in this self-managed lab.

Implemented practices include:

- VPN-first access model for internal and administrative services
- No public exposure of firewall, NAS, hypervisor, or backup administration interfaces
- SSH key-based administration for server access where appropriate
- Password-based SSH login disabled or reduced on managed Linux hosts, with continued hardening in progress
- TLS certificates for web services
- DNS/IP filtering with pfBlockerNG managed in pfSense
- Password manager usage
- Suricata IDS/IPS visibility through pfSense
- Regular review of exposed ports and service access
- Sensitive values excluded from public documentation

Planned or improving practices:

- Stronger segmentation with VLANs after adding managed switch hardware
- More systematic firewall zone documentation
- Offline backup media
- Formalized backup restore testing
- More sanitized configuration examples
- Reducing service coupling by evaluating Pi-hole for DNS filtering and a dedicated reverse proxy / ACME workflow outside pfSense

---

## Monitoring and Troubleshooting

Monitoring and troubleshooting are handled with service checks, logs, dashboards, and network tools.

Typical checks include:

- Firewall/router reachability
- Proxmox host reachability
- TrueNAS availability
- DNS health
- Internet connectivity
- Backup server availability
- Service uptime
- Reverse proxy status
- TLS certificate status
- VoIP service availability

Typical troubleshooting commands:

<pre>
systemctl status &lt;service&gt;
journalctl -u &lt;service&gt;
docker ps
docker compose logs
dig example.com
ping 1.1.1.1
traceroute example.com
nmap -sV &lt;host&gt;
tcpdump -i &lt;interface&gt;
</pre>

### Troubleshooting Examples

These examples are generalized and sanitized.

#### DNS filtering / resolution issue

When DNS filtering or name resolution does not behave as expected, I check the client DNS settings, pfSense/pfBlockerNG configuration, upstream resolver behavior, and command-line output from tools such as `dig` and `nslookup`. This helps separate client-side issues from firewall/DNS resolver issues.

#### Reverse proxy or TLS issue

When a self-hosted service is not reachable through its domain, I check DNS records, Cloudflare settings, HAProxy frontend/backend routing, certificate status, service availability, and firewall exposure. This makes it possible to identify whether the failure is caused by DNS, TLS, reverse proxy configuration, or the backend service itself.

#### Docker service failure

When a containerized service fails or becomes unavailable, I check `docker ps`, `docker compose logs`, exposed ports, volumes, environment configuration, restart policies, and the underlying host resources. I also verify whether the service itself is failing or whether the reverse proxy or network path is the actual problem.

#### VPN / CGNAT access change

After moving behind CGNAT, direct inbound access became less practical. I adapted the remote-access approach by using Tailscale for VPN-style access to internal services instead of relying only on direct port forwarding.

#### Backup and restore planning

For important services and configuration data, I separate VM/container backups, storage snapshots, exported configuration backups, and selected offsite encrypted backups. The next improvement is formal restore testing and documented recovery steps.

---

## Documentation Practices

This repository is intended to document infrastructure decisions in a clear and professional way.

Documentation included or planned:

- Architecture overview
- Network segmentation plan
- Service placement table
- Backup strategy
- Recovery checklist
- Sanitized Docker Compose examples
- Sanitized reverse proxy examples
- Troubleshooting notes
- Change log for major infrastructure changes

Planned documentation files:

<pre>
docs/
  architecture.md
  services.md
  backup-strategy.md
  troubleshooting.md
  security.md
</pre>

---

## Sanitized Examples

This repository may include sanitized examples of configuration patterns, but not live production configuration.

Planned examples:

<pre>
examples/
  docker-compose-redacted.yml
  reverse-proxy-redacted.cfg
  backup-checklist.md
</pre>

All examples should remove or replace:

- real domains
- credentials
- tokens
- public IP addresses
- private keys
- exact internal addresses
- exact production firewall rules
- unredacted `.env` files

---

## What I Learned

This project helped me build practical experience in:

- Linux server administration
- Virtualization with Proxmox
- Docker Compose service deployment
- Reverse proxy and TLS management
- DNS, DHCP, VPN, firewall, and routing concepts
- Storage and backup planning with TrueNAS and Proxmox Backup Server
- Monitoring and uptime checks
- Security-aware self-hosting
- Technical documentation
- Troubleshooting services systematically
- Explaining technical infrastructure to non-technical users

Concrete lessons:

- Troubleshooting is easier when checking one layer at a time: DNS, firewall, reverse proxy, backend service, logs, and host resources.
- Backups are only useful if recovery is planned and tested.
- Publicly exposing admin interfaces is not worth the risk; VPN-first access is safer for internal services.
- Documentation helps avoid repeating the same investigation when an issue comes back later.
- Separating implemented, planned, and experimental components prevents overclaiming and makes the project easier to explain.

---

## Current Focus

* Strengthening practical MariaDB and Apache administration skills
* Preparing for LPIC-1
* Improving infrastructure documentation
* Expanding backup and restore testing
* Publishing sanitized configuration examples
* Improving monitoring and alerting
* Keeping internal services behind VPN-style access and hardening intentionally exposed services
* Planning VLAN-based segmentation with managed switch hardware
* Reducing pfSense service coupling by evaluating Pi-hole for DNS filtering and a dedicated reverse proxy / ACME workflow outside pfSense
* Building a clean portfolio of practical Linux and networking projects

