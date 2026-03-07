#!/bin/bash
################################################################################
# GitHub Pages Custom Domain Setup Script
# Purpose: Automate the GitHub-side setup for adding a custom domain to GitHub Pages
# Domain: shweba2.dpdns.org
# Usage: bash setup-custom-domain.sh
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# SECTION 1: CNAME FILE SETUP
################################################################################

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}GitHub Pages Custom Domain Setup${NC}"
echo -e "${BLUE}Domain: shweba2.dpdns.org${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"

# Define the domain and CNAME file location
DOMAIN="shweba2.dpdns.org"
CNAME_FILE="CNAME"
REPO_ROOT="$(git rev-parse --show-toplevel)"

echo -e "${YELLOW}[Step 1] Creating/Verifying CNAME file...${NC}"

# Check if CNAME already exists
if [ -f "$CNAME_FILE" ]; then
  EXISTING_DOMAIN=$(cat "$CNAME_FILE")
  if [ "$EXISTING_DOMAIN" = "$DOMAIN" ]; then
    echo -e "${GREEN}✓ CNAME file already exists with correct domain: $DOMAIN${NC}\n"
  else
    echo -e "${YELLOW}⚠ CNAME file exists but contains: $EXISTING_DOMAIN${NC}"
    read -p "Overwrite with $DOMAIN? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "$DOMAIN" > "$CNAME_FILE"
      echo -e "${GREEN}✓ CNAME file updated with: $DOMAIN${NC}\n"
    else
      echo -e "${RED}✗ Aborted. CNAME file not modified.${NC}\n"
      exit 1
    fi
  fi
else
  # Create the CNAME file
  echo "$DOMAIN" > "$CNAME_FILE"
  echo -e "${GREEN}✓ Created CNAME file with domain: $DOMAIN${NC}\n"
fi

################################################################################
# SECTION 2: GIT COMMIT & PUSH
################################################################################

echo -e "${YELLOW}[Step 2] Committing and pushing CNAME file...${NC}"

# Check if there are changes to commit
if git diff --name-only --exit-code | grep -q "CNAME" || [ ! -z "$(git status --porcelain | grep CNAME)" ]; then
  # Stage the CNAME file
  git add "$CNAME_FILE"
  echo -e "${GREEN}✓ Staged CNAME file${NC}"

  # Commit the file
  git commit -m "Add custom domain CNAME for GitHub Pages" --quiet
  echo -e "${GREEN}✓ Committed: 'Add custom domain CNAME for GitHub Pages'${NC}"

  # Push to main branch
  git push origin main --quiet
  echo -e "${GREEN}✓ Pushed to main branch${NC}\n"
else
  echo -e "${GREEN}✓ CNAME file already committed (no changes to push)${NC}\n"
fi

################################################################################
# SECTION 3: VERIFICATION
################################################################################

echo -e "${YELLOW}[Step 3] Verifying CNAME file...${NC}"

if [ -f "$CNAME_FILE" ]; then
  CNAME_CONTENT=$(cat "$CNAME_FILE")
  echo -e "${GREEN}✓ Repository contains CNAME file${NC}"
  echo -e "${GREEN}  Content: $CNAME_CONTENT${NC}\n"
else
  echo -e "${RED}✗ CNAME file not found!${NC}\n"
  exit 1
fi

################################################################################
# SECTION 4: DNS CONFIGURATION INSTRUCTIONS
################################################################################

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}[CRITICAL] DNS Configuration Required${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}The CNAME file has been set up on GitHub, but GitHub Pages won't work${NC}"
echo -e "${YELLOW}until you configure DNS records at your domain provider (dpdns.org).${NC}\n"

echo -e "${BLUE}Choose ONE of the following DNS configuration options:${NC}\n"

echo -e "${BLUE}┌─ OPTION A: A Records (Recommended for Apex Domain)${NC}"
echo -e "${BLUE}│${NC}"
echo -e "${BLUE}│  If shweba2.dpdns.org is served from an apex domain, add these A records:${NC}"
echo -e "${BLUE}│${NC}"
echo -e "${GREEN}  185.199.108.153${NC}"
echo -e "${GREEN}  185.199.109.153${NC}"
echo -e "${GREEN}  185.199.110.153${NC}"
echo -e "${GREEN}  185.199.111.153${NC}"
echo -e "${BLUE}│${NC}"
echo -e "${BLUE}│  (All four IPs are required for redundancy and HTTPS)${NC}"
echo -e "${BLUE}└${NC}\n"

echo -e "${BLUE}┌─ OPTION B: CNAME Record (Subdomain)${NC}"
echo -e "${BLUE}│${NC}"
echo -e "${BLUE}│  If shweba2.dpdns.org is a subdomain, add this CNAME:${NC}"
echo -e "${BLUE}│${NC}"
echo -e "${GREEN}  shweba2.dpdns.org → shweba2.github.io${NC}"
echo -e "${BLUE}│${NC}"
echo -e "${BLUE}└${NC}\n"

echo -e "${YELLOW}⚠ IMPORTANT DNS NOTES:${NC}"
echo -e "  • If using Cloudflare, disable the orange proxy cloud (use DNS only)"
echo -e "  • DNS changes can take 24-48 hours to fully propagate"
echo -e "  • You can check propagation using the commands below\n"

################################################################################
# SECTION 5: DNS PROPAGATION CHECK (OPTIONAL)
################################################################################

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}[Optional] DNS Propagation Check${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}Run these commands to check if DNS has propagated:${NC}\n"

# Check which DNS tools are available
if command -v nslookup &> /dev/null; then
  echo -e "${BLUE}Using nslookup:${NC}"
  echo -e "${GREEN}nslookup shweba2.dpdns.org${NC}\n"
  
  echo -e "${YELLOW}Would you like to run DNS check now? (y/n):${NC}"
  read -p "" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Running: nslookup shweba2.dpdns.org${NC}\n"
    nslookup shweba2.dpdns.org || echo -e "${YELLOW}DNS not yet propagated (expected if just configured)${NC}"
    echo
  fi
elif command -v dig &> /dev/null; then
  echo -e "${BLUE}Using dig (more detailed):${NC}"
  echo -e "${GREEN}dig shweba2.dpdns.org${NC}\n"
  
  echo -e "${YELLOW}Would you like to run DNS check now? (y/n):${NC}"
  read -p "" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Running: dig shweba2.dpdns.org${NC}\n"
    dig shweba2.dpdns.org || echo -e "${YELLOW}DNS not yet propagated (expected if just configured)${NC}"
    echo
  fi
else
  echo -e "${YELLOW}nslookup and dig not available. Install bind-utils (or dnsutils on Debian):${NC}"
  echo -e "${GREEN}sudo apt-get install dnsutils${NC}\n"
fi

################################################################################
# SECTION 6: HTTPS SETUP REMINDER
################################################################################

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Next Steps After DNS Propagation${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}Once DNS propagation is confirmed (check steps above):${NC}\n"
echo -e "  1. Visit your GitHub repository settings:"
echo -e "     ${GREEN}https://github.com/shweba2/IT-Pulse/settings/pages${NC}\n"
echo -e "  2. You should see that GitHub has recognized shweba2.dpdns.org"
echo -e "     (This may take a few minutes after DNS propagation)\n"
echo -e "  3. Enable 'Enforce HTTPS' checkbox"
echo -e "     ${YELLOW}(GitHub will provide an SSL certificate via Let's Encrypt)${NC}\n"
echo -e "  4. Your site will be live at: ${GREEN}https://shweba2.dpdns.org${NC}\n"

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ GitHub-side setup complete!${NC}"
echo -e "${YELLOW}⏳ Waiting for: DNS configuration + propagation${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"

exit 0
