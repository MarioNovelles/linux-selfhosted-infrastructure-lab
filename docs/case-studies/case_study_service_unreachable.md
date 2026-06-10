# Case Study: Troubleshooting a Service That Is No Longer Reachable

## Scenario

This is a generalized and sanitized troubleshooting case study from my self-managed Linux infrastructure lab. It is not a real production outage report. I use it to show how I would work through a self-hosted service that suddenly cannot be reached through its normal domain or access path.

In this example, the service runs with Docker Compose behind HAProxy. DNS is managed through an external DNS provider, and TLS certificates are handled with an ACME / Let's Encrypt workflow.

## What This Demonstrates

When a service becomes unreachable, I try not to guess or restart things randomly. My first goal is to find the layer where the problem starts: DNS, the network path, firewall/router rules, HAProxy, TLS, the backend service, Docker Compose, host-level services, or system resources.

This also shows how I document technical work without exposing private infrastructure details. Real domains, IP addresses, credentials, private keys, internal addressing, firewall rules, and live configuration values are intentionally left out.

## Environment

The lab environment includes:

- Linux servers, mainly Ubuntu Server and Debian
- Docker and Docker Compose for self-hosted applications
- HAProxy as a reverse proxy
- Cloudflare DNS and domain management
- ACME / Let's Encrypt TLS certificates
- pfSense firewall/router and OpenWrt access point
- Tailscale, with previous WireGuard experience, for VPN-style access
- Uptime Kuma, Grafana, and Prometheus for monitoring and visibility
- Proxmox VE, Proxmox Backup Server, and TrueNAS for virtualization, backup, and storage workflows

The commands below use placeholders such as `service.example.invalid`, `<container>`, `<host>`, and `<service>`.

## Symptoms

A service-unreachable problem can show up in a few different ways:

- The browser cannot open `https://service.example.invalid`
- Monitoring reports the service as down
- `curl` returns a timeout, connection refused, HTTP 502/503, or a TLS error
- The service works internally but not from outside the network
- The backend container is running, but HAProxy cannot reach it
- DNS resolves incorrectly or does not resolve at all

## Troubleshooting Approach

I start by collecting the current state before changing anything. I want to know what fails, from where it fails, whether the problem is public/VPN/internal only, and what changed recently.

A typical order for me is:

1. Confirm the failure from more than one client or network path.
2. Check DNS resolution.
3. Check firewall/router exposure and routing.
4. Check HAProxy frontend/backend routing.
5. Check TLS certificate behavior.
6. Check the backend service and container status.
7. Review Docker Compose logs.
8. Check systemd and `journalctl` if a host service is involved.
9. Review recent deployments, image changes, configuration edits, DNS/TLS/firewall changes, reboots, and storage events.
10. Check host resources such as disk, memory, CPU, routes, and storage mounts.
11. Document the cause and fix in a sanitized way.

## Checks and Example Commands

### 1. Confirm the failure

I usually begin with simple client-side checks. This tells me whether the failure looks like DNS, routing, TLS, a reverse proxy error, or an application/backend problem.

```bash
curl -I https://service.example.invalid
curl -vk https://service.example.invalid
ping service.example.invalid
traceroute service.example.invalid
```

`ping` is only a rough signal. HTTPS can work even when ICMP is blocked, and ICMP can work while the web service is still broken. For web services, `curl` output and logs are usually more useful than ping alone.

### 2. DNS with dig / nslookup

If the domain itself looks suspicious, I check DNS before touching Docker or HAProxy. A wrong or stale DNS record can make the rest of the stack look broken even when it is not.

```bash
dig service.example.invalid
nslookup service.example.invalid
dig @1.1.1.1 service.example.invalid
dig @8.8.8.8 service.example.invalid
```

What I am looking for:

- Does the name resolve at all?
- Does it resolve to the expected public endpoint or proxy target?
- Is the record stale after a recent change?
- Is the issue local DNS filtering, upstream DNS, or the external DNS provider?

### 3. Firewall / router path

Once DNS points where I expect, I check whether the intended network path is reachable. In my lab this may involve pfSense, OpenWrt, public exposure, or VPN-style access through Tailscale.

```bash
ping <public-or-vpn-endpoint>
nmap -Pn -p 80,443 <public-or-vpn-endpoint>
traceroute <public-or-vpn-endpoint>
```

What I check:

- Is the firewall/router endpoint reachable?
- Are ports 80 and 443 reachable from the intended network path?
- Is the service supposed to be public, VPN-only, or internal-only?
- Did a firewall, NAT, port-forwarding, or routing change affect access?

Additional pfSense-specific checks in my lab:

- Check whether pfBlockerNG DNS filtering blocked the domain or category.
- Check whether pfBlockerNG IP filtering blocked the destination IP or source path.
- Check firewall logs for blocked traffic between client, proxy and backend.
- Check NAT/port-forwarding only if the service is intentionally exposed.
- Check Suricata alerts if the traffic may have been flagged or blocked.
- Confirm whether the expected access path is public, VPN-only or internal-only.

In my environment, a “service unreachable” problem is not always caused by the service itself. It can also be caused by DNS filtering, IP filtering, IDS/IPS alerts, firewall policy, NAT, routing, or a mismatch between public, VPN-only and internal access paths.

I do not publish exact firewall rules, internal addressing, or live network paths. For public documentation, I only describe the troubleshooting logic at a high level.

### 4. HAProxy / reverse proxy

If the request reaches the host but the service still fails, I check HAProxy next. At this point I want to know whether HAProxy is running, whether its configuration is valid, and whether it can reach the backend.

```bash
sudo systemctl status haproxy
sudo journalctl -u haproxy --since "1 hour ago"
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
curl -I http://<backend-host>:<backend-port>
```

What I check:

- Is HAProxy running?
- Does the configuration validate?
- Is the correct frontend matching the hostname?
- Is the backend server marked available or down?
- Is HAProxy returning 502/503 because the backend is unavailable?

For sanitized examples, I do not include real domains, backend IPs, internal ports, or complete live configuration.

### 5. TLS / certificate

If the browser or `curl` reports a certificate problem, I check what certificate is actually being served. This helps separate an application problem from a TLS, SNI, or ACME renewal issue.

```bash
openssl s_client -connect service.example.invalid:443 -servername service.example.invalid </dev/null
curl -Iv https://service.example.invalid
```

What I check:

- Is the certificate valid and not expired?
- Does the certificate match the hostname?
- Is SNI working as expected?
- Did an ACME / Let's Encrypt renewal fail?
- Is the reverse proxy serving the expected certificate?

If the problem is certificate-related, I check the ACME client logs or renewal process without exposing account details, private keys, or real certificate paths.

### 6. Backend service

If HAProxy is reachable but the backend appears down, I move closer to the application. I check the host and container state before restarting anything.

```bash
ssh <admin-user>@<host>
docker ps
docker compose ps
curl -I http://localhost:<backend-port>
curl -I http://<container-or-service-name>:<backend-port>
```

What I check:

- Is the backend container running?
- Is the service listening on the expected internal port?
- Is the application healthy locally?
- Did a recent update, restart, or configuration change affect the service?
- Is the reverse proxy failing, or is the backend itself failing?

### 7. Docker Compose logs

Container status alone is not enough. A container can be running but still failing internally, so I check the recent logs and the current Compose state.

```bash
docker compose logs --tail=100 <service>
docker compose logs --since=1h <service>
docker compose ps
docker inspect <container>
```

What I look for:

- Application startup errors
- Database connection errors
- Permission or volume mount problems
- Missing environment variables
- Failed migrations or updates
- Restart loops

I avoid publishing real `.env` files, tokens, credentials, database passwords, or complete live Compose files.

If a restart is needed, I do it after checking the current state and logs, not as the first troubleshooting step:

```bash
docker compose restart <service>
```

### 8. Recent changes

If the basic checks do not immediately explain the issue, I look for what changed shortly before the alert or failure. This is often the fastest way to narrow the search without making the situation worse.

I check whether there was a recent deployment, a new container image, an edited Compose or environment file, a DNS change, a TLS/ACME renewal problem, a HAProxy or firewall change, a reboot, a package update, or a storage event. In a lab like this, storage is especially worth checking because a missing mount or full disk can make a service look unreachable even when the network path is fine.

The exact commands depend on where the service lives, but these are the kinds of checks I might use as examples:

```bash
docker compose ps
docker compose config
docker image ls
ls -lt
```

I would use these when I want to compare the intended Docker Compose configuration with what is currently running, check whether images or files were changed recently, and spot obvious differences before making a new change.

Questions I ask at this stage:

- Was the service recently updated, redeployed, or restarted?
- Did an image tag, volume mount, permission, or configuration file change?
- Did a DNS, firewall, HAProxy, TLS, or environment variable change happen recently?
- Was there a host reboot, package update, certificate renewal, or storage event?
- Did monitoring such as Uptime Kuma, Grafana, or Prometheus show when the problem started?

Recent changes do not automatically prove the cause, but they usually tell me where to look next.

### 9. systemd / journalctl where relevant

Some services are managed directly by systemd instead of Docker. Host-level services can also affect a containerized application, especially networking, HAProxy, SSH, storage mounts, and scheduled maintenance tasks.

```bash
systemctl status <service>
journalctl -u <service> --since "1 hour ago"
journalctl -xe
systemctl list-units --failed
```

What I check:

- Failed host services
- Restart loops
- Permission problems
- Network service failures
- Failed scheduled maintenance tasks
- Errors after package updates or reboot

### 10. Host resources and storage

If the service and proxy configuration look reasonable, I check the host itself. A service can appear unreachable because the disk is full, a mount is missing, memory is exhausted, or routing changed.

```bash
df -h
free -h
uptime
ip addr
ip route
mount
sudo dmesg -T | tail -50
```

What I check:

- Full disks or full Docker volumes
- Memory pressure
- High load
- Missing storage mounts
- Network interface or route changes
- Kernel or hardware-related errors

For self-hosted services, storage issues are especially important. In a setup that includes TrueNAS or Proxmox Backup Server workflows, I want to know whether the application depends on a mount, dataset, backup location, or storage path that is no longer available.

## Example Outcome Categories

A service-unreachable issue usually ends up in one of these areas:

- DNS record missing, stale, or pointing to the wrong target
- Firewall/router path not allowing the intended access
- HAProxy routing mismatch or backend marked down
- TLS certificate expired, mismatched, or not loaded correctly
- Backend container stopped or stuck in a restart loop
- Application error visible in Docker Compose logs
- Host-level service failure visible in `systemctl` or `journalctl`
- Resource issue such as a full disk, unavailable storage mount, or memory pressure

## After the Fix

After resolving the issue, I would normally:

- Re-test the service from the expected access path, such as public URL, VPN, or internal network.
- Confirm that monitoring has returned to a healthy state.
- Check whether the fix survives a restart or redeploy, if relevant.
- Record the cause, affected layer, commands used, and final fix.
- Note whether a monitoring check, alert, documentation update, or backup/restore improvement would prevent a similar issue in the future.

## What I Learned

This kind of troubleshooting works best when I slow down and verify one layer at a time. A browser error by itself is not enough information. `curl`, `dig`, Docker Compose logs, HAProxy checks, `journalctl`, and local backend tests give a much clearer picture.

I also learned that reverse proxy errors often point to a backend or network-path problem, not only a proxy problem. Looking at Docker logs and host logs together is useful because the cause may be inside the container, on the Linux host, or somewhere in the surrounding infrastructure.

Finally, writing the notes in a sanitized way makes the case study safe to publish while still showing the real troubleshooting workflow.

## What I Would Improve Next

- Create a reusable troubleshooting checklist for common service failures.
- Add clearer runbooks for DNS, HAProxy, TLS renewal, Docker Compose, and storage issues.
- Improve alerting so monitoring points more directly to the failed layer.
- Document restore tests for important services, not only backup creation.
- Continue publishing sanitized examples that show troubleshooting logic without revealing private configuration.

## Security Note

This case study intentionally avoids real domains, public IP addresses, private IP ranges, credentials, tokens, private keys, exact firewall rules, exact internal addressing, and live production configuration values. It is written as a practical troubleshooting workflow for a self-managed Linux infrastructure lab, not as a report of a specific production incident.
