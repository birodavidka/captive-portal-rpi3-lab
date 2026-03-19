#!/usr/bin/env bash

OUT=~/lab-baseline/report-$(date +%F-%H%M).txt

mkdir -p ~/lab-baseline

{
  echo "===== OS ====="
  cat /etc/os-release
  echo
  uname -a
  echo
  hostnamectl

  echo
  echo "===== MODEL / CPU / RAM ====="
  cat /proc/device-tree/model
  echo
  nproc
  echo
  free -h

  echo
  echo "===== STORAGE ====="
  lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL
  echo
  df -h

  echo
  echo "===== NETWORK ====="
  ip -br a
  echo
  ip r
  echo
  ss -tulpn

  echo
  echo "===== WIFI ====="
  iw dev
  echo
  rfkill list

  echo
  echo "===== FORWARD / FIREWALL ====="
  sysctl net.ipv4.ip_forward
  echo
  sudo nft list ruleset

  echo
  echo "===== SERVICES ====="
  systemctl is-active ssh
  systemctl is-active NetworkManager
  systemctl is-active systemd-networkd
  systemctl is-active wpa_supplicant
  systemctl is-active hostapd
  systemctl is-active dnsmasq
} | tee "$OUT"

echo "Mentve ide: $OUT"