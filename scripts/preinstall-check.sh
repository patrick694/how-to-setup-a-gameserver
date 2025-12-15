#!/usr/bin/env bash
set -euo pipefail

# Pre-installation readiness check for Proxmox nodes
# Checks: running as root, parse config-cluster.env (optional), ping peers,
# /etc/hosts entries, chrony, virtualization flags, IOMMU, disk devices, MTU, SSH key

SCRIPT_NAME="preinstall-check"

info(){ printf "[INFO] %s\n" "$*"; }
warn(){ printf "[WARN] %s\n" "$*"; }
err(){ printf "[ERROR] %s\n" "$*" >&2; }

OK=0
WARN=0

require_root(){
  if [ "$(id -u)" -ne 0 ]; then
    err "This script must be run as root. Use sudo.";
    exit 2
  fi
}

load_config(){
  CONFIG_FILE="/root/gameserver/config-cluster.env"
  if [ -f "$CONFIG_FILE" ]; then
    info "Loading config from $CONFIG_FILE"
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
  else
    info "No config-cluster.env found at $CONFIG_FILE — doing generic checks"
  fi
}

ping_check(){
  local ip=$1
  if ping -c 2 -W 1 "$ip" >/dev/null 2>&1; then
    info "Ping OK: $ip"
    return 0
  else
    warn "Ping failed: $ip"
    WARN=$((WARN+1))
    return 1
  fi
}

hosts_check(){
  local ip=$1 name=$2
  if grep -q -E "^${ip}[[:space:]]+" /etc/hosts; then
    info "/etc/hosts contains $ip"
  else
    warn "/etc/hosts missing entry for $ip ($name)"
    WARN=$((WARN+1))
  fi
}

chrony_check(){
  if systemctl is-active --quiet chrony; then
    info "chrony active"
  else
    warn "chrony not active — install & enable chrony for time sync"
    WARN=$((WARN+1))
  fi
}

virt_check(){
  if grep -Eqi "(vmx|svm)" /proc/cpuinfo; then
    info "CPU virtualization flags found"
  else
    warn "No CPU virtualization flags (vmx/svm) found"
    WARN=$((WARN+1))
  fi
}

iommu_check(){
  if dmesg | grep -qi iommu || grep -q "intel_iommu=on" /proc/cmdline || grep -q "amd_iommu=on" /proc/cmdline; then
    info "IOMMU appears enabled or present"
  else
    warn "IOMMU not detected in dmesg or kernel cmdline (intel_iommu/amd_iommu)"
    WARN=$((WARN+1))
  fi
}

disk_check(){
  # Look for NVMe devices or multiple block devices
  local nvme_count
  nvme_count=$(ls /dev | grep -E '^nvme[0-9]n?[0-9]*' 2>/dev/null | wc -l || true)
  if [ "$nvme_count" -ge 1 ]; then
    info "NVMe devices present: $nvme_count"
  else
    local sd_count
    sd_count=$(ls /dev | grep -E '^sd[a-z]$' 2>/dev/null | wc -l || true)
    if [ "$sd_count" -ge 1 ]; then
      info "Block devices present (sd): $sd_count"
    else
      warn "No NVMe or sd block devices detected — check disks"
      WARN=$((WARN+1))
    fi
  fi
}

mtu_check(){
  # Show interfaces with MTU != 1500 (warn if not 9000 where expected)
  info "Network interfaces and MTU:"
  ip -o link show | awk -F': ' '{print $2}' | while read -r line; do
    ifname=$(echo "$line" | awk '{print $1}');
    mtu=$(ip -o link show "$ifname" | sed -n 's/.*mtu \([0-9]*\).*/\1/p')
    printf "  %s: mtu=%s\n" "$ifname" "$mtu"
  done
}

ssh_key_check(){
  if [ -f /root/.ssh/authorized_keys ]; then
    info "root authorized_keys exists"
  else
    warn "root authorized_keys missing — add your public key for SSH access"
    WARN=$((WARN+1))
  fi
}

summary(){
  echo
  info "Preinstall check finished"
  if [ "$WARN" -eq 0 ]; then
    info "All checks passed (no warnings). Ready for Proxmox installation."
    return 0
  else
    warn "$WARN potential issues found — please review output above and fix before installing Proxmox."
    return 3
  fi
}

main(){
  require_root
  load_config

  info "Running preinstall checks on $(hostname)"

  # virtualization
  virt_check
  iommu_check

  # disks and MTU
  disk_check
  mtu_check

  # time sync
  chrony_check

  # SSH key
  ssh_key_check

  # If config loaded, ping peers and check /etc/hosts
  if [ -n "${NODE1_IP:-}" ]; then
    # iterate nodes 1..5 if set
    for i in 1 2 3 4 5; do
      var=NODE${i}_IP
      ip=${!var:-}
      if [ -n "$ip" ]; then
        ping_check "$ip"
        # derive hostname if present in config (optional)
        host_var=NODE${i}_HOSTNAME
        host=${!host_var:-node${i}}
        hosts_check "$ip" "$host"
      fi
    done
  else
    info "No NODE*_IP variables found in /root/gameserver/config-cluster.env; skipping peer ping/hosts checks"
  fi

  summary
}

main "$@"
