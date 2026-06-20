# Security Notes

This document explains the basic security approach I use in my lab.

The goal is to show how I think about reducing exposure, protecting secrets, and checking what is reachable.

This is a private lab, not a production security environment.

## Main idea

My basic security approach is:

* keep administration interfaces private
* expose only what is needed
* prefer VPN access for private services
* avoid committing secrets to Git
* check open ports and Docker published ports
* document limitations honestly

For me, security starts with a simple question:

> Does this service really need to be reachable from here?

## What I do not publish

I do not publish:

* real passwords
* API tokens
* private keys
* VPN keys
* real `.env` files
* public IP addresses
* real domains
* full firewall exports
* production configuration with secrets

Some documents use sanitized example IP addresses when they help explain the setup.

## Access model

| System                      | Access model                        |
| --------------------------- | ----------------------------------- |
| pfSense                     | private access only                 |
| Proxmox                     | private access only                 |
| TrueNAS                     | private access only                 |
| Proxmox Backup Server       | private access only                 |
| Docker admin tools          | private access only                 |
| Monitoring dashboards       | private access only                 |
| Normal user-facing services | exposed only when there is a reason |

I do not want management interfaces to be reachable directly from the public internet.

## SSH basics

For Linux servers, my preferred SSH approach is:

* use SSH keys instead of passwords
* disable root login where practical
* limit which users can log in
* check the SSH config before reloading the service

Useful commands:

```bash
# Check if the SSH server config has valid syntax
sudo sshd -t

# Show important effective SSH settings
sudo sshd -T | grep -Ei 'permitrootlogin|passwordauthentication|pubkeyauthentication'

# Reload SSH after checking the config
sudo systemctl reload ssh
```

I check the configuration before reloading SSH because a broken SSH config can lock me out of a remote server.

## Git and secrets

Before committing, I check what changed.

```bash
# Show changed files
git status

# Review unstaged changes
git diff

# Review staged changes before committing
git diff --staged
```

I also search for common secret-related words before pushing.

```bash
# Search the repository for common sensitive words
git grep -nEi 'password|token|secret|private key|api key' || true
```

This command is not perfect, but it helps me catch obvious mistakes.

I still need to review the results manually because a word like `password` can also appear in harmless documentation.

## Docker exposure checks

For Docker services, I check which ports are published.

```bash
# Show running containers and their published ports
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}'

# Show listening ports on the Linux host
sudo ss -tulpn
```

This helps me understand whether a service is only local, reachable on the LAN, or exposed more widely than intended.

## Firewall approach

My firewall approach is:

* block by default where practical
* allow only what is needed
* keep admin interfaces private
* document temporary rules
* remove old rules after migrations
* avoid exposing dashboards directly to the internet

If I add a temporary rule for testing or migration, I should document why it exists and remove it when it is no longer needed.

## DNS filtering limitations

DNS filtering is useful, but it is not complete security.

It can be bypassed by:

* DNS-over-HTTPS
* VPNs
* mobile hotspots
* manually configured DNS
* direct IP access

Because of that, I treat DNS filtering as one security layer, not as the only protection.

## Things I still want to improve

* better VLAN separation
* more complete firewall rule documentation
* more restore testing
* more automated checks before pushing to GitHub
* regular review of exposed services

## Short summary

My security approach is simple: reduce unnecessary exposure, keep admin interfaces private, avoid committing secrets, check open ports, and be honest about what is implemented and what still needs improvement.

