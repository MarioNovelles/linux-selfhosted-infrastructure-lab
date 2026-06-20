# Restore Test: Uptime Kuma

This document records a restore test for Uptime Kuma.

## Goal

Test whether I can restore Uptime Kuma from a copied service folder.

This was a cold file-level restore test. I stopped the stack before copying so the MariaDB files were not changing during the backup.

## Test info

```text
Service: Uptime Kuma
Restore method: cold file-level copy
Restore target: /tmp/testing-restore-backups/uptime-kuma
Result: successful
Time verified: Sa 2026-06-20 17:57
Live service affected: only stopped during the test
```

## Steps

```bash
# Stop the Uptime Kuma stack before copying database files
cd /srv/docker/uptime-kuma
docker compose down

# Create the temporary restore-test folder
sudo mkdir -p /tmp/testing-restore-backups

# Copy the full service folder and preserve permissions/ownership/timestamps
sudo cp -a /srv/docker/uptime-kuma /tmp/testing-restore-backups/

# Go to the restored copy
cd /tmp/testing-restore-backups/uptime-kuma

# Check the Compose file before starting
docker compose config

# Start the restored stack
docker compose up -d

# Check container status
docker compose ps
```

## Verification

```text
docker compose config: passed
docker compose up -d: passed
docker compose ps: containers looked healthy
Web UI: opened successfully at http://uptime.lab.local/
Result: restore successful
Verified at: Sa 2026-06-20 17:57
```

## Cleanup

```bash
# Stop the restored test stack
cd /tmp/testing-restore-backups/uptime-kuma
docker compose down

# Remove only the temporary restore-test folder
sudo rm -rf /tmp/testing-restore-backups
```

Before using `rm -rf`, I always check the path carefully.

## What I learned

Copying only the Compose file and `.env` was not enough because my custom Uptime Kuma setup uses MariaDB. The containers could start, but the original application state was missing until the database files (database/) were restored.

For this first restore test, I used a cold file-level copy. This worked because the stack was stopped before copying, so the database files were copied in a consistent state.

For a more advanced future test, I want to learn and document a MariaDB dump/restore method.

## Short summary

I tested a simple restore of Uptime Kuma by stopping the stack, copying the full service folder with `cp -a`, starting the copied stack from a temporary location, and checking the web UI. This proved that the service could be restored with its data when copied cold.

