#!/bin/bash
###############################################################################
# Ceph Storage Setup
###############################################################################

source config-cluster.env

echo "🗄️  Ceph storage configuratie..."

# Install Ceph
echo "📦 Ceph installeren..."
pveceph install --version quincy

# Initialize Ceph
echo "⚙️  Ceph initialiseren..."
pveceph init --network 192.168.30.0/24 --cluster-network 192.168.30.0/24

# Create first monitor (on Node 1)
echo "📡 Monitor aanmaken..."
pveceph mon create

# Create manager
echo "📊 Manager aanmaken..."
pveceph mgr create

echo ""
echo "✅ Ceph basis aangemaakt!"
echo ""
echo "📝 Volgende stappen:"
echo "   1. Op ELKE andere node (2-5): pveceph mon create"
echo "   2. Op Node 1-3: pveceph mgr create"
echo "   3. Op ELKE node: pveceph osd create /dev/nvme0n1"
echo ""
echo "4. Wacht tot ceph -s toont: health HEALTH_OK"
echo "5. Voer uit: pveceph pool create ceph-vms --add_storages"
echo ""

# Show current status
echo "📊 Huidige Ceph status:"
ceph -s || echo "Ceph nog niet volledig geinitialiseerd"
