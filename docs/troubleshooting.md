### DNS troubleshooting path

If DNS resolution fails:

1. Check whether the client received the correct DNS servers from DHCP.
2. Test Pi-hole directly: `dig @192.168.33.53 cloudflare.com`
3. Test Unbound locally from the DNS VM: `dig @127.0.0.1 -p 5335 cloudflare.com`
4. Test fallback DNS through pfSense: `dig @192.168.33.1 cloudflare.com`
5. Check Pi-hole and Unbound service status.
