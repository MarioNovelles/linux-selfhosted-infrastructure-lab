# Troubleshooting: Raspberry Pi USB SSD Boot Stalls

## Summary

This note documents a reliability issue with my Raspberry Pi 4B.

The Raspberry Pi sometimes became unreachable. After a forced power cycle, it occasionally needed filesystem repair before it would boot normally again.

The system was running Ubuntu from a USB-connected SSD and was also running multiple Docker containers. During troubleshooting, I found several important clues:

* the root filesystem needed repair after an unclean shutdown
* the USB-SATA adapter was using the `uas` driver
* a root cron job rebooted the Pi every day at 04:30
* kernel RCU stall warnings appeared shortly after boot
* boot-time container startup created noticeable load
* the Pi had been tuned for extra performance, so I returned it to a stock baseline during troubleshooting

The current finding is that the Raspberry Pi showed instability during boot, especially when many services started at the same time.

I do not consider the root cause fully proven yet. The strongest current explanation is that the scheduled daily reboot and heavy startup load were triggering or exposing the instability.

## Symptoms

Observed symptoms:

```text
Raspberry Pi became unreachable
SSH stopped responding
manual power cycle was required
next boot sometimes required fsck
kernel logs showed RCU stall warnings after boot
```

The issue seemed to happen in the early morning. Later, I found that the Pi had a scheduled reboot at 04:30 every day.

## Filesystem recovery

I connected the Raspberry Pi SSD to my laptop with a USB adapter and identified the partitions:

```text
/dev/sdb1  vfat  system-boot
/dev/sdb2  ext4  writable
```

I unmounted both partitions:

```bash
umount /dev/sdb1
umount /dev/sdb2
```

Then I repaired the root filesystem:

```bash
sudo fsck.ext4 -fy /dev/sdb2
```

The repair completed and reported that the filesystem was modified.

I also repaired the boot partition:

```bash
sudo fsck.vfat -a /dev/sdb1
```

The boot partition had the dirty bit set, which confirmed that it had not been cleanly unmounted.

After the repair, I flushed pending writes and safely powered off the USB disk:

```bash
sync
udisksctl power-off -b /dev/sdb
```

After reconnecting the SSD to the Raspberry Pi, the system booted again.

## USB-SATA adapter finding

The SSD was connected through an ASMedia USB-SATA adapter:

```text
idVendor=174c
idProduct=1153
```

The adapter was originally using UAS:

```text
Driver=uas
```

To test whether UAS was contributing to instability, I added this parameter to `/boot/firmware/cmdline.txt`:

```text
usb-storage.quirks=174c:1153:u
```

After rebooting, I verified that the SSD was using `usb-storage` instead of `uas`:

```bash
lsusb -t
```

Expected result:

```text
Driver=usb-storage
```

The kernel also confirmed the quirk:

```text
UAS is ignored for this device, using usb-storage instead
Quirks match for vid 174c pid 1153
```

I kept this change as a stability-focused trade-off for this host.

## Scheduled reboot finding

I checked root cron and found a daily reboot:

```bash
sudo crontab -l
```

The active line was:

```text
30 4 * * * /usr/sbin/reboot
```

I also checked reboot history:

```bash
last -x reboot shutdown | head -20
```

The output showed repeated shutdowns around 04:30 on multiple days.

This matched the time window where kernel RCU stall warnings appeared after boot. The reboot itself was cleanly scheduled, but it caused all services and containers to start again at the same time.

I disabled the daily reboot:

```text
#30 4 * * * /usr/sbin/reboot
```

Scheduled reboots can hide stability problems instead of fixing them. In this case, the reboot likely created a predictable high-load window every morning.

## Performance baseline

During troubleshooting, I returned the Raspberry Pi to a stock performance baseline.

The system had previously been tuned for extra performance because it was running a large number of self-hosted services. Since the issue involved intermittent hangs, filesystem repair after hard power cycles, USB SSD behavior, and kernel RCU stall warnings, I removed non-default performance tuning as part of the troubleshooting process.

The goal was not to blame the tuning immediately. The goal was to reduce variables and test the system under a stable baseline.

Current troubleshooting baseline:

```text
stock Raspberry Pi clock settings
no scheduled daily reboot
USB-SATA adapter using usb-storage instead of UAS
reduced automatic startup for non-critical containers
heavy services planned for migration to ubuntu-docker VM
```

## Container startup load

The Raspberry Pi was running multiple Docker containers.

After boot, many containers started close together. This created a noticeable startup load and coincided with RCU stall warnings.

I stopped several non-critical containers and confirmed they were configured with `unless-stopped`, so they stayed stopped after reboot.

After reducing the startup workload, the system looked calmer:

```text
lower boot load
lower temperature
fewer RCU stall warnings
no under-voltage or throttling flags
```

This did not fully prove the root cause, but it supported the idea that boot-time pressure was contributing to the issue.

## Current working theory

Current working theory:

```text
daily reboot at 04:30
→ many services start at boot
→ high startup load
→ kernel stalls or temporary system hang
→ Pi becomes unreachable
→ forced power cycle
→ dirty filesystem
→ fsck required
```

The USB-SATA UAS behavior may also have contributed, so I kept the UAS workaround in place.

The root cause is not fully proven yet, but the strongest current candidates are:

```text
scheduled daily reboot
heavy container startup load
USB-SATA adapter behavior with UAS
non-default performance tuning
```

## Actions taken

Actions completed:

```text
repaired ext4 root filesystem
repaired vfat boot partition
disabled UAS for the ASMedia USB-SATA adapter
confirmed SSD now uses usb-storage
identified and disabled daily 04:30 reboot
removed non-default performance tuning during troubleshooting
reduced automatic startup for non-critical containers
planned migration of heavier services to ubuntu-docker VM
```

## Long-term plan

The plan is to move most services to the `ubuntu-docker` VM running inside Proxmox and keep the Raspberry Pi for lighter, less critical tasks, like fallback monitoring.

This should reduce:

```text
boot-time load
filesystem repair risk
USB storage dependency
manual recovery work
unexpected service downtime
```

The Raspberry Pi is useful for lightweight tasks, but the Proxmox-based Docker VM is a better long-term place for heavier always-on services.

## Validation

Useful checks after each reboot:

```bash
date
uptime
vcgencmd get_throttled
vcgencmd measure_temp
systemctl --failed
```

Check for new kernel warnings:

```bash
journalctl -k --since "8 hours ago" --no-pager \
  | grep -Ei 'rcu|stall|I/O|sda|usb|reset|timeout|ext4' || true
```

Check reboot history:

```bash
last -x reboot shutdown | head -20
```

Check boot history:

```bash
journalctl --list-boots
```

Check USB storage driver:

```bash
lsusb -t
```

Expected current result:

```text
Driver=usb-storage
```

## Current status

Current status:

```text
filesystem repaired
Raspberry Pi boots again
UAS disabled for USB-SATA adapter
daily reboot disabled
performance baseline returned to stock
container startup load reduced
migration away from Raspberry Pi planned
root cause still being validated
```

The next validation step is to leave the Raspberry Pi running without the scheduled reboot and confirm that it stays online without new filesystem repair events.

References:
## References

* [Raspberry Pi Documentation: `config.txt`](https://www.raspberrypi.com/documentation/computers/config_txt.html)
  I used this as the main reference for Raspberry Pi boot configuration, `cmdline.txt`, `config.txt`, and `vcgencmd` checks.

* [Linux Kernel Documentation: Using RCU's CPU Stall Detector](https://docs.kernel.org/RCU/stallwarn.html)
  This helped me understand what the `rcu_preempt detected expedited stalls` warnings mean.

* [Docker Documentation: Start containers automatically](https://docs.docker.com/engine/containers/start-containers-automatically/)
  I used this to confirm how Docker restart policies such as `always`, `unless-stopped`, and `no` behave.

* [Docker Documentation: Control startup and shutdown order in Compose](https://docs.docker.com/compose/how-tos/startup-order/)
  This was useful for understanding what Docker Compose can and cannot control during service startup.

* [Raspberry Pi Forum: USB SSD and UAS adapter troubleshooting](https://forums.raspberrypi.com/viewtopic.php?t=245931)
  I included this as a community reference because USB-SATA adapter issues on Raspberry Pi systems are often adapter-specific and documented through real troubleshooting examples.

