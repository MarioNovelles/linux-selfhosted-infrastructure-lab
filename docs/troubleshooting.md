# Troubleshooting

This document is my starting point when something breaks in the lab.

The goal is to avoid random restarts and first find which layer is failing.

## Main idea

Before changing anything, I ask:

```text id="fi59ms"
What changed?
What is broken?
What is affected?
Which layer is failing?
```

## First checks

```bash id="a79gfl"
# Check basic system status
hostnamectl
uptime

# Check disk and memory
df -h
free -h

# Check failed systemd units
systemctl --failed
```

## Service checks

```bash id="9qu806"
# Check service status
systemctl status <service-name>

# Read recent service logs
journalctl -u <service-name> --since "30 minutes ago" --no-pager

# Show listening ports
sudo ss -tulpn
```

## Docker checks

```bash id="2d0r0p"
# Show Compose containers
docker compose ps

# Read recent Compose logs
docker compose logs --tail 50

# Validate the Compose file
docker compose config
```

## DNS troubleshooting path

If DNS resolution fails:

```bash id="trwfun"
# Check which DNS servers the client received
resolvectl status

# Test Pi-hole directly using the sanitized example DNS VM IP
dig @192.168.67.53 cloudflare.com

# Test Unbound locally from the DNS VM
dig @127.0.0.1 -p 5335 cloudflare.com

# Test fallback DNS through the sanitized example pfSense IP
dig @192.168.67.1 cloudflare.com
```

Then I check:

1. Did the client receive the correct DNS servers from DHCP?
2. Is Pi-hole running?
3. Is Unbound running?
4. Is pfSense fallback DNS working?
5. Is the firewall blocking or redirecting DNS?

## Common first places to look

| Symptom             | First check                           |
| ------------------- | ------------------------------------- |
| service not loading | service status and logs               |
| 502 error           | reverse proxy and backend service     |
| DNS problem         | client DNS, Pi-hole, Unbound, pfSense |
| host unreachable    | IP, route, gateway, firewall          |
| Docker app broken   | Compose file, logs, volumes, `.env`   |
| server slow         | disk, memory, CPU, logs               |

## Deeper notes

For more detailed troubleshooting, I use:

* `docs/runbooks/linux-service-troubleshooting-checklist.md`
* `docs/runbooks/linux-command-line-workflow.md`
* `docs/case-studies/service-unreachable-troubleshooting.md`
* `dns-filtering/`

## After fixing

After fixing something, I should write down:

```text id="wqklm8"
Problem:
Cause:
Fix:
How I verified it:
How I can prevent it next time:
```

## Short summary

My troubleshooting approach is to find the failing layer first. I check recent changes, logs, services, Docker, DNS, network, storage, and resources before changing things.

