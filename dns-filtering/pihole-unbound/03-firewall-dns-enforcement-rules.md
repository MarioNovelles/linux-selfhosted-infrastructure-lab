# pfSense DNS Enforcement Rules

This document explains the pfSense firewall and NAT rules I use with Pi-hole, Unbound, and pfSense fallback DNS.

## Goal

The intended DNS design is:

```text
Normal path:
Client → Pi-hole → Unbound → root / TLD / authoritative DNS servers

Fallback path:
Client → pfSense DNS Resolver → pfBlockerNG DNSBL
```

Clients receive both DNS servers through DHCP:

```text
DNS server 1: 192.168.33.101  # Pi-hole
DNS server 2: 192.168.33.1    # pfSense fallback DNS
```

Pi-hole is the preferred DNS path.

pfSense remains available as the fallback DNS path with pfBlockerNG DNSBL.

Rogue DNS queries to external resolvers should not bypass filtering.

Examples of rogue DNS destinations:

```text
8.8.8.8
1.1.1.1
9.9.9.9
```

## Aliases

In pfSense, I use aliases to make the firewall and NAT rules easier to read.

In pfSense:

```text
Firewall → Aliases → IP
```

Create an alias for the DNS VM:

```text
Name: ubuntu_dns
IP:   192.168.33.101
```

Create an alias for approved DNS servers:

```text
Name: Allowed_DNS_Servers

192.168.33.101  # Pi-hole
192.168.33.1    # pfSense fallback DNS
```

If this setup is rebuilt in another environment, these private lab IP addresses should be replaced with the correct values.

## Important lesson

The DNS VM must be excluded from the pfSense DNS redirect rule.

Unbound is a recursive resolver. It needs to contact root, TLD, and authoritative DNS servers directly on TCP/UDP port `53`.

If the DNS VM is included in the DNS redirect rule, Unbound's outbound recursive DNS queries can be redirected back to pfSense.

That breaks recursive DNS and can cause Pi-hole to return:

```text
SERVFAIL
```

The important rule is:

```text
Do not redirect the DNS VM itself.
```

## Firewall rule order

DNS-related LAN firewall rules should be ordered like this:

| Order | Action                    | Source         | Destination           | Port        | Description                      |
| ----- | ------------------------- | -------------- | --------------------- | ----------- | -------------------------------- |
| 1     | Pass                      | `ubuntu_dns`   | any                   | TCP/UDP 53  | Allow DNS VM recursive DNS       |
| 2     | Pass / NAT generated rule | `! ubuntu_dns` | `127.0.0.1`           | TCP/UDP 53  | NAT redirect rogue DNS           |
| 3     | Pass                      | any            | `Allowed_DNS_Servers` | TCP/UDP 53  | Pass DNS to approved DNS servers |
| 4     | Block                     | any            | any                   | TCP/UDP 53  | Block DNS to everything else     |
| 5     | Block                     | any            | any                   | TCP/UDP 853 | Block DNS over TLS               |
| 6     | Pass                      | LAN subnets    | any                   | any         | Normal LAN traffic               |

Rule order matters.

The DNS VM allow rule must be above the DNS block rule.

The approved DNS allow rule must also be above the DNS block rule.

## Allow the DNS VM to perform recursion

Firewall rule:

```text
Action:      Pass
Interface:   LAN
Protocol:    TCP/UDP
Source:      ubuntu_dns
Destination: any
Port:        53
Description: Allow DNS VM recursive DNS
```

Why:

Unbound needs to contact root, TLD, and authoritative DNS servers.

If this traffic is redirected or blocked, recursive DNS can fail.

## Allow clients to approved DNS servers

Firewall rule:

```text
Action:      Pass
Interface:   LAN
Protocol:    TCP/UDP
Source:      LAN subnets
Destination: Allowed_DNS_Servers
Port:        53
Description: Pass DNS to approved DNS servers
```

Why:

Clients should be allowed to query Pi-hole and pfSense.

Both are approved DNS paths.

## NAT redirect rule

In pfSense:

```text
Firewall → NAT → Port Forward
```

The DNS redirect rule is:

| Field            | Value                                      |
| ---------------- | ------------------------------------------ |
| Interface        | LAN                                        |
| Protocol         | TCP/UDP                                    |
| Source           | `! ubuntu_dns`                             |
| Source port      | any                                        |
| Destination      | `! Allowed_DNS_Servers`                    |
| Destination port | DNS 53                                     |
| NAT IP           | `127.0.0.1`                                |
| NAT port         | DNS 53                                     |
| Description      | Redirect rogue DNS to pfSense fallback DNS |

Meaning:

```text
Source is not ubuntu_dns
AND destination is not an approved DNS server
AND destination port is DNS 53
→ redirect to pfSense DNS Resolver on 127.0.0.1:53
```

This allows:

```text
Client → Pi-hole DNS
Client → pfSense DNS
```

This redirects:

```text
Client → external DNS, for example 8.8.8.8 or 1.1.1.1
```

This does not redirect:

```text
ubuntu_dns → external root / TLD / authoritative DNS servers
```

## Why rogue DNS redirects to pfSense

A DNS redirect rule is not a health check.

pfSense does not redirect to Pi-hole first and then try pfSense if Pi-hole is down.

If a NAT redirect rule matches, the packet is rewritten to the redirect target.

Because of that, I redirect rogue DNS to pfSense instead of Pi-hole.

Pi-hole is used through DHCP as the preferred DNS server.

pfSense is kept as the fallback and enforcement DNS path.

## Block DNS to everything else

Below the allow and NAT redirect rules, I keep a block rule.

```text
Action:      Block or Reject
Interface:   LAN
Protocol:    TCP/UDP
Source:      LAN subnets
Destination: any
Port:        53
Description: Block DNS to everything else
```

Why:

Only approved DNS paths should be allowed.

## Block DNS-over-TLS

DNS-over-TLS can bypass normal DNS filtering.

I block port `853`.

```text
Action:      Block or Reject
Interface:   LAN
Protocol:    TCP/UDP
Source:      LAN subnets
Destination: any
Port:        853
Description: Block DNS over TLS
```

This does not fully solve DNS-over-HTTPS because DoH often uses normal HTTPS on port `443`.

For managed devices, browser or endpoint policy is stronger than firewall blocking alone.

## Testing firewall behavior

From a normal client:

```bash
# Check which DNS servers the client received.
resolvectl status

# Test Pi-hole directly.
dig @192.168.33.101 cloudflare.com

# Test pfSense fallback directly.
dig @192.168.33.1 cloudflare.com

# Test external DNS bypass behavior.
dig @8.8.8.8 cloudflare.com
```

Expected:

```text
Pi-hole direct query works.
pfSense direct query works.
External DNS is redirected to pfSense or blocked.
```

From the DNS VM:

```bash
# Test Unbound directly.
dig cloudflare.com @127.0.0.1 -p 5335

# Test direct root DNS access over UDP.
dig @198.41.0.4 . NS +norec +time=3

# Test direct root DNS access over TCP.
dig @198.41.0.4 . NS +norec +tcp +time=3
```

Expected:

```text
Unbound returns NOERROR.
Root DNS tests are not redirected back to pfSense.
```

## Final summary

Clients are told to use Pi-hole first and pfSense second.

pfSense allows both approved DNS servers.

Rogue DNS is redirected to pfSense.

The DNS VM is excluded from DNS redirect so Unbound recursion works.

