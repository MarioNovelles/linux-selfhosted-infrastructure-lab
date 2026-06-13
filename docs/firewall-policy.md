# Firewall Policy Notes

This document summarizes the main firewall policy areas used in my lab. It is intentionally sanitized, so it explains the purpose and logic of the rules without publishing exact firewall rules, internal IP addresses, aliases, public IP addresses, VPN endpoints, or production configuration.

## Goal

The firewall policy is designed to keep the lab usable while still enforcing sensible network controls.

The main goals are:

* allow trusted LAN clients to reach required services
* keep normal DNS traffic going through the firewall resolver where possible
* reduce DNS bypass through external DNS servers or DNS-over-TLS
* keep temporary migration or troubleshooting rules easy to identify
* avoid unmanaged IPv6 paths until IPv6 is fully planned and documented
* document VPN routing and access decisions clearly

## Policy Areas

| Rule Area                  | Purpose                                                                      | Notes                                                                 |
| -------------------------- | ---------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| Anti-lockout access        | Prevent accidental loss of firewall administration access                    | Limited to trusted management access                                  |
| DNS to firewall            | Allow LAN clients to query the firewall DNS resolver                         | Supports DNS filtering, local DNS, and consistent name resolution     |
| DNS redirect / enforcement | Redirect or restrict normal client DNS traffic through the firewall resolver | Helps reduce DNS bypass on TCP/UDP port `53`                          |
| Block external DNS         | Prevent clients from directly using external DNS servers                     | Supports consistent DNS filtering policy                              |
| Block DNS-over-TLS         | Reduce encrypted DNS bypass on port `853`                                    | Useful layer, but not a complete DNS-over-HTTPS solution              |
| DNSBL / pfBlockerNG policy | Block unwanted domains and selected IP feeds                                 | Used carefully to reduce false positives                              |
| VPN policy routing         | Route selected traffic through VPN gateway rules                             | Useful for privacy or routing control, but can affect DNS visibility  |
| IPv6 policy                | Block or restrict IPv6 until it is fully designed                            | Avoids unmanaged IPv6 paths around the intended IPv4 policy           |
| Temporary migration rules  | Allow selected traffic during subnet, service, or host migration             | Temporary rules should be reviewed and removed after use              |
| Default LAN access         | Allow normal trusted LAN traffic where appropriate                           | Broader pass rules should come after more specific DNS or block rules |

## Rule Order Notes

Firewall rule order matters. More specific allow, redirect, or block rules should be placed before broader pass rules.

For example, DNS enforcement rules should be evaluated before general LAN-to-WAN allow rules. Otherwise, clients may be able to bypass the intended DNS resolver.

Temporary rules should be clearly named and reviewed after the migration, troubleshooting task, or testing period is complete. This helps avoid old temporary rules becoming permanent without a reason.

## DNS Enforcement Relationship

The firewall policy works together with the DNS filtering documentation in this repository.

Normal client DNS traffic can be redirected or restricted so that LAN clients use the firewall resolver. This supports DNS filtering, local DNS records, and more consistent logging.

This does not fully prevent every bypass method. Third-party VPNs, DNS-over-HTTPS over port `443`, manually configured encrypted DNS, unmanaged devices, and mobile hotspot usage can still avoid local DNS filtering in some situations.

Because of these limitations, DNS enforcement should be treated as one layer. Depending on the environment, additional layers may include endpoint controls, browser policy, provider-domain blocking, DoH IP blocklists, network segmentation, and monitoring.

## IPv6 Notes

IPv6 should not be left unmanaged. If IPv6 is enabled but not intentionally configured, filtered, and monitored, clients may use IPv6 paths that bypass parts of the intended IPv4 policy.

In this lab, IPv6 is treated cautiously until it is fully designed and documented.

## Safety Notes

This document is intentionally sanitized. It does not publish:

* exact firewall rules
* internal IP addressing
* public IP addresses
* aliases
* VPN endpoints
* credentials
* production pfSense configuration

