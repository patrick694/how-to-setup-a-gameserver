#!/bin/bash
###############################################################################
# High Availability Setup
###############################################################################

source config-cluster.env

echo "🔄 High Availability configureren..."

# Check quorum
NODE_COUNT=$(pvesh get /cluster/resources --type node 2>/dev/null | jq -r '.[] | select(.type=="node")' | wc -l)

if [ $NODE_COUNT -lt 3 ]; then
    echo "⚠️  HA vereist minimaal 3 nodes voor quorum"
    echo "   Huidige nodes: $NODE_COUNT"
    echo "   Setup HA later als alle nodes online zijn"
    exit 0
fi

echo "✅ $NODE_COUNT nodes beschikbaar - HA kan ingesteld worden"

# Create HA groups
echo ""
echo "👥 HA groups aanmaken..."

# Get node names
NODE_NAMES=$(pvecm nodes | grep -v "^Name" | awk '{print $3}' | tr '\n' ',' | sed 's/,$//')
IFS=',' read -ra NODES <<< "$NODE_NAMES"

if [ ${#NODES[@]} -ge 3 ]; then
    # Critical group (panel, monitoring)
    ha-manager groupadd critical \
        --nodes "${NODES[0]}:3,${NODES[1]}:2,${NODES[2]}:1" \
        --comment "Critical services - Panel & Monitoring" 2>/dev/null || true
    
    # Production group (game servers)
    if [ ${#NODES[@]} -ge 4 ]; then
        ha-manager groupadd production \
            --nodes "${NODES[1]}:3,${NODES[2]}:3,${NODES[3]}:2" \
            --comment "Production game servers" 2>/dev/null || true
    fi
    
    # Standard group
    if [ ${#NODES[@]} -ge 5 ]; then
        ha-manager groupadd standard \
            --nodes "${NODES[2]}:2,${NODES[3]}:2,${NODES[4]}:2" \
            --comment "Standard game servers" 2>/dev/null || true
    fi
fi

echo "✅ HA groups aangemaakt"

# Add VMs to HA (interactive)
echo ""
read -p "VMs naar HA groups toevoegen? [y/N]: " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Beschikbare VMs:"
    qm list | head -10
    
    echo ""
    echo "VM IDs voor HA (komma gescheiden, bijv: 100,201,202):"
    read -p "VMs: " VM_IDS
    
    IFS=',' read -ra VMS <<< "$VM_IDS"
    for VMID in "${VMS[@]}"; do
        VMID=$(echo $VMID | xargs)
        
        echo ""
        echo "VM $VMID:"
        echo "  [1] critical"
        echo "  [2] production"
        echo "  [3] standard"
        read -p "  Keuze [1-3]: " GROUP_CHOICE
        
        case $GROUP_CHOICE in
            1) GROUP="critical" ;;
            2) GROUP="production" ;;
            3) GROUP="standard" ;;
            *) GROUP="standard" ;;
        esac
        
        ha-manager add vm:$VMID \
            --group $GROUP \
            --state started \
            --max_restart 3 \
            --max_relocate 3 2>/dev/null
        
        echo "  ✅ VM $VMID → $GROUP"
    done
fi

echo ""
echo "✅ HA configuratie compleet!"
echo ""
echo "📊 HA Status:"
ha-manager status
echo ""
echo "🔍 HA Config:"
ha-manager config
