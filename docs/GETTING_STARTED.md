# 🎯 Getting Started - Totale Beginner Gids

Welkom! Deze gids helpt je stap-voor-stap om dit cluster op te zetten. **Geen ervaring nodig** — volg gewoon de stappen.

---

## 📋 STAP 1: Voorbereiding (15 min)

### Wat heb je nodig?
- ✅ 5× MS-01 nodes (of ander hardware)
- ✅ Proxmox VE 8.1+ op elke node geïnstalleerd
- ✅ Netwerk met VLAN-ondersteuning
- ✅ SSH-toegang tot Node 1 (root of sudo)
- ✅ Deze repository gedownload of gekloond

### Controleer je hardware

Op Node 1, log in als root en voer uit:

```bash
# Controleer Proxmox versie
pveversion

# Output zou moeten zijn: pve-manager/8.x.x (PVE 8.x)
```

Klaar? Ga naar STAP 2.

---

## 🚀 STAP 2: Download en Setup (5 min)

### Clone deze repository

```bash
# Log in op Node 1
ssh root@<IP-VAN-NODE-1>

# Download de repository
cd /root
git clone https://github.com/patrick694/gameserver.git
cd gameserver

# Controleer bestanden
ls -la
```

Je zou dit moeten zien:
```
install-cluster.sh          ← Main installer
cluster/                    ← Setup scripts
scripts/                    ← Hulpprogramma's
docs/                       ← Documentatie
config-cluster.env.example  ← Configuratietemplate
README.md                   ← Volledige gids
```

---

## ⚙️ STAP 3: Configuratie (10 min)

### Pas config aan voor jouw nodes

```bash
# Copy template naar echte config
cp config-cluster.env.example config-cluster.env

# Open in editor (nano, vi, of jouw favoriete editor)
nano config-cluster.env
```

### Wat moet je aanpassen?

Zoek deze variables en verander ze naar jouw IP-adressen:

```bash
# NODES - IP-adressen van je 5× nodes
NODE1_IP=192.168.10.11      # Verander dit naar jouw Node 1 IP
NODE2_IP=192.168.10.12      # Verander dit naar jouw Node 2 IP
NODE3_IP=192.168.10.13
NODE4_IP=192.168.10.14
NODE5_IP=192.168.10.15

# VLAN-nummers (keep defaults tenzij je netwerk anders is)
MGMT_VLAN=10                # Management network
CEPH_VLAN=20                # Storage network
GAME_VLAN=30                # Game servers network

# Cluster naam (je mag dit veranderen)
CLUSTER_NAME=proxmox-cluster
```

### Sluit en save (Ctrl+X, Y, Enter als je nano gebruikt)

Klaar? Ga naar STAP 4.

---

## 🎬 STAP 4: Start Installatie (4 uur)

### Run het master installer script

```bash
# Zorg dat je in de directory bent
cd /root/gameserver

# Start installer
./install-cluster.sh
```

### Je ziet een menu:

```
╔═══════════════════════════════════════════════════════════╗
║  Proxmox Cluster Setup - Interactive Menu                ║
╚═══════════════════════════════════════════════════════════╝

1) Complete Setup (alle stappen, ~4 uur)
2) Phase 1: Network Setup
3) Phase 2: Create Cluster
4) Phase 3: Ceph Storage
...
9) Exit
```

**Selecteer optie 1** (Complete Setup) en druk Enter.

### Wat gebeurt er?

De installer voert automatisch uit:
1. ✅ Netwerk configuratie (VLAN's, bridges)
2. ✅ Proxmox cluster aanmaken
3. ✅ Ceph storage initialiseren
4. ✅ VM-templates maken
5. ✅ Virtuele machines deployen
6. ✅ High Availability configureren
7. ✅ Monitoring setup (Prometheus + Grafana)
8. ✅ Health checks

**Dit duurt ongeveer 4 uur. Laat het draaien.**

---

## ✅ STAP 5: Verificatie (10 min)

### Na installatie, check status

```bash
# Run status check
./cluster/99-status.sh

# Dit toont:
# - Cluster status ✓
# - Node status (5/5 gezond)
# - Ceph status (alle OSD's online)
# - VM's (alle draaiend)
# - HA status (actief)
```

### Verwachte output

```
╔═══════════════════════════════════════════════════════════╗
║  Cluster Status Dashboard                                ║
╚═══════════════════════════════════════════════════════════╝

✅ Cluster Status: ONLINE (5 nodes)
✅ Quorum: OK (5/5 nodes, majority met)
✅ Ceph Cluster: HEALTH_OK
✅ Storage: 5TB usable
✅ VMs: 5 deployed (all running)
✅ HA: Enabled (3 groups configured)
```

Alles groen? **Succes!** Je cluster is actief.

---

## 📊 STAP 6: Volgende Stappen

### Proxmox Web Interface

Open je browser naar Node 1:
```
https://192.168.10.11:8006
```

Login met `root` en het wachtwoord dat je bij Proxmox-installatie hebt ingesteld.

### Game Server Setup

VMs zijn nu actief:
- **VM 100**: Pterodactyl Panel (game server management)
- **VM 201-203**: Game servers (3× nodes)
- **VM 300**: Monitoring (Prometheus + Grafana)

Bekijk IP-adressen via:
```bash
qm guest cmd 100 get-status   # Pterodactyl Panel status
```

### Dagelijkse Backups

Backups draaien automatisch dagelijks. Controleer logs:
```bash
tail -f /var/log/gameserver-cluster/backup.log
```

---

## 🆘 Hulp Nodig?

### Problemen?

Controleer de logs:
```bash
# Installation logs
tail -100 /var/log/gameserver-cluster/setup.log

# Run health check
./scripts/health-check.sh

# Dit toont problemen en hoe ze op te lossen
```

### Meer informatie

- 📖 **Full docs**: `README.md`
- ⚡ **Quick reference**: `QUICKSTART.md`
- 🔧 **Setup details**: `SETUP_COMPLETE.md`
- 🐛 **Troubleshooting**: `README.md` → "Troubleshooting" sectie

### Support

Vragen? Open een GitHub Issue:
```
https://github.com/patrick694/gameserver/issues
```

---

## 🎉 Je bent klaar!

Gefeliciteerd! Je hebt nu:

✅ Production-ready Proxmox cluster (5 nodes)
✅ Ceph distributed storage (2× replication, auto-healing)
✅ High Availability (auto-failover)
✅ Game server management (Pterodactyl Panel)
✅ Monitoring (Prometheus + Grafana dashboards)
✅ Automated backups (dagelijks)
✅ CI/CD pipeline (ShellCheck linting)

**Volgende**: Configureer je spellen in Pterodactyl Panel en start je game servers! 🎮

---

**Versie**: 1.0
**Last Updated**: December 2024
**License**: MIT
