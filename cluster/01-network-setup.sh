#!/bin/bash
###############################################################################
# Network Setup - Proxmox Host Configuration
###############################################################################

source config-cluster.env

echo "🌐 Netwerk configuratie..."

# Backup huidige config
cp /etc/network/interfaces /etc/network/interfaces.backup-$(date +%Y%m%d)

# Bepaal node nummer
NODE_NUM=$(hostname | grep -oP '\d+$' || echo "1")
MGMT_IP="192.168.10.1${NODE_NUM}"
CEPH_IP="192.168.30.1${NODE_NUM}"
GAME_IP="192.168.20.1${NODE_NUM}"

echo "Configuratie voor Node ${NODE_NUM}:"
echo "  • Management: ${MGMT_IP}"
echo "  • Ceph: ${CEPH_IP}"
echo "  • Game: ${GAME_IP}"

# Network config
cat > /etc/network/interfaces << EOFNET
auto lo
iface lo inet loopback

# Management Network (SFP+ Port 1)
auto ens1
iface ens1 inet manual

auto vmbr0
iface vmbr0 inet static
    address ${MGMT_IP}/24
    gateway 192.168.10.1
    bridge-ports ens1.10
    bridge-stp off
    bridge-fd 0
    bridge-vlan-aware yes
    bridge-vids 10 20 30
    dns-nameservers 1.1.1.1 8.8.8.8

# Ceph Storage Network (SFP+ Port 2)
auto ens2
iface ens2 inet manual

auto vmbr1
iface vmbr1 inet static
    address ${CEPH_IP}/24
    bridge-ports ens2.30
    bridge-stp off
    bridge-fd 0
    mtu 9000

# Game Server Network (2.5GbE Port 1)
auto ens3
iface ens3 inet manual

auto vmbr2
iface vmbr2 inet static
    address ${GAME_IP}/24
    bridge-ports ens3.20
    bridge-stp off
    bridge-fd 0
EOFNET

echo "✅ Netwerk configuratie geschreven"
echo ""
echo "⚠️  Reboot vereist!"
echo "Voer uit: reboot"
echo ""
echo "Backup: /etc/network/interfaces.backup-$(date +%Y%m%d)"
