#!/bin/bash
################################################################################
# DNS Troubleshooting & Diagnostics Script
# Purpose: Debug why HTTPS isn't working on GitHub Pages custom domain
# Domain: shweba2.dpdns.org
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}GitHub Pages HTTPS Troubleshooting${NC}"
echo -e "${MAGENTA}Domain: shweba2.dpdns.org${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"

################################################################################
# TEST 1: Check if CNAME file exists locally
################################################################################

echo -e "${YELLOW}[Test 1] Verifying CNAME file in repository...${NC}\n"

if [ -f "CNAME" ]; then
  CNAME_CONTENT=$(cat CNAME)
  echo -e "${GREEN}✓ CNAME file exists${NC}"
  echo -e "  Content: ${GREEN}$CNAME_CONTENT${NC}\n"
  
  if [ "$CNAME_CONTENT" = "shweba2.dpdns.org" ]; then
    echo -e "${GREEN}✓ CNAME contains correct domain${NC}\n"
  else
    echo -e "${RED}✗ CNAME contains wrong domain: $CNAME_CONTENT${NC}"
    echo -e "${RED}  Expected: shweba2.dpdns.org${NC}\n"
  fi
else
  echo -e "${RED}✗ CNAME file not found in repository!${NC}\n"
  exit 1
fi

################################################################################
# TEST 2: Check DNS resolution from Codespace
################################################################################

echo -e "${YELLOW}[Test 2] Testing DNS resolution...${NC}\n"

if command -v nslookup &> /dev/null; then
  echo -e "${BLUE}Running: nslookup shweba2.dpdns.org${NC}\n"
  nslookup shweba2.dpdns.org || {
    echo -e "${RED}✗ DNS lookup failed (NXDOMAIN)${NC}\n"
    echo -e "${YELLOW}DIAGNOSTIC: The CNAME record is NOT pointing to shweba2.github.io${NC}\n"
  }
elif command -v dig &> /dev/null; then
  echo -e "${BLUE}Running: dig shweba2.dpdns.org${NC}\n"
  dig shweba2.dpdns.org || {
    echo -e "${RED}✗ DNS lookup failed${NC}\n"
  }
else
  echo -e "${YELLOW}⚠ nslookup/dig not found. Installing dnsutils...${NC}\n"
  sudo apt-get update -qq && sudo apt-get install -y dnsutils &> /dev/null
  echo -e "${BLUE}Running: nslookup shweba2.dpdns.org${NC}\n"
  nslookup shweba2.dpdns.org || {
    echo -e "${RED}✗ DNS lookup failed (NXDOMAIN)${NC}\n"
  }
fi

echo
echo -e "${YELLOW}Expected Output:${NC}"
echo -e "  ${GREEN}Name:    shweba2.dpdns.org${NC}"
echo -e "  ${GREEN}Address: 185.199.108.153 (or 109, 110, 111)${NC}\n"

################################################################################
# TEST 3: Check GitHub Pages settings reflection
################################################################################

echo -e "${YELLOW}[Test 3] Checking GitHub Pages configuration...${NC}\n"

echo -e "${BLUE}GitHub Pages Settings URL:${NC}"
echo -e "${GREEN}https://github.com/shweba2/IT-Pulse/settings/pages${NC}\n"

echo -e "${YELLOW}What to look for:${NC}"
echo -e "  ✓ Custom domain field: ${GREEN}shweba2.dpdns.org${NC}"
echo -e "  ✓ Status: ${GREEN}DNS configured (checkmark)${NC}"
echo -e "  ✓ HTTPS checkbox: ${GREEN}Enforce HTTPS (should be available)${NC}\n"

if grep -q "shweba2.dpdns.org" CNAME 2>/dev/null; then
  echo -e "${YELLOW}Visit GitHub Pages settings and check if:${NC}"
  echo -e "  1. Custom domain shows: ${GREEN}shweba2.dpdns.org${NC}"
  echo -e "  2. DNS check: GREEN CHECKMARK (not yellow/red)${NC}"
  echo -e "  3. Enforce HTTPS: Available to turn on${NC}\n"
fi

################################################################################
# TEST 4: Detailed diagnosis
################################################################################

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}DIAGNOSIS & SOLUTIONS${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"

echo -e "${RED}Error: 'Domain is not eligible for HTTPS'${NC}\n"
echo -e "${YELLOW}This means: GitHub cannot verify your domain ownership.${NC}\n"

echo -e "${MAGENTA}Most Common Causes & Fixes:${NC}\n"

echo -e "${BLUE}1. CNAME Record Not Configured at dpdns.org${NC}"
echo -e "${YELLOW}   Diagnosis:${NC} nslookup above shows NXDOMAIN"
echo -e "${YELLOW}   Fix:${NC}"
echo -e "     a. Log in to dpdns.org"
echo -e "     b. Go to DNS management for shweba2.dpdns.org"
echo -e "     c. Verify CNAME record exists:"
echo -e "        ${GREEN}Name: shweba2 (or @)${NC}"
echo -e "        ${GREEN}Type: CNAME${NC}"
echo -e "        ${GREEN}Value: shweba2.github.io${NC}"
echo -e "     d. If missing, CREATE it"
echo -e "     e. Wait 5 minutes and test again\n"

echo -e "${BLUE}2. Wrong CNAME Target${NC}"
echo -e "${YELLOW}   Diagnosis:${NC} nslookup shows different target than shweba2.github.io"
echo -e "${YELLOW}   Fix:${NC}"
echo -e "     a. Verify CNAME points to: ${GREEN}shweba2.github.io${NC}"
echo -e "     b. NOT to IP addresses (those are for A records)"
echo -e "     c. Edit the CNAME record and correct the value\n"

echo -e "${BLUE}3. Confusion: A Records vs. CNAME${NC}"
echo -e "${YELLOW}   Diagnosis:${NC} You set A records instead of CNAME"
echo -e "${YELLOW}   Fix:${NC}"
echo -e "     a. Delete A records if they exist"
echo -e "     b. Create CNAME: ${GREEN}shweba2.dpdns.org → shweba2.github.io${NC}"
echo -e "     c. (A records are for apex domains, CNAME for subdomains)\n"

echo -e "${BLUE}4. Pro Propagation & TTL Issues${NC}"
echo -e "${YELLOW}   Diagnosis:${NC} Propagation still in progress (rare after 2+ hours)"
echo -e "${YELLOW}   Fix:${NC}"
echo -e "     a. Use specific DNS server to bypass local cache:"
echo -e "        ${GREEN}nslookup shweba2.dpdns.org 8.8.8.8${NC}"
echo -e "     b. Clear local DNS cache:"
echo -e "        ${GREEN}sudo systemd-resolve --flush-caches${NC}"
echo -e "     c. Wait another 30 minutes (rare)\n"

echo -e "${BLUE}5. GitHub Hasn't Re-Checked Yet${NC}"
echo -e "${YELLOW}   Diagnosis:${NC} DNS is correct, but GitHub shows old status"
echo -e "${YELLOW}   Fix:${NC}"
echo -e "     a. Go to GitHub Pages settings"
echo -e "     b. Remove custom domain (clear the field)"
echo -e "     c. Save"
echo -e "     d. Add it back: ${GREEN}shweba2.dpdns.org${NC}"
echo -e "     e. GitHub will re-verify DNS\n"

################################################################################
# TEST 5: Manual verification steps
################################################################################

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Next Steps: Complete This Checklist${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}[ ] 1. Log in to dpdns.org account${NC}"
echo -e "${YELLOW}[ ] 2. Find DNS settings for shweba2.dpdns.org${NC}"
echo -e "${YELLOW}[ ] 3. Look for CNAME record:${NC}"
echo -e "       ${GREEN}shweba2.dpdns.org → shweba2.github.io${NC}"
echo -e "${YELLOW}[ ] 4. If missing, create it${NC}"
echo -e "${YELLOW}[ ] 5. If wrong, edit to match above${NC}"
echo -e "${YELLOW}[ ] 6. Delete any A records (if you added those instead)${NC}"
echo -e "${YELLOW}[ ] 7. Save changes at dpdns.org${NC}"
echo -e "${YELLOW}[ ] 8. Wait 5 minutes${NC}"
echo -e "${YELLOW}[ ] 9. Run this script again to verify${NC}"
echo -e "${YELLOW}[ ] 10. Once DNS resolves, go to GitHub Pages settings${NC}"
echo -e "${YELLOW}[ ] 11. Click 'Re-check' or remove/re-add custom domain${NC}"
echo -e "${YELLOW}[ ] 12. Wait 5 minutes for HTTPS eligibility${NC}"
echo -e "${YELLOW}[ ] 13. Enable 'Enforce HTTPS'${NC}\n"

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Troubleshooting script complete. Fix DNS and re-run to verify.${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"

exit 0
