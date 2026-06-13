# IP Blocklists

This document tracks public IP blocklist feeds used or evaluated in my lab with pfBlockerNG.

IP blocklists are different from DNS blocklists. DNS blocklists stop clients from resolving unwanted domains, while IP blocklists can block traffic to or from known unwanted IP addresses or networks directly at the firewall.

The goal is not to block as much as possible, but to use a small number of reputable feeds carefully and monitor for false positives.

## Feed List

| Feed                         | URL                                                                   | Purpose                                             | Notes                                                                          |
| ---------------------------- | --------------------------------------------------------------------- | --------------------------------------------------- | ------------------------------------------------------------------------------ |
| Abuse Feodo C2               | `https://feodotracker.abuse.ch/downloads/ipblocklist_recommended.txt` | Botnet command-and-control IPs                      | Recommended Feodo Tracker IP blocklist                                         |
| Abuse SSLBL                  | `https://sslbl.abuse.ch/blacklist/sslipblacklist.txt`                 | SSL/TLS-related botnet C2 IPs                       | Deprecated feed; kept here as evaluated/history, not preferred for active use  |
| CINS Army                    | `https://cinsarmy.com/list/ci-badguys.txt`                            | Known hostile or suspicious IPs                     | Public IP reputation feed                                                      |
| Emerging Threats Block       | `https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt`    | Emerging Threats firewall block IPs                 | Used/evaluated as a threat-intelligence feed                                   |
| Emerging Threats Compromised | `https://rules.emergingthreats.net/blockrules/compromised-ips.txt`    | Compromised IP addresses                            | Used/evaluated as a threat-intelligence feed                                   |
| SANS ISC Block               | `https://isc.sans.edu/block.txt`                                      | Internet Storm Center block list                    | Used/evaluated as a security feed                                              |
| Spamhaus DROP                | `https://www.spamhaus.org/drop/drop_v4.json`                          | Malicious netblocks for firewall/routing protection | JSON feed; check pfBlockerNG compatibility and licensing/fair-use requirements |
| Cisco Talos IP Blacklist     | `https://talosintelligence.com/documents/ip-blacklist`                | Cisco Talos IP blacklist                            | Check current access/terms before using automatically                          |

## Operational Notes

IP blocklists can create false positives, especially when cloud providers, CDNs, shared hosting, VPN providers, or dynamic infrastructure are involved.

For that reason, I treat IP blocking as one layer of defense, not as a complete security solution. It should be combined with:

* DNS filtering
* firewall rules
* network segmentation
* patching
* monitoring
* backup and recovery planning
* careful review of blocked traffic

Feeds should be reviewed periodically. Deprecated, unavailable, or noisy feeds should be removed instead of blindly kept enabled.

## Safety Notes

This document lists public feed URLs only. It does not publish internal aliases, exact firewall rules, internal addresses, public IP addresses, or production pfBlockerNG configuration.

