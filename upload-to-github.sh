#!/bin/bash
###############################################################################
# GitHub Upload Helper
# Automatiseert de upload van je Proxmox cluster setup naar GitHub
###############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║             📤 GITHUB UPLOAD HELPER                                      ║
║             Proxmox Cluster Setup                                        ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF

echo ""
echo -e "${BLUE}Dit script helpt je om je project naar GitHub te uploaden${NC}"
echo ""

# Check git installation
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git niet geïnstalleerd!${NC}"
    echo "   Installeer: sudo apt install git"
    exit 1
fi

echo -e "${GREEN}✅ Git gedetecteerd${NC}"

# Get GitHub username
echo ""
read -p "GitHub username (bijv: your-username): " GITHUB_USER

if [ -z "$GITHUB_USER" ]; then
    echo -e "${RED}❌ Username is vereist${NC}"
    exit 1
fi

# Get repository name
echo ""
read -p "Repository naam (default: gameserver-proxmox-cluster): " REPO_NAME
REPO_NAME=${REPO_NAME:-gameserver-proxmox-cluster}

echo ""
read -p "Repository type [public/private] (default: public): " REPO_TYPE
REPO_TYPE=${REPO_TYPE:-public}

# Show summary
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}UPLOAD INSTELLINGEN${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "GitHub User:      $GITHUB_USER"
echo "Repository:       $REPO_NAME"
echo "Type:             $REPO_TYPE"
echo "URL:              https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""

read -p "Kloppen deze instellingen? [Y/n]: " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Geannuleerd"
    exit 0
fi

echo ""
echo -e "${BLUE}📋 STAP 1: Controleer de .gitignore${NC}"
echo ""

if [ -f ".gitignore" ]; then
    echo -e "${GREEN}✅ .gitignore gevonden${NC}"
    echo ""
    echo "Inhoud:"
    cat .gitignore
    echo ""
else
    echo -e "${YELLOW}⚠️  .gitignore niet gevonden${NC}"
fi

echo ""
echo -e "${BLUE}📋 STAP 2: Controleer wat geuploaded wordt${NC}"
echo ""

# Show files that will be committed
echo "Files die geuploaded worden:"
git status --porcelain 2>/dev/null || echo "Git niet geïnitialiseerd - volgende stap initialiseert"

echo ""
read -p "Ziet dit er goed uit? [Y/n]: " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Geannuleerd"
    exit 0
fi

echo ""
echo -e "${BLUE}📋 STAP 3: Git initialiseren${NC}"
echo ""

if [ ! -d ".git" ]; then
    echo "Git repository initialiseren..."
    git init
    echo -e "${GREEN}✅ Git geïnitialiseerd${NC}"
else
    echo -e "${GREEN}✅ Git repository bestaat al${NC}"
fi

# Check if remote exists
if git remote get-url origin &>/dev/null; then
    CURRENT_URL=$(git remote get-url origin)
    echo "Huidige remote: $CURRENT_URL"
    
    read -p "Remote vervangen? [Y/n]: " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote remove origin
    else
        echo "Huidge remote behouden"
    fi
else
    echo "Geen remote geconfigureerd"
fi

echo ""
echo -e "${BLUE}📋 STAP 4: Remote URL instellen${NC}"
echo ""

REMOTE_URL="https://github.com/$GITHUB_USER/$REPO_NAME.git"
echo "Remote URL: $REMOTE_URL"

if ! git remote get-url origin &>/dev/null; then
    git remote add origin "$REMOTE_URL"
    echo -e "${GREEN}✅ Remote URL ingesteld${NC}"
else
    echo -e "${GREEN}✅ Remote URL bestaat al${NC}"
fi

echo ""
echo -e "${BLUE}📋 STAP 5: Files toevoegen${NC}"
echo ""

git add .
echo -e "${GREEN}✅ Files toegevoegd${NC}"

echo ""
echo -e "${BLUE}📋 STAP 6: Initial commit${NC}"
echo ""

if git diff --cached --quiet; then
    echo "Geen wijzigingen om te committen"
else
    git commit -m "Initial commit: Complete Proxmox cluster setup for 5× MS-01 nodes

- Master installer with interactive menu
- 8 setup scripts (network, ceph, ha, monitoring)
- Utility scripts (backup, health-check)
- Complete documentation (README, QUICKSTART)
- Configuration template pre-filled for 5× MS-01"
    
    echo -e "${GREEN}✅ Commit gemaakt${NC}"
fi

echo ""
echo -e "${YELLOW}⚠️  HANDMATIGE STAPPEN NODIG:${NC}"
echo ""
echo "1. Ga naar: https://github.com/new"
echo "   Creëer een nieuwe repository met:"
echo "   - Naam: $REPO_NAME"
echo "   - Visibility: $REPO_TYPE"
echo ""
echo "2. Voer dit uit om te pushen:"
echo ""
echo -e "   ${BLUE}git branch -M main${NC}"
echo -e "   ${BLUE}git push -u origin main${NC}"
echo ""
echo "3. (Optioneel) Setup SSH keys voor toekomstige pushes:"
echo ""
echo -e "   ${BLUE}ssh-keygen -t ed25519 -C 'your-email@example.com'${NC}"
echo -e "   ${BLUE}cat ~/.ssh/id_ed25519.pub${NC}"
echo "   Paste dit op: https://github.com/settings/keys"
echo ""

echo -e "${GREEN}✅ Git is klaar om te pushen!${NC}"
echo ""
echo "Je repository URL zal zijn:"
echo -e "${BLUE}https://github.com/$GITHUB_USER/$REPO_NAME${NC}"
echo ""

read -p "Wil je nu pushen naar GitHub? [y/N]: " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Pushing naar GitHub..."
    echo ""
    
    git branch -M main
    
    if git push -u origin main 2>&1; then
        echo ""
        echo -e "${GREEN}✅ UPLOAD VOLTOOID!${NC}"
        echo ""
        echo "Je repository is nu beschikbaar op:"
        echo -e "${BLUE}https://github.com/$GITHUB_USER/$REPO_NAME${NC}"
        echo ""
    else
        echo ""
        echo -e "${YELLOW}⚠️  Push mislukt${NC}"
        echo "Mogelijke oorzaken:"
        echo "  1. Repository bestaat nog niet (creëer op GitHub)"
        echo "  2. SSH key niet ingesteld (gebruik HTTPS in config)"
        echo ""
        echo "Probeer handmatig:"
        echo -e "  ${BLUE}git push -u origin main${NC}"
    fi
else
    echo ""
    echo "Push later uit met:"
    echo -e "${BLUE}git push -u origin main${NC}"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
