#!/bin/bash
###############################################################################
# Backup Utility - Automated VM Backups
###############################################################################

set -e

BACKUP_DIR="${BACKUP_DIR:-/mnt/backups}"
BACKUP_STORAGE="${BACKUP_STORAGE:-ceph-backups}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"
LOG_FILE="/var/log/cluster-backup.log"

mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname $LOG_FILE)"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "════════════════════════════════════════════════════════════════"
log "Cluster Backup Gestart"

# Backup critical VMs
CRITICAL_VMS=(100 300)    # Panel, Monitoring

log "Backing up critical VMs..."
for VMID in "${CRITICAL_VMS[@]}"; do
    if qm status $VMID &>/dev/null; then
        log "  → Backing up VM $VMID..."
        vzdump $VMID \
            --storage "$BACKUP_STORAGE" \
            --mode snapshot \
            --compress zstd \
            --remove 0 \
            --notes "Automated backup - $(date '+%Y-%m-%d')" || \
            log "  ⚠️  Backup VM $VMID failed"
    fi
done

# Backup game VMs (rotating)
GAME_VMS=(201 202 203)
DAY=$(date +%u)  # 1-7
INDEX=$(( (DAY - 1) % ${#GAME_VMS[@]} ))
VMID=${GAME_VMS[$INDEX]}

if [ ! -z "$VMID" ]; then
    log "  → Rotating backup: VM $VMID"
    vzdump $VMID \
        --storage "$BACKUP_STORAGE" \
        --mode snapshot \
        --compress zstd || \
        log "  ⚠️  Backup VM $VMID failed"
fi

# Cleanup old backups
log "Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -delete

log "✅ Backup completed"
log "════════════════════════════════════════════════════════════════"
