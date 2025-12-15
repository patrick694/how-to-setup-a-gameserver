# 🎮 Proxmox Gameserver Cluster - Complete Setup Package

## 📦 What's Included

### Documentation
- **README.md** - Volledige technische documentatie (70KB+)
- **QUICKSTART.md** - 5-minuten snelstart gids
- **gameserver** - Originele Dutch setup guide

### Master Installer
- **install-cluster.sh** - Interactive menu-driven installer
  - Checks Proxmox installation
  - Loads configuration
  - Runs setup phases in correct order
  - Full logging to `/var/log/gameserver-cluster/`

### Setup Scripts (in `cluster/` dir)
1. **01-network-setup.sh** - Network bridges & VLAN configuration
2. **02-create-cluster.sh** - Create 5-node Proxmox cluster
3. **03-ceph-setup.sh** - Install & initialize Ceph storage
4. **04-create-templates.sh** - Download Ubuntu cloud image & create VM template
5. **05-deploy-vms.sh** - Deploy Panel, Game Nodes, Monitoring VMs
6. **06-ha-setup.sh** - Configure High Availability groups
7. **07-monitoring-setup.sh** - Deploy Prometheus + Grafana stack
8. **99-status.sh** - Real-time cluster dashboard

### Utility Scripts (in `scripts/` dir)
- **backup.sh** - Automated daily backups (critical VMs + rotating game VMs)
- **health-check.sh** - Cluster diagnostics & health verification

### Configuration
- **config-cluster.env.example** - Configuration template (pre-filled for your setup)

---

## 🎯 Hardware Targets

### Per MS-01 Node
```
CPU:     Intel i9-12900H (14C/20T, 5.0GHz)
RAM:     32GB DDR5-4800
Storage: 1TB NVMe
Network: 2× 10G SFP+ + 2× 2.5GbE
```

### Cluster Total
```
CPU:     70 cores / 100 threads
RAM:     160GB (140GB for VMs)
Storage: 5TB (3TB with 2× replication)
Network: 50Gbit+ aggregate
```

---

## 🚀 Quick Start (3 Steps)

### 1️⃣ Copy to Node 1
```bash
scp -r /path/to/gameserver-cluster root@192.168.10.11:/root/
ssh root@192.168.10.11
cd gameserver-cluster
```

### 2️⃣ Configure (30 seconds)
```bash
cp config-cluster.env.example config-cluster.env
# Only change if needed - defaults are optimized!
```

### 3️⃣ Run (automatic ~4 hours)
```bash
chmod +x install-cluster.sh
./install-cluster.sh
# Select [1] Complete setup
```

---

## 📊 What Gets Installed

### Infrastructure
✅ 5-node Proxmox VE cluster  
✅ Ceph distributed storage (replicated, HA)  
✅ 3× Ceph monitors + 3× managers  
✅ 5× Ceph OSDs (one per node)  
✅ High Availability with auto-failover  
✅ Live VM migration capability  

### VMs
✅ Pterodactyl Panel (game server management)  
✅ 3× Game Nodes (8 cores, 16GB RAM each)  
✅ Monitoring Stack (Prometheus + Grafana)  
✅ Cloud-init ready for quick deployment  

### Services
✅ Prometheus metrics (15s intervals, 30d retention)  
✅ Grafana dashboards (Proxmox + Node exporters)  
✅ Automated daily backups (7-day retention)  
✅ Health monitoring & alerting  

---

## ⏱️ Timeline

```
T+0:00    Start installer
T+0:30    Network reconfiguration + reboot
T+1:00    Cluster formed (5 nodes)
T+2:00    Ceph ready (40GB+ allocated)
T+2:30    VMs deploying (Panel, Nodes, Monitoring)
T+3:00    HA configured (auto-failover ready)
T+3:30    Monitoring stack running (dashboards up)
T+4:00    ✅ Production ready!
```

---

## 📝 Configuration File Reference

### Key Settings (pre-configured)
```bash
CLUSTER_NAME="gameserver-cluster"

# Network (VLAN-based, 3 separate networks)
MGMT_NETWORK="192.168.10.0/24"  # Proxmox management
GAME_NETWORK="192.168.20.0/24"  # Public game traffic
CEPH_NETWORK="192.168.30.0/24"  # Storage replication

# VM Allocations (optimized for 5× MS-01)
PANEL_VMID=100   # 4C, 8GB RAM, 80GB disk
NODE1_VMID=201   # 8C, 16GB RAM, 150GB disk
NODE2_VMID=202   # 8C, 16GB RAM, 150GB disk
NODE3_VMID=203   # 8C, 16GB RAM, 150GB disk
MON_VMID=300     # 4C, 8GB RAM, 100GB disk

# Ceph Storage
VM_STORAGE="ceph-vms"          # For VM disks
BACKUP_STORAGE="ceph-backups"  # For daily backups
CEPH_POOL_SIZE="2"             # 2× replication (N+1)

# Monitoring
PROMETHEUS_RETENTION="30d"
GRAFANA_ADMIN_USER="admin"
GRAFANA_ADMIN_PASSWORD="admin"  # ⚠️ Change!
```

---

## 🔧 Post-Installation Checklist

After setup completes:

- [ ] Login to Proxmox: https://192.168.10.11:8006
- [ ] Verify all 5 nodes in cluster (Datacenter → Nodes)
- [ ] Check Ceph status: `ceph -s` (should be HEALTH_OK)
- [ ] SSH to VMs and verify connectivity
- [ ] Change Grafana password: http://192.168.20.90:3000
- [ ] Import Grafana dashboards (Dashboard ID 10048)
- [ ] Setup Pterodactyl Panel on 192.168.20.10
- [ ] Test HA failover (optional but recommended)
- [ ] Configure DNS entries (if using domain)
- [ ] Setup SSL certificates (if needed)

---

## 📚 Usage Examples

### Check cluster health
```bash
./cluster/99-status.sh
```

### View real-time metrics
```bash
# Grafana
http://192.168.20.90:3000

# Prometheus
http://192.168.20.90:9090
```

### Manually deploy a VM
```bash
qm clone 9000 150 --name custom-game-vm --full
qm set 150 --cores 4 --memory 8192
qm resize 150 scsi0 50G
qm set 150 --ipconfig0 ip=192.168.20.50/24,gw=192.168.20.1
qm start 150
```

### Live migrate VM (zero downtime)
```bash
qm migrate 100 pve-node2 --online
```

### Create snapshot
```bash
qm snapshot 100 backup-$(date +%Y%m%d)
```

### Manual backup
```bash
./scripts/backup.sh
```

### Health check
```bash
./scripts/health-check.sh
```

---

## 🆘 Troubleshooting

### Nodes won't cluster
1. Check networking: `ping 192.168.10.12` (from Node 1)
2. Verify SSH works: `ssh root@192.168.10.12`
3. Check Corosync: `systemctl status corosync`
4. Reset and recreate: See README.md

### Ceph issues
1. Check health: `ceph health detail`
2. View logs: `journalctl -u ceph-osd@*.service`
3. Common issues documented in README.md

### VM problems
1. Check console: Proxmox UI → VM → Console
2. Verify cloud-init: `ssh root@vm-ip; cloud-init status`
3. Check logs: `/var/log/gameserver-cluster/install-*.log`

---

## 📞 Resources

- **Full Documentation**: README.md
- **Quick Guide**: QUICKSTART.md  
- **Proxmox**: https://pve.proxmox.com/wiki/
- **Ceph**: https://docs.ceph.com/
- **Pterodactyl**: https://pterodactyl.io/
- **MS-01 Hardware**: https://www.maxtang.com/

---

## 🎓 Learning Path

1. **Understand the setup** (read QUICKSTART.md)
2. **Run the installer** (follow menu)
3. **Verify everything** (run health-check.sh)
4. **Deploy games** (use Pterodactyl)
5. **Monitor cluster** (Grafana dashboards)
6. **Optimize** (tune performance as needed)

---

## ✨ Features

- ✅ **Fully Automated** - Menu-driven installer, no manual config
- ✅ **Production Ready** - HA, backups, monitoring included
- ✅ **Scalable** - Easy to add more nodes/VMs
- ✅ **Redundant** - 2× replication, auto-failover
- ✅ **Observable** - Prometheus + Grafana dashboards
- ✅ **Backed Up** - Daily automated backups
- ✅ **Well Documented** - Extensive guides + scripts
- ✅ **Flexible** - Works for any game types
- ✅ **Modern** - Proxmox 8.1, Ceph Quincy, Ubuntu 22.04

---

## 📊 Expected Performance

After setup on 5× MS-01 nodes:

| Metric | Value | Notes |
|--------|-------|-------|
| CPU cores available | 70 (100 with overcommit) | i9-12900H × 5 |
| RAM available | 140GB (VMs) | 160GB total - 20GB Proxmox |
| Storage (effective) | 2.5TB | 5TB raw with 2× replication |
| Network | 50Gbit+ | Aggregate across all nodes |
| Concurrent VMs | 20-30 | Depending on game resource needs |
| Player capacity | 1000+ | Distributed across VMs |
| Backup daily time | ~30min | Depending on data change rate |

---

## 🎯 Success Criteria

After setup completes successfully:

1. ✅ All 5 nodes show "online" in Proxmox UI
2. ✅ `ceph -s` shows "HEALTH_OK"
3. ✅ Can SSH to all VMs (100, 201, 202, 203, 300)
4. ✅ Grafana dashboards show metrics
5. ✅ HA status shows "started" for critical VMs
6. ✅ Daily backups run automatically

---

## 📝 Notes

- Scripts are idempotent - safe to re-run
- Logs saved to: `/var/log/gameserver-cluster/`
- Configuration backed up: `.env.backup`
- Can be deployed in stages (phase by phase)
- Compatible with Proxmox 8.0+ & Ceph Quincy+

---

## 🎊 You're Ready!

Your production-grade gameserver cluster is one command away:

```bash
./install-cluster.sh
```

Good luck! 🚀
