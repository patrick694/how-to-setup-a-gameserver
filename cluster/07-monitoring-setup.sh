#!/bin/bash
###############################################################################
# Monitoring Setup - Prometheus + Grafana
###############################################################################

source config-cluster.env

echo "📊 Monitoring stack setup..."

MON_VM="${MON_VMID:-300}"
MON_IP="192.168.20.90"

echo "Monitoring VM: $MON_VM ($MON_IP)"
echo ""

# Check if VM is running
if ! qm status $MON_VM 2>/dev/null | grep -q "running"; then
    echo "⚠️  Monitoring VM niet actief"
    echo "Start: qm start $MON_VM"
    exit 0
fi

echo "✅ VM actief"
echo ""

# Create directories on monitoring VM
echo "🔧 Directories aanmaken..."

ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "root@$MON_IP" << 'EOFDIR' || {
    echo "⚠️  Kan niet connecteren naar VM, probeer later"
    exit 0
}
mkdir -p /opt/monitoring/{prometheus,grafana,alertmanager}
cd /opt/monitoring

# Create docker-compose
cat > docker-compose.yml << 'EOFDOCKER'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
    ports:
      - 9090:9090
    restart: unless-stopped
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
    ports:
      - 3000:3000
    restart: unless-stopped
    networks:
      - monitoring
    depends_on:
      - prometheus

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
    ports:
      - 9100:9100
    restart: unless-stopped
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
EOFDOCKER

# Create prometheus config
mkdir -p prometheus
cat > prometheus/prometheus.yml << 'EOFPROM'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'proxmox-nodes'
    static_configs:
      - targets: 
        - '192.168.10.11:9100'
        - '192.168.10.12:9100'
        - '192.168.10.13:9100'
        - '192.168.10.14:9100'
        - '192.168.10.15:9100'

  - job_name: 'game-vms'
    static_configs:
      - targets:
        - '192.168.20.10:9100'
        - '192.168.20.21:9100'
        - '192.168.20.22:9100'
        - '192.168.20.23:9100'
EOFPROM

# Create grafana provisioning
mkdir -p grafana/provisioning/datasources
cat > grafana/provisioning/datasources/prometheus.yml << 'EOFDS'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
EOFDS

# Install docker
curl -sSL https://get.docker.com/ | bash
systemctl enable docker
systemctl start docker

# Start stack
cd /opt/monitoring
docker-compose up -d

echo "✅ Monitoring stack gestart"
EOFDIR

echo ""
echo "✅ Monitoring setup compleet!"
echo ""
echo "🌐 Dashboards:"
echo "   • Grafana: http://$MON_IP:3000 (admin/admin)"
echo "   • Prometheus: http://$MON_IP:9090"
echo ""
echo "📝 Volgende stappen:"
echo "   1. Open Grafana in browser"
echo "   2. Login met admin/admin"
echo "   3. Import Proxmox dashboard (ID: 10048)"
echo "   4. Wijzig Grafana admin password!"
