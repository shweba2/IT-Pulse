#!/bin/bash
################################################################################
# Remove Custom Domain Setup
# Purpose: Remove CNAME file since you don't own a custom domain
# Result: Your site will be at https://shweba2.github.io
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Removing Custom Domain Setup${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}[Step 1] Checking CNAME file...${NC}"

if [ -f "CNAME" ]; then
  CNAME_CONTENT=$(cat CNAME)
  echo -e "${GREEN}✓ Found CNAME file with: $CNAME_CONTENT${NC}\n"
  
  echo -e "${YELLOW}[Step 2] Removing CNAME file...${NC}"
  rm CNAME
  echo -e "${GREEN}✓ CNAME file deleted${NC}\n"
  
  echo -e "${YELLOW}[Step 3] Committing changes...${NC}"
  git add -A
  git commit -m "Remove custom domain CNAME - using default GitHub Pages URL"
  git push origin main
  echo -e "${GREEN}✓ Changes pushed to GitHub${NC}\n"
else
  echo -e "${YELLOW}ℹ CNAME file not found - nothing to remove${NC}\n"
fi

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Setup complete!${NC}\n"
echo -e "${YELLOW}Your site is now live at:${NC}"
echo -e "${GREEN}  https://shweba2.github.io${NC}\n"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"

exit 0
