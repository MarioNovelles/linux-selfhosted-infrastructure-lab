#!/usr/bin/env bash

# Variables/costants
DRIVE="/dev/sdc2" # drive where jellyfin library is located
SLEEP_TIME="5s" # time to wait for the command to finish loading

# Minimal bash script to mount HDD2, start jellyfin server and jellyfin desktop client

echo "mounting HDD2."
udisksctl mount -b $DRIVE # mounts HDD2
echo "drive mounted, waiting 5 seconds for drive to be ready."
sleep $SLEEP_TIME # waits 5 seconds to let the drive mount well, before jellyfin server is started

echo "drive ready, starting jellyfin server."
nohup flatpak run org.jellyfin.server # starts jellyfin server
echo "jellyfin server started, waiting 5 seconds for it to be ready."
sleep $SLEEP_TIME # waits 5 seconds to let jellyfin server load, before starting the client

echo "jellyfin server ready, starting jellyfin desktop client."
nohup flatpak run com.github.iwalton.jellyfin.desktop.client # starts jellyfin desktop client
echo "Mission Completed!"
