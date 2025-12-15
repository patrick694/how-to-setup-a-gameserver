# 🛠️ Pre-installatiegids voor Proxmox VE (uitgebreid)

Deze pagina legt stap-voor-stap uit wat je moet doen voordat je Proxmox VE installeert op je 5× MS-01 cluster. Doel: zo min mogelijk verrassingen tijdens de installatie en een betrouwbare basis voor Proxmox + Ceph + HA.

De gids is in het Nederlands en gericht op Proxmox VE 8.x (Debian Bookworm). Volg precies waar nodig en pas netwerk/IP-adressen aan jouw omgeving aan.

---

## Inhoud
- Hardware & firmware
- Netwerkontwerp & switch-voorbereiding
- Disk layout & opslagkeuzes
- Voorbereiding OS-installatie (ISO / unattended)
- Hostname, DNS en /etc/hosts
- Tijd & NTP/chrony
- SSH- en toegangstips
- Proxmox install (ISO) checklist
- After-install: repos, updates, basisconfig

---

## 1) Hardware & firmware

- BIOS/UEFI:
  - Schakel virtualization/VT-x (Intel) of SVM (AMD) in.
  - Schakel "Intel VT-d" of IOMMU in als je PCI passthrough of Ceph/isolatie gebruikt.
  - Zet `Secure Boot` uit (Proxmox-installatie en sommige drivers werken niet goed met secure boot).
  - Zorg dat `UEFI` of `Legacy` consistent is op alle nodes (aanbeveling: UEFI).

- Firmware (BIOS) updaten naar nieuwste versie voordat je installeert.

- RAID vs. JBOD:
  - Voor Ceph OSD's wil je liever individuele NVMe’s (JBOD/raw disks) zodat Ceph volledige controle heeft.
  - Als je ZFS lokaal op een node wilt gebruiken, gebruik dan hardware of software RAID alleen als je de consequenties begrijpt.

- RAM/CPU:
  - Zorg voor voldoende RAM per node (je hebt 32GB in MS-01; Ceph OSDs gebruiken extra RAM per OSD).

- Power & Cooling:
  - Zorg voor betrouwbare voeding en goede ventilatie; Ceph/VM-workloads kunnen vlakke stroompieken veroorzaken.

---

## 2) Netwerkontwerp & switch-voorbereiding

Voor dit project gebruiken we drie gescheiden logische netwerken (VLANs):
- Management: VLAN 10 (Proxmox GUI, cluster traffic)
- Ceph / Storage: VLAN 20 (Ceph public + cluster internal)
- Game / VM: VLAN 30 (VM/netwerk voor game-traffic)

Switch-voorbereiding:
- Maak VLANs aan (10, 20, 30) op je switch.
- Zorg dat trunk-ports naar je nodes beide VLANs taggen en management VLAN als native/untagged indien gewenst.
- Stel MTU 9000 (jumbo frames) alleen in als je switch en NICs dit ondersteunen — test MTU end-to-end.

Voorbeeld switchport (Cisco-like):

```text
interface Ethernet1/1
  switchport mode trunk
  switchport trunk native vlan 10
  switchport trunk allowed vlan 10,20,30
  mtu 9000
```

Netwerk IP-planning (voorbeeld):

```
MGMT network (VLAN10): 192.168.10.0/24
NODE1: 192.168.10.11
NODE2: 192.168.10.12
NODE3: 192.168.10.13
NODE4: 192.168.10.14
NODE5: 192.168.10.15

CEPH network (VLAN20): 10.20.0.0/24
NODE1-ceph: 10.20.0.11
...

GAME network (VLAN30): 10.30.0.0/24
VM nets: DHCP of statische IPs binnen dit bereik
```

---

## 3) Disk layout & opslagkeuzes

Aanbevelingen:
- OS/boot: kleine NVMe of partition op een disk (32–64GB) is voldoende voor Proxmox zelf.
- Ceph OSDs: gebruik aparte NVMe devices (zonder partition table) per OSD. Vraag: wil je journal op NVMe? (oude Ceph-opties) Moderne Ceph gebruikt Bluestore op het volledige device.
- Swap: Proxmox gebruikt zelden swap; laat de default of schakel uit op servers met genoeg RAM.

Voorbeeld:
- NVMe0: OS + boot
- NVMe1: Ceph OSD 1
- NVMe2: Ceph OSD 2 (indien meerdere spindles/SSDs)

Belangrijk:
- Verwijder alle RAID metadata en partition tables op OSD-disks voor installatie (gebruik `sgdisk --zap-all /dev/nvmeX` of `wipefs -a`).
- Controleer SMART-status van NVMe's: `smartctl -a /dev/nvme0n1`.

---

## 4) Voorbereiding OS-installatie (ISO / unattended)

Aanbeveling: gebruik de officiële Proxmox VE 8.1 ISO (standalone installer). Opties:
- Handmatige ISO installatie via USB/ISO (Aanbevolen voor beginners).
- Unattended installatie (voor geautomatiseerde provisioning) — geavanceerd.

Handmatige stappen (kort):
1. Download ISO: https://www.proxmox.com/en/downloads
2. Maak een bootable USB (Rufus op Windows, `dd` op Linux):

```bash
# Voorbeeld (zorg dat je het juiste device kiest!)
sudo dd if=proxmox-ve_8.1.iso of=/dev/sdX bs=4M status=progress && sync
```

3. Boot van USB op iedere node en doorloop installer.

Installer opties:
- Kies target disk (OS/boot - meestal NVMe0)
- Hostname: `node1.cluster.local` of `ms01-01` (kies één conventie en gebruik consistent)
- Management IP: geef statisch IP in management VLAN
- DNS: zet naar locale resolver of upstream (1.1.1.1 / 8.8.8.8)
- Timezone: configureer juiste timezone

---

## 5) Hostname, DNS en `/etc/hosts`

Zorg dat iedere node een vaste hostname en een corresponderende entry in `/etc/hosts` heeft. Dit helpt clustervorming:

Voorbeeld `/etc/hosts` op Node1:

```
127.0.0.1 localhost
192.168.10.11 node1.example.local node1
192.168.10.12 node2.example.local node2
192.168.10.13 node3.example.local node3
192.168.10.14 node4.example.local node4
192.168.10.15 node5.example.local node5
```

Let op: gebruik consistente hostnames bij `pvecm create` en `pvecm add`.

---

## 6) Tijd & NTP (chrony)

Consistente tijd is cruciaal voor clustering and Ceph. Proxmox8 gebruikt `systemd-timesyncd` of `chrony`.

Aanbeveling: installeer en configureer `chrony` op alle nodes:

```bash
sudo apt update
sudo apt install -y chrony
sudo systemctl enable --now chrony
chronyc sources
```

Zorg dat chrony synchroniseert met betrouwbare NTP-servers (of interne time server).

---

## 7) SSH- en toegangstips

- Voeg je publieke SSH-sleutel toe aan `/root/.ssh/authorized_keys` vóór installatie (als je unattended/remote toegang wilt).
- Test SSH-toegang zonder wachtwoord:

```bash
ssh root@192.168.10.11
```

- Schakel password-authentication indien gewenst uit na configuratie voor extra veiligheid.

---

## 8) Proxmox-installatie checklist (per node)

Voor je begint op Node1 (en later op alle nodes):

1. BIOS: virtualization + IOMMU ingeschakeld
2. Switch: VLAN 10/20/30 geconfigureerd en trunk naar node
3. Disks: OS-disk en OSD disks bereikbaar en cleared
4. Hostnames ingesteld en `/etc/hosts` klaar
5. Time sync (chrony) werkend
6. SSH key toegevoegd
7. Proxmox ISO klaar op USB
8. Documenteer alle IP-adressen en wachtwoorden ergens veilig

Als alles klaar is: boot van USB en installeer Proxmox op Node1.

---

## 9) Na installatie: direct acties op elke node

1. Update apt sources en disable enterprise repo (optioneel voor geen subscription):

```bash
# Voorbeeld: voeg No-Subscription repo toe
cat > /etc/apt/sources.list.d/pve-no-subscription.list <<'EOF'
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
EOF

apt update
apt full-upgrade -y
```

2. Installeer handige packages:

```bash
apt install -y ifupdown2 sshpass chrony htop
```

3. Controleer Proxmox services:

```bash
systemctl status pve-cluster pvedaemon pveproxy
pvecm status
```

4. Stel firewall & GUI toegang (beheer via: `https://<node-ip>:8006`)

---

## 10) Voorbereiding op cluster-creation & Ceph

- Zorg dat de management netwerk connectiviteit tussen nodes 100% is.
- Test `ping` en `ssh` tussen alle nodes.
- Zorg dat de Ceph/vlan netwerk snelle pings heeft (MTU / jumbo frames consistent).

Voorbeeld tests:

```bash
# vanaf node1
ping -c 3 192.168.10.12
ssh root@192.168.10.12 hostname
# ceph network test
ping -c 3 10.20.0.12
```

---

## FAQ (snelle antwoorden)

Q: Wat als `Secure Boot` aanstaat?
A: Zet het uit — Proxmox en enkele modules functioneren mogelijk niet met secure boot.

Q: Moet ik ZFS of LVM gebruiken?
A: Voor Ceph clusters is ZFS niet nodig; Ceph beheert zijn eigen OSDs over raw devices. Gebruik ZFS alleen als je node-lokaal ZFS wilt (bijv. testomgeving).

Q: Hoeveel OSDs per node?
A: Afhankelijk van schijfruimte; common pattern: 1 OSD per NVMe. Meer OSDs = betere paralleliteit, maar hou rekening met CPU/RAM per OSD.

---

## Links & bronnen
- Proxmox VE downloads: https://www.proxmox.com/en/downloads
- Proxmox VE administration guide
- Ceph documentation: https://docs.ceph.com/
- Chrony docs: https://chrony.tuxfamily.org/

---

## Conclusie
Deze pre-installatie checklist minimaliseert verrassingen tijdens clusteropbouw. Zodra de nodes voorbereid zijn kun je door naar `cluster/02-create-cluster.sh` en `cluster/03-ceph-setup.sh` uit deze repository.

Succes — als je wilt, kan ik deze checklist in een korte `preinstall` checklist script gieten dat checks uitvoert en fouten rapporteert (ping/DNS/hosts/chrony/disks). Zeg het en ik maak het voor je.