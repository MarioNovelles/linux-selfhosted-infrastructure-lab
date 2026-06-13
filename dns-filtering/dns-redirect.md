# DNS Redirect / DNS Enforcement

This document summarizes a sanitized DNS enforcement pattern used in my lab.

The goal is to make LAN clients use the firewall DNS resolver instead of directly querying external DNS servers. This supports local DNS filtering, logging, and consistent name resolution behavior.

The approach is based on the Netgate/pfSense recipe for redirecting client DNS requests.

## Sanitized Rule Logic

| Rule Area | Purpose |
|---|---|
| DNS resolver / forwarder | Firewall DNS service must be enabled and able to answer local queries |
| NAT DNS redirect | Redirect LAN client DNS traffic on TCP/UDP port `53` to the firewall resolver |
| Pass DNS to firewall | Allow clients to query the firewall DNS resolver |
| Block external DNS | Prevent clients from directly using external DNS servers on port `53` |
| Block DNS-over-TLS | Reduce bypass through DNS-over-TLS on port `853` |

## DNS-over-HTTPS Bypass Considerations

This lab uses a layered approach to reduce DNS filtering bypass.

Normal DNS traffic on TCP/UDP port `53` is redirected or restricted so LAN clients use the firewall resolver. DNS-over-TLS on TCP port `853` can be blocked with a firewall rule. Known DNS-over-HTTPS provider domains and IP addresses may also be blocked with DNSBL/IP blocklists.

This is not a perfect DoH-blocking solution because DNS-over-HTTPS commonly uses HTTPS on port `443`, which can make it difficult to distinguish from normal web traffic at the firewall. For managed devices, browser or endpoint policies are a stronger control than network blocking alone.

The goal is to reduce casual or accidental DNS bypass while keeping the network usable and avoiding overly aggressive blocking that causes false positives.

Firefox supports organization controls for DoH and also supports a canary domain mechanism; Mozilla says a negative result for use-application-dns.net signals Firefox to disable application DNS/DoH.

For managed browsers, Firefox has enterprise policy support for DNSOverHTTPS, and Microsoft Edge has a DnsOverHttpsMode policy where off disables DNS-over-HTTPS.

## Notes

Rule order matters. DNS allow or redirect behavior should be placed before broader DNS block rules.

Exact interfaces, internal addresses, aliases, and production firewall rules are intentionally not published.

## Reference

- Netgate pfSense documentation: Redirecting Client DNS Requests
