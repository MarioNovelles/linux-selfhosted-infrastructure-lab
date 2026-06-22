# Disable IPv6 on pfSense

This runbook documents how I disable IPv6 in the lab when IPv6 is not part of the current network design.

The goal is not only to block IPv6 traffic.

The goal is to avoid accidentally advertising, assigning, routing, or allowing IPv6 in the lab.

## Why IPv6 is disabled

This lab currently uses an IPv4-only network design.

DNS filtering, firewall rules, DHCP, and troubleshooting notes are all based on the IPv4 LAN.

```text
LAN clients
→ Pi-hole + Unbound
→ pfSense fallback DNS
→ IPv4 firewall and DNS enforcement rules
```

If IPv6 is left partially enabled, clients may receive IPv6 router or DNS information and bypass the intended IPv4 filtering path.

Because of that, IPv6 is intentionally disabled until I decide to design and document it properly.

## Important distinction

In pfSense, disabling `Allow IPv6` is not the same as fully disabling IPv6 features.

`Allow IPv6` controls whether IPv6 traffic is allowed through the firewall.

It does not remove IPv6 configuration from interfaces, DHCPv6, Router Advertisements, VPNs, tunnels, or packages.

Because of that, I disable IPv6 in multiple places.

## Backup first

Before changing firewall settings, I export the pfSense configuration.

```text
Diagnostics
→ Backup & Restore
→ Download configuration
```

This gives me a rollback point if I make a mistake.

## Disable IPv6 on WAN

Go to:

```text
Interfaces
→ WAN
```

Set:

```text
IPv6 Configuration Type: None
```

Then save and apply changes.

## Disable IPv6 on LAN and internal interfaces

For each internal interface:

```text
Interfaces
→ LAN
Interfaces
→ VLAN / OPT interfaces
```

Set:

```text
IPv6 Configuration Type: None
```

I repeat this for every interface where IPv6 should not be used.

Examples:

```text
LAN:       IPv6 Configuration Type: None
SERVERS:   IPv6 Configuration Type: None
IOT:       IPv6 Configuration Type: None
GUEST:     IPv6 Configuration Type: None
```

## Disable Router Advertisements

Router Advertisements can tell clients about IPv6 routers, prefixes, and DNS information.

Since IPv6 is not used in this lab, Router Advertisements should be disabled.

Go to:

```text
Services
→ Router Advertisement
```

For each internal interface, set:

```text
Router Mode: Disabled
```

Then save and apply changes.

## Disable DHCPv6 Server

DHCPv6 can give clients IPv6 addressing and network configuration.

Go to:

```text
Services
→ DHCPv6 Server
```

For each interface, make sure DHCPv6 is not enabled.

## Remove IPv6 gateways and routes

Check for IPv6 gateways:

```text
System
→ Routing
→ Gateways
```

Remove or disable IPv6 gateways that are not intentionally used.

Then check static routes:

```text
System
→ Routing
→ Static Routes
```

Remove IPv6 static routes if any exist.

## Disable IPv6 traffic as a final safety layer

After IPv6 configuration is removed from interfaces and services, I also disable IPv6 passing through the firewall.

Go to:

```text
System
→ Advanced
→ Networking
```

Uncheck:

```text
Allow IPv6
```

Then save and apply changes.

This is the final safety layer.

It should not be the only IPv6 change.

## Check VPNs, tunnels, and packages

I also check anything that may create or advertise IPv6 routes.

Examples:

```text
VPN
→ WireGuard

VPN
→ OpenVPN

Services
→ Tailscale

Interfaces
→ Assignments
→ GIF / GRE

Firewall
→ NAT
→ NPt
```

For this lab, I do not intentionally advertise IPv6 routes through VPNs or Tailscale.

If IPv6 is added later, it should be documented as a separate design decision.

## Validation

After applying the settings, I check pfSense interfaces:

```text
Status
→ Interfaces
```

Expected result:

```text
WAN: no IPv6 address or IPv6 prefix
LAN: no IPv6 address or IPv6 prefix
Internal interfaces: no IPv6 address or IPv6 prefix
```

I also check that these services are not active for internal interfaces:

```text
Router Advertisements: Disabled
DHCPv6 Server: Disabled
IPv6 gateways/routes: Removed or disabled
Allow IPv6: Unchecked
```

On a LAN client, I check that it is not receiving IPv6 DNS or router information from pfSense.

Examples:

```bash
ip -6 addr
ip -6 route
resolvectl status
```

Link-local IPv6 addresses such as `fe80::...` may still appear on client operating systems.

The important part for this lab is that pfSense is not assigning IPv6 prefixes, advertising IPv6 router information, or allowing IPv6 forwarding through the firewall.

## Intended final state

```text
WAN IPv6 Configuration Type: None
LAN/VLAN IPv6 Configuration Type: None
Router Advertisements: Disabled
DHCPv6 Server: Disabled
IPv6 gateways/routes: Removed
IPv6 VPN/tunnel routes: Not used
Allow IPv6: Unchecked
```

## DNS filtering note

This matters for DNS filtering because the lab DNS design is IPv4-based.

```text
Primary DNS:
  Pi-hole + Unbound

Fallback DNS:
  pfSense DNS Resolver + pfBlockerNG DNSBL
```

If IPv6 was accidentally advertised to clients, they could use IPv6 DNS or IPv6 connectivity outside the intended filtering path.

Disabling IPv6 keeps the DNS filtering behavior predictable.

## Lesson learned

Blocking IPv6 traffic is only one part of the job.

For an IPv4-only lab, I also need to disable IPv6 configuration, DHCPv6, Router Advertisements, IPv6 gateways, and accidental IPv6 routes from packages or tunnels.

If I want IPv6 in the future, I should design it intentionally instead of letting it exist as an undocumented bypass path.

## References

- [Netgate pfSense Documentation — Advanced Networking](https://docs.netgate.com/pfsense/en/latest/config/advanced-networking.html) — reference for the `Allow IPv6` setting and the important note that it controls IPv6 traffic flow but does not disable IPv6 functions or prevent IPv6 from being configured.
- [Netgate pfSense Documentation — Interface Configuration](https://docs.netgate.com/pfsense/en/latest/config/interface-configuration.html) — reference for setting an interface IPv6 Configuration Type to `None`.
- [Netgate pfSense Documentation — IPv6 Configuration Types](https://docs.netgate.com/pfsense/en/latest/interfaces/configure-ipv6.html) — reference for how pfSense assigns or disables IPv6 configuration on interfaces.
- [Netgate pfSense Documentation — IPv6 Router Advertisements](https://docs.netgate.com/pfsense/en/latest/services/dhcp/ipv6-ra.html) — reference for Router Advertisement settings and DNS advertisement behavior.
- [Netgate pfSense Documentation — DHCPv6 Server](https://docs.netgate.com/pfsense/en/latest/services/dhcp/ipv6.html) — reference for DHCPv6 assigning IPv6 addresses and network configuration to clients.
