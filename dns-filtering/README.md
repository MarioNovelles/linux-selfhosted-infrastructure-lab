# DNS Filtering

This folder documents DNS filtering notes, blocklists, allowlists, regex rules, encrypted DNS bypass considerations, and IP blocklist usage evaluated in my lab.

## Filtering Approach

Earlier in the lab, I experimented with very aggressive DNS filtering by enabling many blocklists and broad regex rules. This blocked more unwanted traffic, but it also made normal internet use harder because of false positives, broken websites, and extra troubleshooting.

I now prefer a smaller, more reliable set of blocklists and carefully reviewed regex rules. The goal is to reduce ads, tracking, malicious domains, and unwanted services while keeping the network usable for normal daily browsing and self-hosted services.

Regex rules are tested carefully before being used broadly because they can match more than intended.

DNS filtering can reduce unwanted traffic and casual DNS bypass, but it does not fully prevent bypass through third-party VPNs, manually configured encrypted DNS, or unmanaged devices.

## Files

- [DNS blocklists](./blocklists.md) — public DNS blocklists used or evaluated in the lab
- [DNS allowlists](./allowlists.md) — allowlists used or evaluated to reduce false positives
- [`regex.txt`](./regex.txt) — DNS regex rules used or evaluated carefully because broad rules can overmatch
- [`encrypted-dns-providers.txt`](./encrypted-dns-providers.txt) — known DoH/DoT/DoQ provider domains used or evaluated for DNS bypass reduction
- [IP blocklist notes](./ip-blocklists.md) — IP blocklist feeds used or evaluated with pfBlockerNG
- [DNS redirect / DNS enforcement](./dns-redirect.md) — notes on redirecting or restricting client DNS through the firewall resolver
