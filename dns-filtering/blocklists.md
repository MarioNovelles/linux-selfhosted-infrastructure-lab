# DNS Blocklists

This document tracks public DNS blocklists used or evaluated in my lab.

DNS blocklists help reduce access to advertising, tracking, telemetry, phishing, malware, suspicious, and unwanted domains. They are used carefully because overly aggressive blocking can cause false positives and break normal browsing.

The initial feed selection is based on the Firebog / Wally3k blocklist collection, then adjusted for my own lab based on reliability, false positives, and usability.

## Filtering Approach

Earlier in the lab, I experimented with very aggressive DNS filtering by enabling many blocklists and broad regex rules. This blocked more unwanted traffic, but it also made normal internet use harder because of false positives, broken websites, and extra troubleshooting.

I now prefer a smaller, more reliable set of blocklists and carefully reviewed regex rules. The goal is to reduce ads, tracking, malicious domains, and unwanted services while keeping the network usable for normal daily browsing and self-hosted services.

## Suspicious Lists

- `https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt`
- `https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts`
- `https://v.firebog.net/hosts/static/w3kbl.txt`

## Advertising Lists

- `https://adaway.org/hosts.txt`
- `https://v.firebog.net/hosts/AdguardDNS.txt`
- `https://v.firebog.net/hosts/Admiral.txt`
- `https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt`
- `https://v.firebog.net/hosts/Easylist.txt`
- `https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext`
- `https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts`
- `https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts`
- `https://easylist.to/easylistgermany/easylistgermany.txt`
- `https://easylist-downloads.adblockplus.org/easylistspanish.txt`

## Tracking and Telemetry Lists

- `https://v.firebog.net/hosts/Easyprivacy.txt`
- `https://v.firebog.net/hosts/Prigent-Ads.txt`
- `https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts`
- `https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt`
- `https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt`

## Malicious Lists

- `https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt`
- `https://v.firebog.net/hosts/Prigent-Crypto.txt`
- `https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts`
- `https://phishing.army/download/phishing_army_blocklist_extended.txt`
- `https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt`
- `https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt`
- `https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts`
- `https://urlhaus.abuse.ch/downloads/hostfile/`
- `https://lists.cyberhost.uk/malware.txt`

## Other Lists

- `https://raw.githubusercontent.com/chadmayfield/my-pihole-blocklists/master/lists/pi_blocklist_porn_top1m.list`

## Language-Specific Filter Lists

These lists are included because I sometimes browse German- and Spanish-language websites and want DNS filtering to cover region/language-specific advertising and tracking patterns.

Some of these feeds originate from browser/adblocker filter ecosystems, but they are available through pfBlockerNG feeds and can be evaluated for DNSBL use in the lab.

- `https://easylist.to/easylistgermany/easylistgermany.txt` — German-language EasyList filter feed
- `https://easylist-downloads.adblockplus.org/easylistspanish.txt` — Spanish-language EasyList filter feed

These lists should be tested carefully because language-specific filters may create false positives or include rules that are only partially useful at the DNS level.


## Notes

Blocklists should be reviewed periodically. Unmaintained, noisy, duplicated, or overly aggressive lists should be removed instead of blindly kept enabled.

DNS filtering is treated as one layer of defense, not a complete security solution. It should be combined with firewall policy, patching, segmentation, monitoring, and backup planning.

## Source / Reference

Many of these DNS blocklist categories and feed selections are based on the Firebog / Wally3k blocklist collection.

- Firebog / Wally3k blocklists: `https://firebog.net/`

