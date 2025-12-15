# GitHub Upload Instructions

Volg deze stappen om je Proxmox Cluster Setup naar GitHub te uploaden:

## 1️⃣ GitHub Repository aanmaken

Ga naar https://github.com/new en maak een nieuwe repository aan:
- **Repository name**: `gameserver-proxmox-cluster`
- **Description**: `Production-ready Proxmox cluster setup for 5× MS-01 nodes with Ceph storage, HA, and monitoring`
- **Visibility**: Public (of Private als je wilt)
- **Add .gitignore**: Nee (hebben we al)
- **Add a LICENSE**: Selecteer `MIT License` (aanbevolen)

Klik "Create repository"

## 2️⃣ Clone & Push (Lokaal)

```bash
# Navigate naar je project directory
cd /home/patrick/Downloads/5pccluster

# Initialize Git (if not already done)
git init

# Add remote repository
git remote add origin https://github.com/YOUR-USERNAME/gameserver-proxmox-cluster.git

# Add all files
git add .

# Initial commit
git commit -m "Initial commit: Complete Proxmox cluster setup for 5× MS-01 nodes

- Master installer with interactive menu
- 8 setup scripts (network, ceph, ha, monitoring)
- Utility scripts (backup, health-check)
- Complete documentation (README, QUICKSTART)
- Pre-configured for 5× MS-01 hardware"

# Push to GitHub
git branch -M main
git push -u origin main
```

## 3️⃣ SSH Setup (optioneel, voor toekomstige pushes)

Als je SSH keys wilt gebruiken (veiliger dan HTTPS):

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "your-email@example.com"

# Add key to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key to GitHub
# Ga naar https://github.com/settings/keys
# Klik "New SSH key"
# Paste inhoud van ~/.ssh/id_ed25519.pub

# Test SSH connection
ssh -T git@github.com
```

## 4️⃣ Update Repository URL (na SSH setup)

```bash
# Als je SSH wilt gebruiken
git remote set-url origin git@github.com:YOUR-USERNAME/gameserver-proxmox-cluster.git
```

## 5️⃣ Toekomstige Updates

```bash
# Voeg files toe
git add .

# Maak commit
git commit -m "Description van je changes"

# Push naar GitHub
git push
```

---

## 📝 Commit Message Best Practices

```bash
# Feature toevoegen
git commit -m "Add new backup script with retention policy"

# Bug fixen
git commit -m "Fix: Network configuration for VLAN 30 Ceph network"

# Documentatie
git commit -m "docs: Update README with troubleshooting guide"

# Multiple changes
git commit -m "refactor: Improve cluster status dashboard

- Add color formatting
- Include Ceph pool information
- Display backup status"
```

---

## 🔒 Gevoelige Data

⚠️ **NOOIT** committen:
- ❌ `config-cluster.env` (bevat IP adressen & passwords)
- ❌ Log files
- ❌ SSH keys
- ❌ Passwords

De `.gitignore` voorkomt dit automatisch.

---

## 📊 GitHub Repository Instellingen

Na upload, configureer:

### 1. Topics (Tags)
Ga naar Settings → Topics, voeg toe:
```
proxmox
ceph
kubernetes-alternative
devops
infrastructure-as-code
gameserver
clustering
```

### 2. Description
```
Production-ready Proxmox cluster setup for 5× MS-01 nodes with Ceph storage, 
High Availability, and monitoring. Fully automated installer with 70+ cores, 
160GB RAM, and 5TB storage.
```

### 3. README Badge (optioneel)

Voeg dit toe bovenaan je README.md:

```markdown
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/YOUR-USERNAME/gameserver-proxmox-cluster.svg)](https://github.com/YOUR-USERNAME/gameserver-proxmox-cluster/issues)
[![GitHub stars](https://img.shields.io/github/stars/YOUR-USERNAME/gameserver-proxmox-cluster.svg)](https://github.com/YOUR-USERNAME/gameserver-proxmox-cluster)
```

---

## 🎯 GitHub Actions (Optioneel)

Voeg CI/CD toe door `.github/workflows/` aan te maken:

```bash
mkdir -p .github/workflows
```

Voorbeeld workflow (`.github/workflows/lint.yml`):

```yaml
name: Lint Scripts

on: [push, pull_request]

jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run ShellCheck
        run: |
          sudo apt-get install shellcheck
          shellcheck cluster/*.sh scripts/*.sh
```

---

## 📈 Repository Management

### Branches (optioneel)
```bash
# Main branch = production-ready
# Develop development features in separate branches

git checkout -b feature/docker-compose-support
# ... make changes ...
git push -u origin feature/docker-compose-support

# Then create Pull Request op GitHub
```

### Releases (optioneel)
```bash
# Tag a release
git tag -a v1.0 -m "Initial stable release"
git push origin v1.0

# Op GitHub: Releases → Create new release
```

---

## ✅ Checklist

- [ ] GitHub account
- [ ] New repository created
- [ ] Local git initialized
- [ ] Files committed
- [ ] Pushed to main branch
- [ ] .gitignore working (config-cluster.env NOT uploaded)
- [ ] README visible on GitHub
- [ ] Topics/tags added
- [ ] Description filled in

---

## 🚀 Share je Repository

Zodra je het geupload hebt:

```
https://github.com/YOUR-USERNAME/gameserver-proxmox-cluster
```

Deel deze link met je team! 🎉

---

## 📞 Troubleshooting

### "fatal: not a git repository"
```bash
cd /home/patrick/Downloads/5pccluster
git init
```

### "Permission denied (publickey)"
Setup SSH keys (zie stap 3 hierboven)

### "fatal: remote origin already exists"
```bash
git remote remove origin
git remote add origin https://github.com/YOUR-USERNAME/...
```

### "failed to push some refs"
```bash
git pull origin main
git push origin main
```

---

**Vragen? Check GitHub docs: https://docs.github.com**
