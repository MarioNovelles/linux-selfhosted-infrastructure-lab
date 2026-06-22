# Troubleshooting: `grub2-common.service` Failed Unit

This document records a real troubleshooting case from my lab where monitoring reported one failed `systemd` unit.

The failed unit was:

```text
grub2-common.service - Record successful boot for GRUB
```

## Alert

The monitoring alert showed:

```text
systemd: 1 failed unit(s)
```

On the server, I confirmed it with:

```bash
# Show failed systemd units
systemctl --failed
```

Output:

```text
UNIT                 LOAD   ACTIVE SUB    DESCRIPTION
grub2-common.service loaded failed failed Record successful boot for GRUB
```

## Check the failed unit

I checked the service status:

```bash
# Show detailed status for the failed unit
systemctl status grub2-common.service --no-pager -l
```

Important error:

```text
grub-editenv: error: cannot read `/boot/grub/grubenv': Invalid argument
```

The failed command was:

```text
grub-editenv /boot/grub/grubenv unset recordfail
```

This showed that the system was not failing because an application service was down.

The failure was related to GRUB trying to update its environment file after a successful boot.

## Check the service logs

I checked the logs for the unit:

```bash
# Show recent logs for the failed unit
journalctl -u grub2-common.service -n 80 --no-pager
```

The logs showed that this had happened before:

```text
grub-editenv: error: invalid environment block
grub-editenv: error: cannot read `/boot/grub/grubenv': Invalid argument
```

This pointed to a problem with:

```text
/boot/grub/grubenv
```

## Cause

The likely cause was a corrupted or unreadable GRUB environment block.

`grubenv` is used by GRUB to store small boot-related variables, such as whether the last boot was successful.

The server itself had booted successfully, but `grub2-common.service` failed because it could not read or update the GRUB environment file.

## Fix

First, I checked the file:

```bash
# Check the grubenv file
ls -lah /boot/grub/grubenv

# Try to read it with the GRUB tool
sudo grub-editenv /boot/grub/grubenv list
```

Then I backed up the broken file:

```bash
# Back up the broken grubenv file before replacing it
sudo cp -a /boot/grub/grubenv /boot/grub/grubenv.broken.$(date +%F-%H%M%S)
```

Then I recreated it:

```bash
# Remove the broken GRUB environment block
sudo rm -f /boot/grub/grubenv

# Create a clean GRUB environment block
sudo grub-editenv /boot/grub/grubenv create
```

After recreating the file, I restarted the failed unit:

```bash
# Restart the failed unit
sudo systemctl restart grub2-common.service
```

## Validate the fix

I checked the service again:

```bash
# Check service status
systemctl status grub2-common.service --no-pager -l
```

Expected result:

```text
Active: inactive (dead)
code=exited, status=0/SUCCESS
```

The service completed successfully:

```text
Finished grub2-common.service - Record successful boot for GRUB.
```

Then I checked failed units again:

```bash
# Confirm no failed units remain
systemctl --failed
```

Expected result:

```text
0 loaded units listed.
```

## Disk health check

Because the issue involved a file under `/boot`, I also checked the disk.

First, I identified the disk:

```bash
# Show disks and mount points
lsblk
```

The system disk was:

```text
/dev/sda
```

I installed SMART tools:

```bash
# Install SMART monitoring tools
sudo apt update
sudo apt install smartmontools
```

Then I checked disk health:

```bash
# Show full SMART report
sudo smartctl -a /dev/sda

# Show quick SMART health result
sudo smartctl -H /dev/sda
```

Important results:

```text
SMART overall-health self-assessment test result: PASSED
Reallocated_Sector_Ct: 0
Reported_Uncorrect: 0
CRC_Error_Count: 0
No Errors Logged
```

I also ran a short SMART self-test:

```bash
# Start a short SMART self-test
sudo smartctl -t short /dev/sda
```

After a few minutes:

```bash
# Check SMART self-test results
sudo smartctl -l selftest /dev/sda
```

Result:

```text
Short offline Completed without error
```

This suggested the SSD was healthy and the `grubenv` issue was not caused by an obvious disk failure.

## Kernel log check

I checked for disk or filesystem errors:

```bash
# Look for serious disk or filesystem errors
journalctl -k --no-pager | grep -Ei 'I/O error|filesystem error|ext4.*error|sda.*error|ata.*error|reset|timeout' || true
```

There were no disk or filesystem errors related to `/dev/sda`.

## Unrelated PCIe warning

The kernel logs showed PCIe AER messages:

```text
PCIe Bus Error: severity=Correctable
device [10ec:5229]
```

I identified the device:

```bash
# Identify the PCIe device
lspci -nn -s 02:00.0
```

Result:

```text
Realtek Semiconductor Co., Ltd. RTS5229 PCI Express Card Reader [10ec:5229]
```

This is the built-in card reader.

Because this is a server and I do not use the card reader, I treated this as low priority.

Current decision:

```text
No action needed unless the warnings become noisy or cause problems.
If it keeps happening, check UEFI/BIOS for an option to disable the card reader.
```

I did not blacklist drivers or add kernel parameters because the warning was correctable and unrelated to the SSD health check.

## Final result

The original failed unit was fixed.

Validation:

```text
grub2-common.service: success
systemctl --failed: 0 failed units
SMART health: passed
SMART short test: completed without error
No disk/filesystem errors found
Realtek card reader warning: unrelated and low priority
```

## Lesson learned

A failed `systemd` unit does not always mean an application service is broken.

In this case, the server booted correctly, but GRUB could not update its environment file.

The troubleshooting path was:

```text
Monitoring alert
→ systemctl --failed
→ systemctl status
→ journalctl logs
→ identify failing command
→ repair corrupted grubenv
→ restart service
→ verify systemd is clean
→ check disk health
→ separate real issue from unrelated hardware warnings
```

This was a useful reminder to troubleshoot in layers instead of assuming the first scary log line is the root cause.

