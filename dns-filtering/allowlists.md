# DNS Allowlists

This document tracks public DNS allowlists used or evaluated in my lab.

Allowlists can help reduce false positives when DNS filtering blocks legitimate services or domains.

## Feed List

| Feed | URL | Purpose | Notes |
|---|---|---|---|
| AnudeepND Whitelist | `https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt` | Commonly allowed domains for Pi-hole-style DNS filtering | Used/evaluated for reducing false positives |
| Pi-hole Common Whitelist Discussion | `https://discourse.pi-hole.net/t/commonly-whitelisted-domains/212` | Community discussion of commonly whitelisted domains | Reference material, not a direct feed |
| mmotti Regex Whitelist | `https://raw.githubusercontent.com/mmotti/pihole-regex/master/whitelist.list` | Regex-style whitelist entries for Pi-hole-style filtering | Used/evaluated carefully because broad allow rules can weaken filtering |

## Notes

Allowlists should be used carefully. They can fix broken services, but overly broad allowlisting can weaken DNS filtering.

In this lab, allowlists are treated as a troubleshooting and false-positive reduction tool, not as a way to blindly bypass filtering.
