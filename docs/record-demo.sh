#!/bin/bash
# Demo script voor terminal recording

# Clear en show banner
clear
cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║         🎮 GameServer Cluster - Quick Demo               ║
╚═══════════════════════════════════════════════════════════╝
EOF
sleep 2

# Show directory
echo ""
echo "$ cd gameserver-proxmox-cluster"
sleep 1
echo "$ ls -la"
sleep 1
ls -la --color=auto
sleep 2

# Show config
echo ""
echo "$ cat config/config-cluster.env.example | head -20"
sleep 1
head -20 config/config-cluster.env.example
sleep 3

# Run installer (demo mode)
echo ""
echo "$ ./scripts/install-cluster.sh"
sleep 2
cat << 'EOF'

╔═══════════════════════════════════════════════════════════╗
║              🎮  GAMESERVER CLUSTER INSTALLER            ║
╚═══════════════════════════════════════════════════════════╝

[1] 🚀 Complete cluster setup (recommended)
[2] 🌐 Network configuration only
[3] 👥 Create cluster only

Select option [1-3]: 
EOF
sleep 2
echo "1"
sleep 1

echo ""
echo "✅ Installation started!"
echo "📝 Log file: /var/log/gameserver-cluster/install-20240101-120000.log"
sleep 2

# Show cluster status
echo ""
echo "$ pvecm status"
sleep 1
cat << 'EOF'
Cluster information
-------------------
Name:             gameserver-cluster
Config Version:   5
Transport:        knet
Nodes:            5
Quorate:          Yes ✅

Node ID:          0x00000001
Ring ID:          1.5
EOF
sleep 2

# Show VMs
echo ""
echo "$ qm list"
sleep 1
cat << 'EOF'
      VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID
       100 pterodactyl-panel    running    8192       80.00        12345
       201 ark-theisland        running    20480      100.00       12346
       301 fivem-rp1            running    6144       50.00        12347
       401 minecraft-1          running    4096       30.00        12348
EOF
sleep 2

echo ""
echo "🎉 Demo complete! Your cluster is ready for production!"
sleep 2
