#!/usr/bin/env bash

# lab-login-summary.sh
#
# Simple login summary for my Linux home lab servers.
#
# I use this script to get a quick overview when I connect over SSH.
# It shows green checks or red Xs so I can quickly see if something needs attention.
#
# This script is intentionally simple.
# It uses basic Bash, Linux commands, and if/else checks.
#
# It does not change anything on the system.
# It only reads information and prints a summary.
#
# To run/test:
# chmod +x scripts/system/lab-login-summary.sh
# ./scripts/system/lab-login-summary.sh
#
# To install in Ubuntu server:
# sudo install -o root -g root -m 755 \
# scripts/system/lab-login-summary.sh \
# /etc/update-motd.d/99-lab-login-summary

# -----------------------------
# Settings for my lab
# -----------------------------

# pfSense LAN gateway (not my real ip, just an example).
GATEWAY_IP="192.168.67.1"

# Public IP used to test internet connectivity.
# This checks internet access without depending on DNS.
INTERNET_IP="1.1.1.1"

# Domain used to test DNS resolution.
DNS_TEST_DOMAIN="cloudflare.com"

# Symbols for quick visual feedback.
OK="✅"
WARN="⚠️"
FAIL="❌"
INFO="ℹ️"

# -----------------------------
# Header
# -----------------------------

echo
echo "----------------------------------------"
echo "Lab Login Summary - $(hostname)"
echo "----------------------------------------"

# -----------------------------
# Basic system information
# -----------------------------

# /etc/os-release contains the Linux distribution name.
# Example: Ubuntu 26.04 LTS
if [ -f /etc/os-release ]; then
  source /etc/os-release
  echo "$INFO  OS: $PRETTY_NAME"
fi

# uname -r shows the running Linux kernel version.
echo "$INFO  Kernel: $(uname -r)"

# uptime -p shows how long the system has been running.
echo "$INFO  Uptime: $(uptime -p)"

# hostname -I shows the IP addresses of the server.
# awk '{print $1}' prints only the first IP address.
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "$INFO  Main IP: $SERVER_IP"

echo

# -----------------------------
# Disk usage
# -----------------------------

# df shows filesystem disk usage.
# Here I check only "/" because it is the main/root filesystem.
#
# awk gets the percentage column.
# tr removes the percent sign, so Bash can compare the number.
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$DISK_USAGE" -ge 90 ]; then
  echo "$FAIL  Disk /: ${DISK_USAGE}% used"
  echo "    Run deeper check: scripts/system/troubleshoot-disk.sh"
elif [ "$DISK_USAGE" -ge 80 ]; then
  echo "$WARN  Disk /: ${DISK_USAGE}% used"
  echo "    Run deeper check: scripts/system/troubleshoot-disk.sh"
else
  echo "$OK  Disk /: ${DISK_USAGE}% used"
fi

# -----------------------------
# Memory usage
# -----------------------------

# free -m shows memory usage in megabytes.
# NR==2 means: read the second line of the output.
# This is simpler than searching for "Mem:" and works better on different systems.
MEM_TOTAL=$(free -m | awk 'NR==2 {print $2}')
MEM_USED=$(free -m | awk 'NR==2 {print $3}')

# Only calculate the percentage if MEM_TOTAL is not empty and not zero.
# This prevents "division by zero" errors.
if [ -z "$MEM_TOTAL" ] || [ "$MEM_TOTAL" -eq 0 ]; then
  echo "$WARN  Memory: could not read memory usage"
else
  MEM_USAGE=$((MEM_USED * 100 / MEM_TOTAL))

  if [ "$MEM_USAGE" -ge 90 ]; then
    echo "$FAIL  Memory: ${MEM_USAGE}% used"
    echo "    Run deeper check: scripts/system/troubleshoot-memory.sh"
  elif [ "$MEM_USAGE" -ge 80 ]; then
    echo "$WARN  Memory: ${MEM_USAGE}% used"
    echo "    Run deeper check: scripts/system/troubleshoot-memory.sh"
  else
    echo "$OK  Memory: ${MEM_USAGE}% used"
  fi
fi

# -----------------------------
# Reboot required
# -----------------------------

# Ubuntu creates this file when installed updates require a reboot.
if [ -f /var/run/reboot-required ]; then
  echo "$WARN  Reboot required: yes"
else
  echo "$OK  Reboot required: no"
fi

# -----------------------------
# Failed systemd services
# -----------------------------

# systemctl --failed lists failed systemd units.
# wc -l counts how many lines were returned.
FAILED_UNITS=$(systemctl --failed --no-legend 2>/dev/null | wc -l)

if [ "$FAILED_UNITS" -gt 0 ]; then
  echo "$FAIL  systemd: $FAILED_UNITS failed unit(s)"
  echo "    Run deeper check: scripts/system/troubleshoot-systemd.sh"
else
  echo "$OK  systemd: 0 failed units"
fi

# -----------------------------
# Docker health
# -----------------------------

# First check if Docker exists on this server.
if command -v docker >/dev/null 2>&1; then

  # docker info checks if the Docker daemon is reachable.
  if docker info >/dev/null 2>&1; then

    # Count running containers.
    RUNNING_CONTAINERS=$(docker ps -q | wc -l)

    # Count unhealthy containers.
    UNHEALTHY_CONTAINERS=$(docker ps --filter health=unhealthy -q | wc -l)

    if [ "$UNHEALTHY_CONTAINERS" -gt 0 ]; then
      echo "$FAIL  Docker: $RUNNING_CONTAINERS running, $UNHEALTHY_CONTAINERS unhealthy"
      echo "    Run deeper check: scripts/docker/troubleshoot-docker-health.sh"
    else
      echo "$OK  Docker: $RUNNING_CONTAINERS running, 0 unhealthy"
    fi

  else
    echo "$WARN  Docker: installed but daemon not reachable"
    echo "    Run deeper check: scripts/docker/troubleshoot-docker-health.sh"
  fi

else
  echo "$INFO  Docker: not installed"
fi

echo

# -----------------------------
# LAN gateway check
# -----------------------------

# ping -c 1 sends one ping packet.
# ping -W 1 waits only one second.
# This keeps the login summary fast.
if ping -c 1 -W 1 "$GATEWAY_IP" >/dev/null 2>&1; then
  echo "$OK  LAN gateway: $GATEWAY_IP reachable"
else
  echo "$FAIL  LAN gateway: $GATEWAY_IP unreachable"
  echo "    Run deeper check: scripts/network/troubleshoot-core-network.sh"
fi

# -----------------------------
# Internet connectivity check
# -----------------------------

# This checks if the server can reach a public IP.
# It does not use DNS, so it only tests basic internet connectivity.
if ping -c 1 -W 1 "$INTERNET_IP" >/dev/null 2>&1; then
  echo "$OK  Internet: $INTERNET_IP reachable"
else
  echo "$FAIL  Internet: $INTERNET_IP unreachable"
  echo "    Run deeper check: scripts/network/troubleshoot-core-network.sh"
fi

# -----------------------------
# DNS resolution check
# -----------------------------

# getent ahosts uses the normal system DNS resolver.
# timeout 2 stops the check after two seconds if DNS is broken.
if timeout 2 getent ahosts "$DNS_TEST_DOMAIN" >/dev/null 2>&1; then
  echo "$OK  DNS: $DNS_TEST_DOMAIN resolves"
else
  echo "$FAIL  DNS: $DNS_TEST_DOMAIN does not resolve"
  echo "    Run deeper check: scripts/network/troubleshoot-dns.sh"
fi

echo

# -----------------------------
# Failed SSH login attempts
# -----------------------------

# journalctl reads system logs.
# This counts failed SSH login attempts from the last 24 hours.
FAILED_SSH=$(journalctl --since "24 hours ago" _COMM=sshd --no-pager 2>/dev/null |
  grep -Ei "Failed password|Invalid user" |
  wc -l)

if [ "$FAILED_SSH" -gt 0 ]; then
  echo "$WARN  Failed SSH logins: $FAILED_SSH in last 24h"
  echo "    Run deeper check: scripts/security/troubleshoot-auth-logins.sh"
else
  echo "$OK  Failed SSH logins: 0 in last 24h"
fi

# -----------------------------
# Failed sudo attempts
# -----------------------------

# This counts failed sudo attempts from the last 24 hours.
FAILED_SUDO=$(journalctl --since "24 hours ago" _COMM=sudo --no-pager 2>/dev/null |
  grep -Ei "authentication failure|incorrect password|user NOT in sudoers" |
  wc -l)

if [ "$FAILED_SUDO" -gt 0 ]; then
  echo "$WARN  Failed sudo attempts: $FAILED_SUDO in last 24h"
  echo "    Run deeper check: scripts/security/troubleshoot-auth-logins.sh"
else
  echo "$OK  Failed sudo attempts: 0 in last 24h"
fi

# -----------------------------
# Footer
# -----------------------------

echo "----------------------------------------"
echo
