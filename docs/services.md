# Services

This document explains how I document services in my homelab.

The goal is not only to know which tools are running. I also want to know where a service runs, how it is accessed, where its data is, and how I would recover it.

## Service checklist

For every important service, I try to document:

```textService:
Purpose:
Where it runs:
Access method:
Data location:
Backup method:
Restore tested:
Monitoring:
Security notes:
```

## Questions I ask

When I add or review a service, I ask:

```textDoes this service need to be exposed?
Where is the data stored?
Does it use a database?
How is it backed up?
How would I restore it?
How do I know if it is down?
```

## Example: Uptime Kuma

```textService: Uptime Kuma
Purpose: monitor important lab services
Where it runs: Docker Compose
Access method: private access
Data location: Docker volume or bind mount
Backup method: service data backup + VM backup layer
Restore tested: still improving
Monitoring: monitors other services, but should also be checked itself
Security notes: admin access should not be public
```

## Current status

Implemented or documented:

* main services are listed in the README
* Docker Compose architecture is documented
* DNS and monitoring services are documented
* backup notes are being improved

Still improving:

* per-service restore notes
* clearer data-location notes
* more service-specific backup tests

## Short summary

I document services so I can understand how they run, how they are accessed, where their data is, and how I would recover them. I do not want the lab to be only a list of tools; I want it to be understandable and maintainable.

