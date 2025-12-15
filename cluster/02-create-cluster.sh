#!/bin/bash
###############################################################################
# Create Proxmox Cluster
###############################################################################

source config-cluster.env

echo "👥 Proxmox cluster aanmaken..."

CLUSTER_NAME="${CLUSTER_NAME:-gameserver-cluster}"
MGMT_IP="192.168.10.11"

# Check if cluster exists
if pvesh get /cluster/status --noborder 2>/dev/null | grep -q "cluster"; then
    echo "⚠️  Cluster bestaat al"
    pvecm status
    exit 0
fi

echo "Cluster naam: $CLUSTER_NAME"
echo "Master node IP: $MGMT_IP"

# Create cluster
pvecm create "$CLUSTER_NAME" --link0 "$MGMT_IP"

# Wait for initialization
sleep 5

echo ""
echo "✅ Cluster aangemaakt!"
echo ""

# Show status
pvecm status

echo ""
echo "📝 Volgende stappen:"
echo "   1. Voer op ELKE andere node (2-5) uit:"
echo "      pvecm add $MGMT_IP"
echo "   2. Voer root wachtwoord in en bevestig fingerprint"
echo "   3. Wacht ~30 seconden per node"
echo ""
echo "Verificatie (later):"
echo "   pvecm status  # Moet tonen: Nodes: 5, Quorate: Yes"
