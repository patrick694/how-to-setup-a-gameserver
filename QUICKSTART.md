# 🚀 Proxmox Gameserver Cluster - QUICKSTART

## ⚡ 5 minuten overzicht

Je hebt een complete, geautomatiseerde setup voor een 5-node Proxmox cluster met gameserver infrastructure.

### 📋 Vereisten
- ✅ 5× MS-01 nodes met **Proxmox VE 8.1+** geïnstalleerd
- ✅ Netwerk switch met 10G SFP+ support
- ✅ SSH access naar Node 1
- ✅ Basis networking kennis

### 🎯 Wat je krijgt
```
5 × MS-01 Hardware Nodes
    ↓
Proxmox VE Cluster (5 nodes)
    ├─ Ceph Distributed Storage
    ├─ High Availability (auto-failover)
    ├─ Live VM Migration
    └─ Centralized Management

VMs:
    ├─ Pterodactyl Panel (game management)
    ├─ 3× Game Nodes (capacity)
    ├─ Monitoring (Prometheus + Grafana)
    └─ Ready for your game servers
```

---

## 🚀 Quick Setup (30 seconden)

### 1. Copy scripts naar Node 1
```bash
# Op je laptop
scp -r /path/to/gameserver-cluster root@192.168.10.11:/root/
ssh root@192.168.10.11
cd /root/gameserver-cluster
```

### 2. Configure
```bash
cp config-cluster.env.example config-cluster.env
nano config-cluster.env

# Wijzig enkel:
# - CLUSTER_NAME (optioneel)
# - ADMIN_EMAIL (optioneel)
# Rest is al geconfigureerd voor je setup!
```

### 3. Run installer
```bash
chmod +x install-cluster.sh
./install-cluster.sh
```

### 4. Menu
```
[1] 🚀 Complete cluster setup (aanbevolen)
[2] 🌐 Netwerk configuratie
...
```

**Kies [1]** - dan doet het script alles automatisch! ⏱️ ~3-4 uur

---

## 📊 Wat doet het setup script?

### ✅ Fase 1: Netwerk (30 min)
- VLANs configureren (Management, Game, Ceph)
- Bridges aanmaken
- Reboot nodes

### ✅ Fase 2: Cluster (15 min)
- Proxmox cluster aanmaken
- Nodes samenvoegen
- Corosync optimization

### ✅ Fase 3: Ceph (60 min)
- Ceph storage installeren
- Monitors/Managers aanmaken
- OSDs configureren
- Pools aanmaken

### ✅ Fase 4: VMs (30 min)
- Ubuntu cloud template downloaden
- Template aanmaken
- VMs deployen (Panel, Nodes, Monitoring)
- Cloud-init configuratie

### ✅ Fase 5: HA (15 min)
- HA groups definiëren
- VMs naar HA toevoegen
- Auto-failover inschakelen

### ✅ Fase 6: Monitoring (30 min)
- Prometheus + Grafana deployen
- Dashboards configureren
- Alerts setup

---

## 🔍 Directory Structure

```
gameserver-cluster/
├── README.md                          # Volledige documentatie
├── QUICKSTART.md                      # Dit bestand
├── install-cluster.sh                 # ⭐ Master installer
├── config-cluster.env.example         # Configuratie template
│
├── cluster/                           # Setup scripts
│   ├── 01-network-setup.sh
│   ├── 02-create-cluster.sh
│   ├── 03-ceph-setup.sh
│   ├── 04-create-templates.sh
│   ├── 05-deploy-vms.sh
│   ├── 06-ha-setup.sh
│   ├── 07-monitoring-setup.sh
│   └── 99-status.sh
│
└── scripts/                           # Utilities
    ├── backup.sh                      # Automated backups
    └── health-check.sh                # Diagnostics
```

---

## 📈 Setup Timeline

```
T+0:00    → Start install-cluster.sh
T+0:30    → Netwerk configuratie + reboots
T+1:00    → Cluster aangemaakt
T+2:00    → Ceph online, pools ready
T+2:30    → VMs deploying
T+3:00    → HA configuratie
T+3:30    → Monitoring setup
T+4:00    → ✅ COMPLEET!
```

---

## ✨ Handige commands

### Cluster status
```bash
./cluster/99-status.sh          # Real-time dashboard
pvecm status                    # Cluster info
pvecm nodes                     # Node list
```

### Ceph
```bash
ceph -s                         # Health
ceph df                         # Usage
ceph osd tree                   # OSD layout
```

### VMs
```bash
qm list                         # All VMs
qm status 100                   # VM status
qm start 100                    # Start VM
qm migrate 100 pve-node2 --online  # Live migrate
```

### HA
```bash
ha-manager status               # HA overview
ha-manager config               # HA resources
```

### Backups
```bash
./scripts/backup.sh             # Manual backup
```

### Health Check
```bash
./scripts/health-check.sh       # Diagnostics
```

---

## 🔧 Post-Setup

### 1. Change Passwords
```bash
# Grafana
# Login: admin / admin (change in UI!)

# Proxmox root user
passwd
```

### 2. Setup Pterodactyl Panel
```bash
ssh root@192.168.20.10
# Install Pterodactyl (separate guide)
```

### 3. Configure DNS (optional)
```bash
# Point your domain to cluster
example.gameserver.com → 192.168.10.11
panel.gameserver.com   → 192.168.20.10
```

### 4. Setup SSL (optional)
```bash
# On monitoring VM for Grafana
certbot --nginx -d monitoring.gameserver.com
```

---

## 🆘 Troubleshooting

### ❌ Script mislukt

**Opties:**
1. Check logbestand: `/var/log/gameserver-cluster/install-*.log`
2. Run failed stap opnieuw via menu
3. Check netwerk connectivity
4. Ensure all nodes online

```bash
# Check nodes
for i in {11..15}; do ping -c1 192.168.10.$i; done

# Check SSH
for i in {12..15}; do ssh root@192.168.10.$i "echo OK"; done
```

### ❌ Nodes don't cluster

```bash
# Reset corosync (Node 1 + all nodes)
systemctl stop pve-cluster corosync
rm /etc/corosync/* /etc/pve/corosync.conf
killall pmxcfs
systemctl start pve-cluster

# Recreate cluster
pvecm create gameserver-cluster --link0 192.168.10.11
```

### ❌ Ceph stuck

```bash
# Check status
ceph health detail

# Check logs
journalctl -u ceph-osd@*.service -f
```

### ❌ Can't SSH to VMs

```bash
# VM console (via Proxmox UI)
qm terminal 100

# Or check cloud-init
cloud-init status
```

---

## 📞 Support Resources

- **Proxmox Docs**: https://pve.proxmox.com/wiki/
- **Ceph Docs**: https://docs.ceph.com/
- **Pterodactyl**: https://pterodactyl.io/
- **MS-01**: https://www.maxtang.com/

---

## 🎯 Next Steps After Setup

### Phase 1: Test (1 hour)
- ✅ SSH to each VM
- ✅ Run health-check.sh
- ✅ Test Grafana dashboards
- ✅ Check backups

### Phase 2: Deploy Games (varies)
- Deploy via Pterodactyl Panel
- Configure game-specific settings
- Setup ports & network rules

### Phase 3: Production (ongoing)
- Monitor dashboards
- Automated backups (daily)
- HA failover testing
- Performance tuning

---

## 💡 Tips & Tricks

### Memory
Bij 5× MS-01 nodes heb je 160GB RAM. Dit is genoeg voor:
- **20-30 concurrent game servers** (diverse games)
- **100+ player servers** (Minecraft, FiveM, etc.)

### Storage
5TB Ceph (2× replication) = 2.5TB effectief. Genoeg voor:
- **Operating systems** (~10GB per VM)
- **Game files** (vary per game)
- **Backups** (7 day retention)

### Network
50Gbit+ aggregate bandwidth - geen bottleneck voor gaming!

---

## 📝 Configuration Checklist

Voordat je begint:

- [ ] All 5 nodes running Proxmox VE 8.1+
- [ ] Network switch configured (VLANs 10,20,30)
- [ ] SSH access to Node 1
- [ ] External internet (for ISO/package downloads)
- [ ] Time synchronized on all nodes
- [ ] DNS configured (1.1.1.1, 8.8.8.8)

---

## 🎉 You're Ready!

Run this on Node 1:

```bash
cd /root/gameserver-cluster
chmod +x install-cluster.sh
./install-cluster.sh
```

Select **[1] Complete setup** and let it do the work! 🚀

Your cluster will be production-ready in ~4 hours.

---

**Questions?** Check README.md for detailed documentation.
