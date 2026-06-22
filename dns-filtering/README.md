# DNS Filtering

This folder documents DNS filtering, recursive DNS resolution, allowlists, blocklists, encrypted DNS bypass considerations, and pfSense DNS enforcement notes used in my lab.

## DNS architecture

This lab uses a redundant DNS filtering design.

```text
Primary DNS:   Pi-hole + Unbound
Fallback DNS:  pfSense DNS Resolver + pfBlockerNG DNSBL
```

Pi-hole provides the main DNS filtering, query visibility, and local DNS records.

Unbound provides recursive DNS resolution without relying on public DNS forwarders such as Cloudflare, Google, or Quad9.

pfSense remains the router, firewall, DHCP server, and fallback DNS resolver with pfBlockerNG DNSBL.

## Pi-hole + Unbound runbook

| File                                                                                                           | Purpose                                                                                   |
| -------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| [`pihole-unbound/01-install-pihole-unbound.md`](./pihole-unbound/01-install-pihole-unbound.md)                 | Install Pi-hole and Unbound on a dedicated Ubuntu DNS VM                                  |
| [`pihole-unbound/02-configure-pfsense-dhcp-dns.md`](./pihole-unbound/02-configure-pfsense-dhcp-dns.md)         | Configure pfSense DHCP to hand out Pi-hole as primary DNS and pfSense as fallback DNS     |
| [`pihole-unbound/03-firewall-dns-enforcement-rules.md`](./pihole-unbound/03-firewall-dns-enforcement-rules.md) | Document pfSense DNS enforcement, NAT redirect, allowed DNS aliases, and DNS bypass rules |
| [`pihole-unbound/04-troubleshoot-unbound-servfail.md`](./pihole-unbound/04-troubleshoot-unbound-servfail.md)   | Troubleshoot Pi-hole receiving queries while Unbound returns `SERVFAIL`                   |
| [`pihole-unbound/05-troubleshoot-dns-vm-static-ip.md`](./pihole-unbound/05-troubleshoot-dns-vm-static-ip.md)   | Troubleshoot the DNS VM receiving a DHCP pool address instead of the intended static IP   |

## Filtering approach

Earlier in the lab, I experimented with very aggressive DNS filtering by enabling many blocklists and broad regex rules.

This blocked more unwanted traffic, but it also caused false positives, broken websites, and extra troubleshooting.

I now prefer a smaller and more reliable set of blocklists, plus carefully reviewed regex rules.

The goal is to reduce ads, tracking, malicious domains, unwanted services, and casual DNS bypass while keeping the network usable for normal daily browsing and self-hosted services.

Regex rules are tested carefully before being used broadly because they can match more than intended.

DNS filtering is one layer of control. It does not fully prevent bypass through third-party VPNs, manually configured encrypted DNS, unmanaged devices, or browser-level DNS-over-HTTPS settings.

## Allowlists

| File                                                                                                 | Purpose                                      |
| ---------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| [`allowlists/allowlists.md`](./allowlists/allowlists.md)                                             | Allowlist notes used or evaluated in the lab |
| [`allowlists/allow-regex.txt`](./allowlists/allow-regex.txt)                                         | Pi-hole allow regex examples                 |
| [`allowlists/commonly-whitelisted-from-pihole.md`](./allowlists/commonly-whitelisted-from-pihole.md) | Common Pi-hole whitelist notes               |
| [`allowlists/pfblockerng-official-whitelist.txt`](./allowlists/pfblockerng-official-whitelist.txt)   | pfBlockerNG whitelist reference              |

## Blocklists

| File                                                                                 | Purpose                                                                         |
| ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| [`blocklists/blocklists.md`](./blocklists/blocklists.md)                             | DNS blocklist notes used or evaluated in the lab                                |
| [`blocklists/block-regex.txt`](./blocklists/block-regex.txt)                         | Pi-hole block regex examples                                                    |
| [`blocklists/encrypted-dns-providers.txt`](./blocklists/encrypted-dns-providers.txt) | Known encrypted DNS provider entries used or evaluated for DNS bypass reduction |
| [`blocklists/ip-blocklists.md`](./blocklists/ip-blocklists.md)                       | IP blocklist notes used or evaluated with pfBlockerNG                           |

## IPv6 scope

IPv6 is intentionally not used in this lab DNS filtering design.

The DNS filtering and DNS enforcement rules are based on the IPv4 LAN design:

```text
Primary DNS:   Pi-hole + Unbound
Fallback DNS:  pfSense DNS Resolver + pfBlockerNG DNSBL
```

To avoid accidental DNS bypass through IPv6, pfSense is configured so internal interfaces do not advertise IPv6 to clients.

The intended pfSense IPv6 state is:

```text
WAN/LAN IPv6 Configuration Type: None
Router Advertisements: Disabled
DHCPv6 Server: Disabled
Allow IPv6: unchecked as a final firewall safety layer
```

This keeps DNS filtering predictable.

If IPv6 is added to the lab later, it should be designed and documented properly instead of being enabled accidentally.

IPv6 is intentionally out of scope for this DNS filtering design; the pfSense IPv6 disablement procedure is documented in [`docs/runbooks/disable-ipv6-pfsense.md`](../docs/runbooks/disable-ipv6-pfsense.md).

## Notes

DNS filtering helps improve visibility and reduce unwanted DNS traffic, but it is not a complete security boundary.

The goal is to keep DNS filtering useful, understandable, and reliable without making the network difficult to use.

