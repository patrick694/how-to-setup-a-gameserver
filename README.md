# 🚀 Proxmox Gameserver Cluster Setup
## Professional Infrastructure voor 5× MS-01 Nodes

Dit is een complete, geautomatiseerde setup guide voor een production-grade gameserver cluster op basis van Proxmox VE en 5× MS-01 hardware nodes.

## 📋 Inhoudsopgave

1. [Hardware Overzicht](#hardware)
2. [Snelstart](#snelstart)
3. [Volledige Installatie](#volledige-installatie)
4. [Troubleshooting](#troubleshooting)

---

## Hardware

### Per Node (MS-01)
- **CPU**: Intel i9-12900H (14 cores, 20 threads, 5.0GHz)
- **RAM**: 32GB DDR5-4800
- **Storage**: 1TB NVMe M.2 2280
- **Network**: 2× 10G SFP+ + 2× 2.5GbE
- **Form Factor**: 20×20×6cm
- **Power**: 65W typical, 120W max

### Cluster Totaal
- **CPU**: 70 cores / 100 threads
- **RAM**: 160GB (140GB usable)
- **Storage**: 5TB (3TB usable with Ceph replication)
- **Network**: 50Gbit+ aggregate

---

## Snelstart

### Vereisten
- ✅ 5× MS-01 nodes met Proxmox VE 8.1 geïnstalleerd
- ✅ Netwerk switch (10G SFP+, VLAN support)
- ✅ Ethernet kabels
- ✅ SSH access naar Node 1

### Quick Installation (Node 1)

```bash
# Download setup
ssh root@192.168.10.11
cd /root
git clone https://github.com/jouw-repo/gameserver-cluster.git
cd gameserver-cluster

# Copy en pas configuratie aan
cp config-cluster.env.example config-cluster.env
nano config-cluster.env  # Wijzig IP adressen

# Start installer
chmod +x install-cluster.sh
./install-cluster.sh
```

⏱️ **Totale setup tijd**: ~3-4 uur

---

## Volledige Installatie

### FASE 1: Netwerk Configuratie (30 min)

#### 1.1 Fysieke Bekabeling
```
STOP! Schakel alle nodes UIT voordat je kabels aansluit.

Per Node:
  • Port 1 (SFP+ #1)  → 10G Switch [Management + Corosync]
  • Port 2 (SFP+ #2)  → 10G Switch [Ceph Storage]
  • Port 3 (2.5GbE)   → Router [Game Traffic]
```

#### 1.2 IP Addressing Plan

```
Management Network (VLAN 10): 192.168.10.0/24
├─ Gateway:      192.168.10.1
├─ Node 1:       192.168.10.11
├─ Node 2:       192.168.10.12
├─ Node 3:       192.168.10.13
├─ Node 4:       192.168.10.14
└─ Node 5:       192.168.10.15

Game Network (VLAN 20): 192.168.20.0/24
├─ Gateway:      192.168.20.1
└─ VMs:          192.168.20.10-250

Ceph Network (VLAN 30): 192.168.30.0/24
├─ Node 1:       192.168.30.11
├─ Node 2:       192.168.30.12
├─ Node 3:       192.168.30.13
├─ Node 4:       192.168.30.14
└─ Node 5:       192.168.30.15
```

#### 1.3 Netwerk Configuratie (Node 1)

```bash
ssh root@192.168.10.11

# Backup huidige config
cp /etc/network/interfaces /etc/network/interfaces.backup

# Nieuwe configuratie
cat > /etc/network/interfaces << 'EOF'
auto lo
iface lo inet loopback

# Management Bridge (VLAN 10)
auto vmbr0
iface vmbr0 inet static
    address 192.168.10.11/24
    gateway 192.168.10.1
    bridge-ports ens1.10
    bridge-stp off
    bridge-fd 0
    bridge-vlan-aware yes
    dns-nameservers 1.1.1.1 8.8.8.8

# Ceph Storage Network (VLAN 30)
auto vmbr1
iface vmbr1 inet static
    address 192.168.30.11/24
    bridge-ports ens2.30
    bridge-stp off
    bridge-fd 0
    mtu 9000

# Game Server Bridge (VLAN 20)
auto vmbr2
iface vmbr2 inet static
    address 192.168.20.11/24
    bridge-ports ens3.20
    bridge-stp off
    bridge-fd 0
EOF

# Reboot
reboot
```

#### 1.4 Repeat voor Nodes 2-5
Pas `.11` aan naar `.12`, `.13`, `.14`, `.15` respectievelijk.

### FASE 2: Cluster Aanmaken (15 min)

#### 2.1 Create Cluster (Node 1)

```bash
ssh root@192.168.10.11

# Create cluster
pvecm create gameserver-cluster --link0 192.168.10.11

# Verify
pvecm status
```

#### 2.2 Add Nodes (Node 2-5)

```bash
# Voer UIT op elke node (2-5):
pvecm add 192.168.10.11
# Voer root wachtwoord van Node 1 in + fingerprint verificatie

# Verify op Node 1:
pvecm status
# Moet tonen: Nodes: 5, Quorate: Yes
```

### FASE 3: Ceph Storage (60 min)

#### 3.1 Install Ceph (Alle nodes)

```bash
# Parallel voer uit op alle nodes:
for i in {11..15}; do
  ssh root@192.168.10.$i "pveceph install --version quincy" &
done
wait
```

#### 3.2 Initialize Ceph (Node 1)

```bash
pveceph init --network 192.168.30.0/24 --cluster-network 192.168.30.0/24
```

#### 3.3 Create Monitors (Alle nodes)

```bash
# Voer uit op ELKE node:
pveceph mon create
```

#### 3.4 Create Managers (3 nodes)

```bash
# Voer uit op Node 1, 2, 3:
pveceph mgr create
```

#### 3.5 Create OSDs (Alle nodes)

```bash
# Per node, check beschikbare disks:
lsblk

# Maak OSD (op elke node):
pveceph osd create /dev/nvme0n1
```

#### 3.6 Create Pools

```bash
pveceph pool create ceph-vms --add_storages --size 2 --pg_num 128
pveceph pool create ceph-backups --add_storages --size 2 --pg_num 64

# Verify:
ceph -s
# Verwacht: health HEALTH_OK
```

### FASE 4: VM Templates & Deployment (30 min)

#### 4.1 Download Ubuntu Cloud Image

```bash
cd /var/lib/vz/template/iso
wget https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img
```

#### 4.2 Create VM Template

```bash
TEMPLATE_ID=9000

qm create $TEMPLATE_ID \
  --name ubuntu-22.04-template \
  --memory 2048 \
  --cores 2 \
  --net0 virtio,bridge=vmbr0

qm importdisk $TEMPLATE_ID ubuntu-22.04-server-cloudimg-amd64.img ceph-vms
qm set $TEMPLATE_ID --scsihw virtio-scsi-pci --scsi0 ceph-vms:vm-$TEMPLATE_ID-disk-0
qm set $TEMPLATE_ID --ide2 ceph-vms:cloudinit
qm set $TEMPLATE_ID --boot c --bootdisk scsi0
qm set $TEMPLATE_ID --serial0 socket --vga serial0
qm set $TEMPLATE_ID --agent enabled=1

qm template $TEMPLATE_ID
```

#### 4.3 Deploy VMs

```bash
# Panel VM
qm clone 9000 100 --name panel --full --storage ceph-vms
qm set 100 --cores 4 --memory 8192
qm resize 100 scsi0 80G
qm set 100 --ipconfig0 ip=192.168.20.10/24,gw=192.168.20.1
qm start 100

# Game Node VMs (repeat with different IDs/names)
for i in {1..5}; do
  VMID=$((200 + i))
  qm clone 9000 $VMID --name game-node-$i --full --storage ceph-vms
  qm set $VMID --cores 8 --memory 16384
  qm resize $VMID scsi0 100G
  IP="192.168.20.$((20 + i))"
  qm set $VMID --ipconfig0 ip=$IP/24,gw=192.168.20.1
  qm start $VMID
done
```

### FASE 5: High Availability (15 min)

```bash
# Create HA groups
ha-manager groupadd critical \
    --nodes "pve-node1:3,pve-node2:2,pve-node3:1" \
    --comment "Critical services"

# Add VMs to HA
ha-manager add vm:100 --group critical --state started
```

### FASE 6: Monitoring (30 min)

#### Deploy Monitoring VM

```bash
qm clone 9000 300 --name monitoring --full --storage ceph-vms
qm set 300 --cores 4 --memory 8192
qm resize 300 scsi0 100G
qm set 300 --ipconfig0 ip=192.168.20.90/24,gw=192.168.20.1
qm start 300
```

#### Setup Monitoring Stack

```bash
ssh root@192.168.20.90

# Install Docker
curl -sSL https://get.docker.com/ | bash
systemctl enable docker

# Setup Prometheus + Grafana (volledige docker-compose in aparte guide)
```

---

## Verificatie Checklist

```bash
# Cluster status
pvecm status              # Nodes: 5, Quorate: Yes
pvecm nodes

# Ceph status
ceph -s                   # health HEALTH_OK
ceph osd tree

# VMs
qm list                   # Alle VMs zichtbaar
ssh root@192.168.20.10   # SSH naar Panel VM werkt

# Network
ping 192.168.10.12        # Management network
ping 192.168.30.12        # Ceph network
ping 192.168.20.12        # Game network
```

---

## Troubleshooting

### Cluster problemen

**Geen quorum na nodes toevoegen**
```bash
# Check corosync
systemctl status corosync

# Check network connectivity
ping [other-node-ip]

# Reset cluster (LAST RESORT):
systemctl stop pve-cluster corosync
pmxcfs -l
rm /etc/corosync/* /etc/pve/corosync.conf
killall pmxcfs
systemctl start pve-cluster
```

### Ceph problemen

**OSDs stuck in creating**
```bash
# Check logs
journalctl -u ceph-osd@*.service -f

# Remove stuck OSD
ceph osd down <osd-id>
ceph osd out <osd-id>
ceph osd rm <osd-id>
```

### Network problemen

**VMs niet bereikbaar**
```bash
# Check VM console
qm terminal <vmid>

# Check cloud-init status
cloud-init status
cloud-init clean && cloud-init init
```

---

## Post-Setup

### 1. Install Pterodactyl Panel

```bash
ssh root@192.168.20.10
curl -L https://get.pterodactyl.io/panel | bash
```

### 2. Deploy Game Servers

Volg de Pterodactyl documentation voor het deployen van game servers via de web UI.

### 3. Configure Monitoring Dashboards

Import Grafana dashboards:
- ID 10048: Proxmox via Prometheus
- ID 1860: Node Exporter

### 4. Setup Backups

```bash
# Create backup cron
cat > /root/backup.sh << 'EOF'
#!/bin/bash
for vmid in {100,200,201,202,203,204,205}; do
  vzdump $vmid --storage ceph-backups --mode snapshot --compress zstd
done
EOF

chmod +x /root/backup.sh
(crontab -l; echo "0 2 * * * /root/backup.sh") | crontab -
```

---

## Nuttige Links

- [Proxmox VE Documentation](https://pve.proxmox.com/wiki/Main_Page)
- [Ceph Documentation](https://docs.ceph.com/)
- [Pterodactyl Panel](https://pterodactyl.io/)
- [MS-01 Specifications](https://www.maxtang.com/)

---

## Support

Voor vragen/issues, raadpleeg:
1. Log files: `/var/log/gameserver-proxmox-setup/`
2. Proxmox UI: https://192.168.10.11:8006
3. Troubleshooting guide hierboven

---

**Gebaseerd op**: Proxmox VE 8.1, Ceph Quincy, 5× MS-01 nodes
**Laatst bijgewerkt**: December 2024
