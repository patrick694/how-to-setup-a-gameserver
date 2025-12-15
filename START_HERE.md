# 🎮 Proxmox Gameserver Cluster Setup

> **Production-ready infrastructure for 5× MS-01 nodes**

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Status: Ready](https://img.shields.io/badge/Status-Production--Ready-green.svg)
![Proxmox: 8.0+](https://img.shields.io/badge/Proxmox-8.0%2B-blueviolet.svg)
![Scripts: 10+](https://img.shields.io/badge/Scripts-10%2B-blue.svg)

---

## 🚀 What This Is

A **complete, fully automated setup** for deploying a production-grade gameserver infrastructure on 5× MS-01 nodes with:

- ✅ **Proxmox VE cluster** (5 nodes, HA, live migration)
- ✅ **Ceph distributed storage** (2× replication, self-healing)
- ✅ **Monitoring stack** (Prometheus + Grafana dashboards)
- ✅ **Automated backups** (daily retention)
- ✅ **Game management** (Pterodactyl Panel ready)

---

## 📖 Documentation

**Choose your path:**

| Document | Purpose | Read Time |
|----------|---------|-----------|
| **[QUICKSTART.md](QUICKSTART.md)** | 5-minute quick reference | 5 min ⚡ |
| **[README.md](README.md)** | Complete technical guide | 30 min 📚 |
| **[SETUP_COMPLETE.md](SETUP_COMPLETE.md)** | What you got | 10 min 📋 |
| **[GITHUB_UPLOAD.md](GITHUB_UPLOAD.md)** | Upload to GitHub | 5 min 📤 |

---

## ⚡ Quick Setup (4 Hours)

### Prerequisites
- 5× MS-01 nodes with Proxmox VE 8.1+
- Network switch (10G SFP+)
- SSH access to Node 1

### Installation
```bash
# 1. Copy to Node 1
scp -r /path/to/gameserver-proxmox-cluster root@192.168.10.11:/root/

# 2. SSH to Node 1
ssh root@192.168.10.11
cd gameserver-proxmox-cluster

# 3. Run installer
chmod +x install-cluster.sh
./install-cluster.sh

# 4. Select [1] Complete setup
# ✅ Everything runs automatically (~4 hours)
```

---

## 📦 What's Included

```
🎯 Master Installer
  └─ install-cluster.sh (interactive menu)

🔧 8 Setup Scripts
  ├─ 01-network-setup.sh
  ├─ 02-create-cluster.sh
  ├─ 03-ceph-setup.sh
  ├─ 04-create-templates.sh
  ├─ 05-deploy-vms.sh
  ├─ 06-ha-setup.sh
  ├─ 07-monitoring-setup.sh
  └─ 99-status.sh

🛠️ Utility Scripts
  ├─ backup.sh (automated backups)
  └─ health-check.sh (diagnostics)

📚 Complete Documentation
  ├─ README.md (70KB+)
  ├─ QUICKSTART.md (5 min)
  ├─ SETUP_COMPLETE.md
  └─ GITHUB_UPLOAD.md

⚙️ Configuration
  └─ config-cluster.env.example (pre-filled)

📄 License
  └─ MIT (use freely!)
```

---

## 📊 Hardware Specs

### Per Node (MS-01)
- CPU: Intel i9-12900H (14C/20T)
- RAM: 32GB DDR5
- Storage: 1TB NVMe
- Network: 2× 10G SFP+ + 2× 2.5GbE

### Cluster Total
- **CPU**: 70 cores / 100 threads
- **RAM**: 160GB (140GB for VMs)
- **Storage**: 5TB (3TB effective with 2× replication)
- **Network**: 50Gbit+ aggregate

---

## 🎯 What You Get After Setup

### Infrastructure
✅ 5-node Proxmox cluster  
✅ Ceph storage (replicated, HA)  
✅ High Availability (auto-failover)  
✅ Live VM migration  

### VMs
✅ Pterodactyl Panel (1× VM)  
✅ Game Nodes (3× VMs, 8C/16GB each)  
✅ Monitoring Stack (1× VM)  

### Services
✅ Prometheus metrics (15s intervals)  
✅ Grafana dashboards  
✅ Daily automated backups  
✅ Health monitoring  

---

## ⏱️ Setup Timeline

```
T+0:00    Start
T+0:30    Network configured + reboot
T+1:00    Cluster formed (5 nodes)
T+2:00    Ceph storage ready
T+2:30    VMs deploying
T+3:00    HA configured
T+3:30    Monitoring setup
T+4:00    ✅ PRODUCTION READY!
```

---

## 🔒 Security Features

- ✅ `.gitignore` protects sensitive data
- ✅ Network VLANs (separate management/game/storage)
- ✅ HA with automatic failover
- ✅ Data replication (2× copies of everything)
- ✅ Automated backups (daily, 7-day retention)
- ✅ Prometheus + Grafana monitoring

---

## 📱 After Installation

### 1. Verify Everything Works
```bash
./scripts/health-check.sh
```

### 2. Deploy Game Servers
Go to Panel VM (192.168.20.10) and use Pterodactyl to deploy games

### 3. Monitor Your Cluster
Visit Grafana: http://192.168.20.90:3000

### 4. Setup Automated Backups
Crontab already configured. Backups run daily at 2 AM.

---

## 🆘 Help & Troubleshooting

**Issues?**
1. Check `/var/log/gameserver-cluster/` for logs
2. Run `./scripts/health-check.sh` for diagnostics
3. See [README.md](README.md) troubleshooting section
4. Check QUICKSTART.md for common issues

---

## 📤 Share on GitHub

```bash
./upload-to-github.sh
```

Follow the prompts to upload your setup to GitHub!

---

## 📚 Resources

- [Proxmox Documentation](https://pve.proxmox.com/wiki/)
- [Ceph Documentation](https://docs.ceph.com/)
- [Pterodactyl Panel](https://pterodactyl.io/)
- [MS-01 Hardware](https://www.maxtang.com/)

---

## 📄 License

MIT License - Use freely for personal or commercial projects!
See [LICENSE](LICENSE) for details.

---

## 🎉 Ready to Deploy?

```bash
./install-cluster.sh
```

**Your production infrastructure awaits!** 🚀

---

<div align="center">

**Questions?** → Check [README.md](README.md)  
**Quick start?** → Check [QUICKSTART.md](QUICKSTART.md)  
**Share?** → Run `./upload-to-github.sh`

**Made with ❤️ for gameserver enthusiasts**

</div>
