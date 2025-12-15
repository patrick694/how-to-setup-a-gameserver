#!/bin/bash
###############################################################################
# Health Check - Cluster Diagnostics
###############################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

check() {
    local TEST="$1"
    local CMD="$2"
    
    echo -n "✓ $TEST... "
    if eval "$CMD" &>/dev/null; then
        echo -e "${GREEN}OK${NC}"
        ((PASSED++))
    else
        echo -e "${RED}FAILED${NC}"
        ((FAILED++))
    fi
}

clear
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║          CLUSTER HEALTH CHECK                            ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

echo "🌐 CLUSTER CHECKS"
check "Cluster quorum" "pvecm status | grep -q 'Quorate.*Yes'"
check "5 nodes present" "[ \$(pvecm nodes | tail -5 | wc -l) -eq 5 ]"
check "Corosync running" "systemctl is-active --quiet corosync"

echo ""
echo "🗄️  CEPH CHECKS"
check "Ceph health" "ceph health | grep -q 'HEALTH_OK'"
check "Ceph OSDs" "[ \$(ceph osd ls | wc -l) -ge 5 ]"
check "Ceph monitors" "[ \$(ceph mon ls | wc -l) -ge 3 ]"

echo ""
echo "🎮 VM CHECKS"
check "Panel VM exists" "qm status 100 &>/dev/null"
check "Game nodes exist" "qm status 201 &>/dev/null && qm status 202 &>/dev/null"
check "Monitoring VM exists" "qm status 300 &>/dev/null"

echo ""
echo "🔄 HA CHECKS"
check "HA enabled" "ha-manager config | grep -q critical"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "RESULTS:"
echo -e "  ${GREEN}Passed: $PASSED${NC}"
echo -e "  ${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some checks failed${NC}"
    exit 1
fi
