#!/bin/bash
###############################################################################
# Create VM Templates
###############################################################################

source config-cluster.env

echo "🖼️  VM templates aanmaken..."

TEMPLATE_ID="${TEMPLATE_VMID:-9000}"
UBUNTU_IMG="/var/lib/vz/template/iso/ubuntu-22.04-cloudimg-amd64.img"

# Check if image exists
if [ ! -f "$UBUNTU_IMG" ]; then
    echo "📥 Ubuntu cloud image downloaden..."
    cd /var/lib/vz/template/iso
    
    wget -q --show-progress \
        "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img" \
        -O ubuntu-22.04-cloudimg-amd64.img
    
    if [ $? -ne 0 ]; then
        echo "❌ Download mislukt!"
        exit 1
    fi
fi

# Create template VM
echo "🔧 Template VM aanmaken (ID: $TEMPLATE_ID)..."

# Destroy if exists
qm destroy $TEMPLATE_ID 2>/dev/null || true
sleep 2

# Create
qm create $TEMPLATE_ID \
    --name "ubuntu-22.04-template" \
    --memory 2048 \
    --cores 2 \
    --net0 virtio,bridge=vmbr0 \
    --serial0 socket \
    --vga serial0

# Import disk
echo "📀 Disk importeren..."
qm importdisk $TEMPLATE_ID ubuntu-22.04-cloudimg-amd64.img local-lvm

# Attach disk
qm set $TEMPLATE_ID \
    --scsihw virtio-scsi-pci \
    --scsi0 local-lvm:vm-${TEMPLATE_ID}-disk-0

# Cloud-init drive
qm set $TEMPLATE_ID --ide2 local-lvm:cloudinit

# Boot settings
qm set $TEMPLATE_ID \
    --boot c \
    --bootdisk scsi0 \
    --agent enabled=1

# Convert to template
qm template $TEMPLATE_ID

echo "✅ Template aangemaakt!"
echo ""
echo "Template ID: $TEMPLATE_ID"
echo "Naam: ubuntu-22.04-template"
echo "Storage: local-lvm"
echo ""
echo "Nu kunnen VMs gekloneerd worden van dit template."
