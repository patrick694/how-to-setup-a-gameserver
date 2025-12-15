#!/bin/bash
###############################################################################
# Proxmox Gameserver Cluster - Master Installer
# Automatiseert volledige 5-node cluster setup
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging
LOG_DIR="/var/log/gameserver-cluster"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"

log() {
    echo -e "${2}${1}${NC}" | tee -a "$LOG_FILE"
}

clear
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║           🎮  PROXMOX GAMESERVER CLUSTER SETUP                           ║
║           5× MS-01 Nodes - Professionele Infrastructure                  ║
║                                                                           ║
║           ⏱️  Totale setup: ~3-4 uur                                     ║
║           📊 Resources: 70 cores, 160GB RAM, 5TB storage                 ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF

echo ""
log "📝 Setup gestart: $(date)" "$BLUE"
log "📂 Logbestand: $LOG_FILE" "$BLUE"
echo ""

# Check Proxmox
if [ ! -f "/etc/pve/local/pve-ssl.pem" ]; then
    log "❌ Proxmox VE niet gedetecteerd!" "$RED"
    log "   Dit script moet draaien op een Proxmox VE host" "$YELLOW"
    exit 1
fi

log "✅ Proxmox VE detected: $(pveversion | grep pve-manager)" "$GREEN"

# Load config
if [ ! -f "config-cluster.env" ]; then
    log "⚠️  config-cluster.env niet gevonden!" "$YELLOW"
    log "   Kopieëren van config-cluster.env.example..." "$BLUE"
    
    if [ ! -f "config-cluster.env.example" ]; then
        log "❌ config-cluster.env.example ook niet gevonden!" "$RED"
        exit 1
    fi
    
    cp config-cluster.env.example config-cluster.env
    log "✅ config-cluster.env aangemaakt - pas deze aan en voer script opnieuw uit" "$YELLOW"
    exit 0
fi

source config-cluster.env

# Check required scripts
for script in cluster/*.sh; do
    if [ ! -f "$script" ]; then
        log "❌ Script niet gevonden: $script" "$RED"
        exit 1
    fi
done

log "✅ Alle vereiste scripts gevonden" "$GREEN"
echo ""

# Menu
show_menu() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  CLUSTER SETUP MENU${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "  [1] 🚀 Complete cluster setup (aanbevolen)"
    echo "  [2] 🌐 Netwerk configuratie"
    echo "  [3] 👥 Cluster aanmaken"
    echo "  [4] 🗄️  Ceph storage setup"
    echo "  [5] 🖼️  VM templates aanmaken"
    echo "  [6] 🎮 VMs deployen"
    echo "  [7] 🔄 High Availability setup"
    echo "  [8] 📊 Monitoring setup"
    echo "  [9] 🔍 Cluster status"
    echo "  [0] ❌ Afsluiten"
    echo ""
    read -p "Keuze [0-9]: " choice
}

execute_setup() {
    local step=$1
    local script=$2
    local desc=$3
    
    log "════════════════════════════════════════════════════════════════" "$BLUE"
    log "STAP $step: $desc" "$BLUE"
    log "════════════════════════════════════════════════════════════════" "$BLUE"
    echo ""
    
    if bash "$script" 2>&1 | tee -a "$LOG_FILE"; then
        log "✅ $desc voltooid" "$GREEN"
        return 0
    else
        log "❌ $desc MISLUKT" "$RED"
        return 1
    fi
}

# Main menu loop
while true; do
    show_menu
    
    case $choice in
        1)
            log "🚀 Complete cluster setup gestart..." "$GREEN"
            
            execute_setup "1" "cluster/01-network-setup.sh" "Netwerk configuratie" || exit 1
            sleep 2
            
            execute_setup "2" "cluster/02-create-cluster.sh" "Cluster aanmaken" || exit 1
            sleep 2
            
            execute_setup "3" "cluster/03-ceph-setup.sh" "Ceph storage" || exit 1
            sleep 2
            
            execute_setup "4" "cluster/04-create-templates.sh" "VM templates" || exit 1
            sleep 2
            
            execute_setup "5" "cluster/05-deploy-vms.sh" "VM deployment" || exit 1
            sleep 2
            
            execute_setup "6" "cluster/06-ha-setup.sh" "High Availability" || exit 1
            sleep 2
            
            execute_setup "7" "cluster/07-monitoring-setup.sh" "Monitoring" || exit 1
            
            log "✅ CLUSTER SETUP COMPLEET!" "$GREEN"
            bash cluster/99-status.sh
            break
            ;;
        2)
            execute_setup "1" "cluster/01-network-setup.sh" "Netwerk configuratie"
            ;;
        3)
            execute_setup "2" "cluster/02-create-cluster.sh" "Cluster aanmaken"
            ;;
        4)
            execute_setup "3" "cluster/03-ceph-setup.sh" "Ceph storage"
            ;;
        5)
            execute_setup "4" "cluster/04-create-templates.sh" "VM templates"
            ;;
        6)
            execute_setup "5" "cluster/05-deploy-vms.sh" "VM deployment"
            ;;
        7)
            execute_setup "6" "cluster/06-ha-setup.sh" "High Availability"
            ;;
        8)
            execute_setup "7" "cluster/07-monitoring-setup.sh" "Monitoring"
            ;;
        9)
            bash cluster/99-status.sh
            ;;
        0)
            log "👋 Afsluiten..." "$YELLOW"
            echo ""
            log "📝 Setup logbestand: $LOG_FILE" "$BLUE"
            exit 0
            ;;
        *)
            log "❌ Ongeldige keuze" "$RED"
            ;;
    esac
    
    echo ""
    read -p "Druk op Enter om door te gaan..."
done
