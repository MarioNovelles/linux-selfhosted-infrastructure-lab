# Linux Service Troubleshooting Checklist

A practical, sanitized runbook for investigating a Linux service that is slow, unhealthy, or unreachable.

This checklist is based on self-managed Linux infrastructure lab practice. It is not a production outage report and does not claim professional production administrator experience. It is written to show a structured troubleshooting approach for Linux, Docker Compose, DNS, firewall, reverse proxy, TLS, and storage-related service issues.

## Purpose and Scope

Use this runbook when a service such as `<service>` cannot be reached at `https://service.example.invalid`, returns errors, fails a monitoring check, or behaves differently from the expected access path.

It is intended for services that may involve:

- Linux hosts managed with systemd
- Docker Compose applications
- HAProxy through the pfSense HAProxy package
- DNS records managed externally or internally
- TLS certificates managed through the pfSense ACME package / Let's Encrypt workflow
- pfSense firewalling, pfBlockerNG filtering, and Suricata alerts
- VPN-only, internal-only, or public access paths
- Storage mounts, backups, and restore planning

The goal is to identify the failed layer before changing anything. Avoid restarting random services as the first step unless there is a clear reason and the current state has already been captured.

## Quick Triage

Start by writing down the current symptoms.

Questions to answer first:

- What is failing: DNS lookup, connection, TLS, HTTP response, login, or the application itself?
- Is the problem visible from one client only or from multiple clients?
- Does it fail from public internet, VPN, internal network, or all paths?
- Did monitoring report the start time?
- Is the service supposed to be public, VPN-only, or internal-only?
- Has anything changed recently?

Useful first checks:

```bash
curl -I https://service.example.invalid
curl -vk https://service.example.invalid
ping service.example.invalid
traceroute service.example.invalid
```

Notes:

- `ping` is only a rough reachability check. ICMP may be blocked while HTTPS still works.
- `curl -I` helps identify HTTP status such as 301, 401, 403, 502, 503, or timeout.
- `curl -vk` can show TLS handshake and certificate problems without exposing secrets.

## Recent Changes Check

Before making fixes, check whether the problem started after a change.

Look for:

- Service deployment or container image update
- Edited `docker-compose.yml` or environment file
- DNS record change
- Firewall, NAT, pfBlockerNG, or Suricata rule/change
- HAProxy frontend/backend change
- TLS certificate renewal or ACME account issue
- Host reboot or package update
- Storage mount, TrueNAS dataset, or backup target issue
- Disk space or permission change
- Monitoring alert timeline from Uptime Kuma, Grafana, or Prometheus

Generic local checks:

```bash
date
uptime
systemctl list-units --failed
docker compose ps
docker image ls
docker compose config
```

If the service has a deployment directory, check file timestamps without exposing file contents:

```bash
ls -lt
```

Do not paste real `.env` values, tokens, domains, addresses, or credentials into public notes.

Note: I use `docker compose config` and `docker inspect` for local troubleshooting only. Their output can contain environment values, internal paths, labels, hostnames, or other sensitive details, so I do not paste raw output into public documentation.

## systemd Checks

Use this section for services managed directly by systemd, or for host services that support the application, such as Docker, networking, SSH, cron, mount units, or other Linux host services.

```bash
systemctl status <service>
systemctl is-enabled <service>
systemctl list-units --failed
journalctl -u <service> --since "1 hour ago"
journalctl -xe
```

Check for:

- Service stopped or failed
- Restart loops
- Permission errors
- Missing files or paths
- Failed dependencies
- Errors after reboot or package update
- Host networking or storage mount failures

If a restart is needed, first capture enough state to understand what changed:

```bash
systemctl status <service>
journalctl -u <service> --since "1 hour ago"
```

Then restart only the affected service if appropriate:

```bash
sudo systemctl restart <service>
```

After restarting, verify the service, logs, and external behavior again.

## journalctl and Log Checks

Logs usually explain more than a browser error.

For systemd services:

```bash
journalctl -u <service> --since "30 minutes ago"
journalctl -u <service> --since today
```

For general host issues:

```bash
journalctl -p warning..alert --since "1 hour ago"
sudo dmesg -T | tail -50
```

Look for:

- Authentication failures
- Permission denied messages
- Bind/listen errors
- Missing files or directories
- Failed database connections
- Certificate load errors
- Storage or mount errors
- Kernel, disk, or network interface warnings

When writing public documentation, summarize the type of error instead of copying sensitive paths, domains, usernames, tokens, or internal addresses.

## Port and Listening Checks

Confirm whether the service is listening where expected.

```bash
ss -tulpn
ss -tulpn | grep <backend-port>
curl -I http://localhost:<backend-port>
curl -I http://<host>:<backend-port>
```

Optional network scan from another trusted machine:

```bash
nmap -Pn -p 80,443,<backend-port> <host>
```

Check for:

- Service not listening
- Service listening only on localhost when remote access is expected
- Wrong port after a configuration change
- Port conflict with another process
- Firewall path blocked even though the service is listening
- Backend reachable locally but not through reverse proxy

Avoid publishing real open-port lists for private systems. Use placeholders and explain the troubleshooting logic.

## DNS Checks

DNS should be checked before assuming the service or container is broken.

```bash
dig service.example.invalid
nslookup service.example.invalid
dig @<public-dns-resolver> service.example.invalid
dig @<internal-or-vpn-dns-resolver> service.example.invalid
```

Check for:

- Name does not resolve
- Record points to the wrong target
- Stale result after a recent DNS change
- Split DNS difference between internal, VPN, and public networks
- Local DNS filtering affecting only one client or network
- External DNS provider record mismatch

Useful questions:

- Should `service.example.invalid` resolve publicly, internally, or only over VPN?
- Is the expected record type A, AAAA, CNAME, or something else?
- Is IPv6 involved, and does it point somewhere different from IPv4?
- Is the client using the intended DNS resolver?

Do not document real domains, public IP addresses, private ranges, or provider account details.

## Firewall, pfSense, pfBlockerNG, and Suricata Checks

Use pfSense and related tools to confirm whether traffic is allowed along the intended path. Do this through the Web UI, logs, and reports rather than publishing exact live firewall rules.

Check in pfSense Web UI/logs:

- Firewall logs for blocked traffic between client, proxy, and backend
- NAT and port-forwarding status only if the service is intentionally public
- Interface selected for the rule or NAT entry
- Source and destination aliases used by the policy
- Whether the service should be public, VPN-only, or internal-only
- Whether routing changed after WAN, VPN, or gateway changes

Check pfBlockerNG Web UI/reports:

- DNSBL reports for blocked domains related to `service.example.invalid`
- IP block reports for blocked source or destination addresses
- Recent feed updates that might explain a new block
- Whether the issue affects all clients or only filtered clients

Check Suricata Web UI/logs/reports:

- Alerts around the time the service became unreachable
- Whether traffic was only alerted or actively blocked
- Rule category and destination involved
- Whether a false positive may have interrupted expected access

Do not publish exact firewall rules, internal networks, public IPs, aliases, or security-event details. For a public runbook, document the check category and sanitized outcome only.

## Reverse Proxy / HAProxy Checks

In my lab, HAProxy is managed through the pfSense HAProxy package and pfSense Web UI. If DNS and the firewall path look correct but the service returns 502, 503, timeout, TLS errors, or the wrong site, I check the reverse proxy configuration next.

In the pfSense Web UI, I check:

- Whether the expected frontend is enabled.
- Whether the hostname / SNI / ACL rule matches `service.example.invalid`.
- Whether the frontend points to the correct backend.
- Whether the backend server, address, and port are correct.
- Whether the backend is marked available or down.
- Whether the health check path still matches the application.
- Whether recent HAProxy package or pfSense configuration changes were applied.
- Whether certificate selection and TLS termination match the intended service.

From a trusted machine or from the relevant host, I also test whether the backend itself responds:

```bash
curl -I http://<backend-host>:<backend-port>
```

Common outcomes:

- HAProxy is reachable, but the backend is down.
- The frontend rule matches the wrong hostname or backend.
- The backend port changed after an application or container update.
- The health check fails even though the application partly responds.
- TLS or SNI settings cause the wrong certificate or service path to be used.
- The issue is actually caused earlier by pfSense firewall rules, NAT, pfBlockerNG filtering, or Suricata blocking.

For public documentation, I do not include screenshots of live pfSense rules, real domains, backend IPs, internal ports, certificate names, aliases, or full HAProxy configuration.

## TLS / ACME / Let's Encrypt Checks

In my lab, TLS certificates are managed through pfSense, using the ACME package and the pfSense certificate workflow. HAProxy then uses the selected certificate for the relevant frontend. Because of that, a TLS issue can be caused by the certificate itself, the ACME renewal process, DNS validation, or the way the certificate is assigned in the pfSense HAProxy package.

From a trusted client, I first check what certificate is actually being served:

```bash
openssl s_client -connect service.example.invalid:443 -servername service.example.invalid </dev/null
curl -Iv https://service.example.invalid
```

In the pfSense Web UI, I check:

- Whether the expected certificate exists and is still valid.
- Whether the certificate matches `service.example.invalid`.
- Whether the certificate chain looks correct.
- Whether the ACME renewal was successful.
- Whether the ACME account and challenge method are configured correctly.
- Whether DNS validation records were created and removed as expected, if DNS-01 is used.
- Whether HTTP-01 validation could be blocked by firewall, NAT, pfBlockerNG, Suricata, or HAProxy routing, if HTTP-01 is used.
- Whether the correct certificate is selected in the HAProxy frontend.
- Whether HAProxy was reloaded or had its configuration applied after certificate changes.
- Whether SNI/hostname matching points to the expected frontend and backend.

Common outcomes:

- The certificate expired because renewal failed.
- The certificate is valid but not assigned to the correct HAProxy frontend.
- The wrong certificate is served because SNI or frontend matching is wrong.
- DNS validation failed because the DNS provider/API configuration changed.
- HTTP validation failed because the challenge path was not reachable.
- A firewall, pfBlockerNG, Suricata, NAT, or HAProxy rule interfered with validation.
- The certificate renewed correctly, but HAProxy still needs the updated certificate applied.

For public documentation, I do not include real domains, certificate names, ACME account details, DNS provider tokens, API keys, private keys, challenge records, internal hostnames, or screenshots of live pfSense configuration.

## Docker Compose Checks

For containerized services, check Compose state before restarting.

From the service directory:

```bash
docker compose ps
docker compose logs --tail=100 <service>
docker compose logs --since=1h <service>
docker inspect <container>
docker compose config
```

Check for:

- Container stopped or restarting
- Health check failing
- Application startup error
- Database connection error
- Permission problem on mounted volume
- Missing or changed environment variable
- Wrong image tag or failed update
- Network name or service name mismatch
- Port mapping changed
- Volume mount missing or read-only

If a restart is justified:

```bash
docker compose restart <service>
```

For updates or redeployments, I treat this as a separate maintenance action rather than a blind troubleshooting step:

```bash
docker compose pull
docker compose up -d
```

Only do this when I understand what will change, where the data lives, and how to roll back if needed. Avoid destructive cleanup commands unless backups and data locations are understood.

## Storage and Resource Checks

A network-looking problem can be caused by host resources or storage.

```bash
df -h
free -h
uptime
ip addr
ip route
mount
sudo dmesg -T | tail -50
```

Check for:

- Full root filesystem
- Full Docker storage
- Memory pressure or high load
- Missing mount used by the application
- Read-only filesystem
- TrueNAS dataset/share unavailable
- Backup target unavailable
- Permission or ownership changes
- Network route or interface change

For services with important data, also identify where the data actually lives:

- Docker named volume
- Bind mount
- Database container volume
- NAS share
- VM disk
- Application config directory

Do not run cleanup commands blindly. First confirm what data is disposable and what must be preserved.

## Backup and Restore Consideration

Before risky changes, think about restore options.

Ask:

- Is there a recent backup of the VM, container, database, or config?
- Is the relevant storage snapshot available?
- Is there an exported configuration backup for pfSense, HAProxy, TrueNAS, or the application?
- Has this type of restore been tested?
- Would a rollback lose user data created after the backup?
- Is the issue safer to fix forward than to restore?

Examples of safe documentation points:

- Backup type checked: VM backup, storage snapshot, exported config, or application backup
- Restore risk reviewed before changing data
- Config file copied before editing
- Rollback path noted

Do not publish backup repository locations, encryption keys, internal paths, or restore credentials.

## After-Action Documentation

After the service is healthy again, document the result while it is still fresh.

Record:

- Date and approximate time
- Service placeholder, such as `<service>`
- Symptom
- Affected access path: public, VPN, internal, or local only
- Failed layer: DNS, firewall, reverse proxy, TLS, backend, Docker, systemd, storage, or resources
- Evidence used to identify the cause
- Fix applied
- Verification performed after the fix
- Whether monitoring returned to healthy
- Follow-up task to prevent repeat issues

Example sanitized after-action note:

```markdown
## After-action note

Service: <service>
Symptom: `https://service.example.invalid` returned HTTP 503.
Affected path: VPN and internal access.
Failed layer: reverse proxy to backend.
Evidence: HAProxy marked backend down; local backend check on `<backend-port>` failed.
Fix: corrected backend service state and verified local response before re-testing through HAProxy.
Verification: `curl -I` returned expected status; monitoring recovered.
Follow-up: add a clearer backend health check and document restart order.
```

Keep the note factual. Do not turn a lab issue into a production outage or imply an employer/customer impact that did not happen.

## Security and Sanitization Note

This runbook is designed for public GitHub documentation and interview discussion without exposing private infrastructure.

Do not include:

- Real domains
- Public IP addresses
- Private IP ranges or exact internal addressing
- Credentials, tokens, API keys, passwords, or private keys
- Full `.env` files
- Exact firewall rules
- Sensitive HAProxy, pfSense, DNS provider, or ACME account configuration
- Unredacted logs containing usernames, hostnames, client addresses, or secrets
- Claims of professional production administration experience if the work was done in a self-managed lab

Use placeholders instead:

- `service.example.invalid`
- `<service>`
- `<host>`
- `<container>`
- `<backend-host>`
- `<backend-port>`
- `<admin-user>`

The value of this runbook is the troubleshooting structure: verify one layer at a time, collect evidence before changing things, protect data before risky fixes, and document the outcome clearly.
