# Configure pfSense DHCP DNS Servers

This document explains how I configured pfSense DHCP to give LAN clients two DNS servers.

```text
Primary DNS:   Pi-hole + Unbound
Fallback DNS:  pfSense DNS Resolver + pfBlockerNG DNSBL
```

## Goal

The intended DNS design is:

```text
Normal path:
Client → Pi-hole → Unbound → root / TLD / authoritative DNS servers

Fallback path:
Client → pfSense DNS Resolver → pfBlockerNG DNSBL
```

Pi-hole is the preferred DNS path.

pfSense remains available as the fallback DNS path.

This keeps DNS filtering available during normal use and still gives clients a filtered DNS path if the Pi-hole VM is offline.

## Example lab values

The IP addresses shown here are private lab examples. Replace them with the correct values for the environment.

```text
Pi-hole DNS:  192.168.33.101
pfSense DNS: 192.168.33.1
```

## Configure DHCP DNS servers

In pfSense:

```text
Services → DHCP Server → LAN
```

Set:

```text
DNS server 1: 192.168.33.101
DNS server 2: 192.168.33.1
```

Meaning:

```text
DNS server 1 = Pi-hole
DNS server 2 = pfSense fallback DNS
```

## Keep pfSense DNS Resolver enabled

pfSense should still be able to answer DNS queries.

In pfSense:

```text
Services → DNS Resolver
```

The DNS Resolver should remain enabled.

pfBlockerNG DNSBL should also remain active so the fallback DNS path still has filtering.

## Important limitation

Clients do not always use DNS servers strictly as “primary first, fallback second.”

Some clients may use DNS server 1 first and only use DNS server 2 if needed.

Other clients may query both DNS servers.

Because of that, both DNS paths should provide filtering.

I do not treat the second DNS server as a completely unused backup.

## Client testing

After changing DHCP settings, renew DHCP on a client or reconnect the network.

On a Linux client:

```bash
# Show DNS servers received from DHCP
resolvectl status
```

Expected idea:

```text
DNS Servers: 192.168.33.101 192.168.33.1
```

Then test DNS:

```bash
# Test normal DNS resolution
dig cloudflare.com

# Test Pi-hole directly
dig @192.168.33.101 cloudflare.com

# Test pfSense fallback directly
dig @192.168.33.1 cloudflare.com
```

Expected:

```text
Pi-hole answers directly.
pfSense answers directly.
Normal DNS resolution works.
```

## Lesson

DHCP tells clients which DNS servers to use, but it does not guarantee perfect failover behavior.

Because client behavior can vary, I keep both Pi-hole and pfSense DNS filtering active.

