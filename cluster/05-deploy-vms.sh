#!/bin/bash
###############################################################################
# Deploy Game Server VMs
###############################################################################

source config-cluster.env

echo "🎮 Game Server VMs deployen..."

TEMPLATE_ID="${TEMPLATE_VMID:-9000}"
STORAGE="${VM_STORAGE:-local-lvm}"

deploy_vm() {
    local VMID=$1
    local NAME=$2
    local IP=$3
    local CORES=$4
    local RAM=$5
    local DISK=$6
    
    echo "  → Deploying $NAME (VMID: $VMID, IP: $IP)..."
    
    # Clone from template
    qm clone $TEMPLATE_ID $VMID \
        --name "$NAME" \
        --full \
        --storage "$STORAGE" 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo "  ❌ Clone mislukt!"
        return 1
    fi
    
    # Configure
    qm set $VMID \
        --cores $CORES \
        --memory $RAM \
        --balloon 0 \
        --onboot 1
    
    # Resize disk
    qm resize $VMID scsi0 ${DISK}G
    
    # Network
    qm set $VMID \
        --ipconfig0 ip=${IP}/24,gw=192.168.20.1 \
        --nameserver "1.1.1.1 8.8.8.8"
    
    echo "  ✅ $NAME deployed"
    return 0
}

# Deploy VMs
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "PANEL VM"
echo "═══════════════════════════════════════════════════════════════"

deploy_vm 100 "pterodactyl-panel" "192.168.20.10" 4 8192 80

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "GAME NODE VMs"
echo "═══════════════════════════════════════════════════════════════"

# Nodes 2-4
for i in {1..3}; do
    VMID=$((200 + i))
    IP="192.168.20.$((20 + i))"
    deploy_vm $VMID "game-node-$i" "$IP" 8 16384 150
done

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "MONITORING VM"
echo "═══════════════════════════════════════════════════════════════"

deploy_vm 300 "monitoring" "192.168.20.90" 4 8192 100

echo ""
echo "✅ Alle VMs gedeployed!"
echo ""
echo "📋 VM Overzicht:"
qm list
echo ""
echo "🚀 VMs starten:"
echo "   qm start 100"
echo "   qm start 201"
echo "   qm start 202"
echo "   qm start 203"
echo "   qm start 300"
