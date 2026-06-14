# Cloudflare DDNS for WireGuard Remote Access

This runbook documents a remote-access approach used earlier in the lab, before the connection was behind CGNAT.

The goal was to keep WireGuard VPN access working even when the residential WAN IP address changed.

## Background

Earlier in the lab, the internet connection had a dynamic public IP address. This meant the WAN IP could change, but inbound access was still technically possible.

To make WireGuard easier to reach, I used:

- a purchased domain
- Cloudflare DNS
- a Cloudflare DDNS updater script
- a cron job to run the updater regularly
- a DNS record pointing to the current public IP address

This allowed the WireGuard endpoint to be reached through a domain name instead of manually checking and updating the changing WAN IP address.

## Reference Implementation

For the DDNS updater, I used the public `cloudflare-ddns-updater` script from K0p1-Git as a reference implementation:

- `https://github.com/K0p1-Git/cloudflare-ddns-updater`

In my lab, the script was configured locally and executed on a schedule with cron. The real configuration values, Cloudflare API token, zone ID, DNS record, domain name, and production crontab are not published in this repository.
