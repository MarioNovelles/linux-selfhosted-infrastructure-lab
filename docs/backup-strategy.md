# Backup Strategy

This document explains how I think about backups in my lab.

My main rule is:

> A backup is not proven until I have tested the restore.

This is a lab backup strategy, not an enterprise backup policy.

## What I want to protect

| Data                       | Importance | Notes                              |
| -------------------------- | ---------- | ---------------------------------- |
| personal documents         | critical   | must not depend on one disk/server |
| photos and important files | critical   | needs more than one backup         |
| password manager data      | critical   | must be backed up privately        |
| Docker Compose files       | high       | needed to rebuild services         |
| private `.env` files       | high       | not stored in Git                  |
| service databases          | high       | may need database dumps            |
| media files                | medium     | useful, but less critical          |
| cache/downloads            | low        | can usually be recreated           |

## Backup layers

| Layer                  | Purpose                                     |
| ---------------------- | ------------------------------------------- |
| Proxmox Backup Server  | restore full VMs or containers              |
| TrueNAS snapshots      | recover from file changes or deletion       |
| Docker Compose files   | rebuild services                            |
| private config backups | restore `.env` files and secrets            |
| database dumps         | restore application data                    |
| off-machine backup     | protect important data if one machine fails |

## Important lesson

RAID or RAIDZ is not a backup.

RAID can help when a disk fails, but it does not protect me from accidental deletion, broken updates, wrong commands, ransomware, theft, or fire.

That is why I need backups and restore tests.

## Docker service checklist

For each important Docker service, I should know:

```textService:
Compose file:
Data folder:
Database:
Secrets:
Backup method:
Restore steps:
Restore tested:
```

## Example commands

Example for a simple Docker service folder:

```bash# Create a backup folder
mkdir -p ~/backups/example-service

# Copy service data and keep permissions/timestamps
rsync -a /srv/docker/example-service/data/ ~/backups/example-service/data/

# Copy the Compose file
cp /srv/docker/example-service/compose.yml ~/backups/example-service/
```

If the service uses a database, I may also need a database dump.

```bash# Example pattern: replace container, user, and database name
docker exec <database-container> \
  mariadb-dump -u <database-user> -p <database-name> > <database-name>.sql
```

I do not commit `.env` files or database dumps to Git.

## Restore test checklist

When I test a restore, I should write down:

```textService:
Backup source:
Restore target:
Date:
Result:
What worked:
What failed:
What I learned:
```

A good restore test should answer:

* Can the service start?
* Can I log in?
* Is the expected data there?
* Are permissions correct?
* Did I avoid touching the live service?

## Current status

Implemented or documented:

* Proxmox Backup Server for VM backups
* TrueNAS snapshots for storage rollback
* Docker Compose files stored in Git without secrets
* private secrets kept outside the public repository

Still improving:

* more restore tests
* better per-service backup notes
* clearer database backup notes
* off-site/offline backup for the most important data

## Short summary

My backup approach is layered. I do not rely only on RAID or snapshots. I document service configuration, keep secrets outside Git, and want to test restores because backups only matter if I can restore from them.

