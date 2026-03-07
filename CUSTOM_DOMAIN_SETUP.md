# Custom Domain Setup Guide for GitHub Pages

## Overview

This guide walks you through setting up a custom domain (`shweba2.dpdns.org`) for your GitHub Pages site (IT-Pulse) using an automated Bash script.

## Architecture

The setup process involves **two independent systems**:

1. **GitHub (this Codespace)** — Configures the repository to recognize your custom domain
2. **DNS Provider (dpdns.org)** — Routes traffic from your domain to GitHub's servers

Both must be configured for your site to work.

---

## Quick Start (3 Steps)

### Step 1: Run the Setup Script

```bash
cd /workspaces/IT-Pulse
bash setup-custom-domain.sh
```

This will:
- ✓ Create/verify the CNAME file
- ✓ Commit and push it to GitHub
- ✓ Display DNS configuration instructions
- ✓ Offer to check DNS propagation

### Step 2: Configure DNS at dpdns.org

Log in to your dpdns.org account and add ONE of these options:

**Option A: A Records** (if shweba2.dpdns.org is the apex/root domain)
```
Type: A  Record: 185.199.108.153
Type: A  Record: 185.199.109.153
Type: A  Record: 185.199.110.153
Type: A  Record: 185.199.111.153
```

**Option B: CNAME Record** (if shweba2.dpdns.org is a subdomain)
```
Type: CNAME  Value: shweba2.github.io
```

⚠️ **Important:**
- If using Cloudflare, set DNS-only mode (gray cloud, not orange)
- Disable any proxy/firewall that might interfere
- DNS propagation takes 5 minutes to 48 hours

### Step 3: Enable HTTPS on GitHub

After DNS propagates (DNS check passes):
1. Open: https://github.com/shweba2/IT-Pulse/settings/pages
2. Verify GitHub recognizes your custom domain
3. Check "Enforce HTTPS"
4. GitHub provides a free SSL cert via Let's Encrypt

Your site will be live at: **https://shweba2.dpdns.org**

---

## Detailed Reference

### What the Script Does

**1. Creates CNAME File**
- Generates a file named `CNAME` in the repo root
- Contains one line: `shweba2.dpdns.org`
- If CNAME already exists, prompts before overwriting

**2. Commits & Pushes**
- Stages: `git add CNAME`
- Commits: `git commit -m "Add custom domain CNAME for GitHub Pages"`
- Pushes: `git push origin main`
- Skips if no changes detected

**3. Verifies Setup**
- Confirms CNAME file exists and is readable
- Exit code indicates success (0) or failure (1)

**4. Provides DNS Instructions**
- Explains the two DNS options (A records vs. CNAME)
- Lists all required IP addresses
- Warns about proxies and propagation delays

**5. Optional DNS Check**
- Offers interactive DNS lookup using `nslookup` or `dig`
- Shows current DNS status (helps diagnose delays)

### How the Script Handles Errors

- **set -e**: Exits immediately if any command fails
- **Git check**: Verifies repo before making commits
- **File validation**: Confirms CNAME was created successfully
- **User confirmation**: Prompts before overwriting existing CNAME

---

## DNS Configuration Details

### Why Both GitHub and DNS Are Needed

| System | Role |
|--------|------|
| **GitHub CNAME** | Tells GitHub Pages: "I own shweba2.dpdns.org" |
| **DNS Records** | Tells the internet: "shweba2.dpdns.org lives at GitHub" |

### A Records vs. CNAME: Which Should You Use?

**Use A Records if:**
- `shweba2.dpdns.org` is your apex/root domain
- You want to point the bare domain (not a subdomain)
- dpdns.org supports apex A records

**Use CNAME if:**
- `shweba2.dpdns.org` is a subdomain (e.g., main domain is `dpdns.org`)
- You're routing through a DNS alias service
- Your DNS provider recommends it

**All Four A Records Required:**
GitHub uses all four IPs for:
- Load balancing
- Redundancy (if one IP goes down, others work)
- HTTPS certificate validation

---

## Testing DNS Propagation

### Manual Checks

Run from Codespace:

```bash
# Option 1: nslookup (simpler)
nslookup shweba2.dpdns.org

# Option 2: dig (more detailed/verbose)
dig shweba2.dpdns.org

# Option 3: Check your public IP (should show GitHub IPs)
curl -I https://shweba2.github.io
```

### Expected Output

**If DNS is propagated (SUCCESS):**
```
$ nslookup shweba2.dpdns.org
Server:  8.8.8.8
Address: 8.8.8.8#53

Non-authoritative answer:
Name:    shweba2.dpdns.org
Address: 185.199.108.153
Address: 185.199.109.153
Address: 185.199.110.153
Address: 185.199.111.153
```

**If DNS hasn't propagated yet (EXPECTED INITIALLY):**
```
$ nslookup shweba2.dpdns.org
Server:  8.8.8.8
Address: 8.8.8.8#53

*** shweba2.dpdns.org can't find shweba2.dpdns.org: NXDOMAIN
```
→ This is OK. Wait and try again in 5-15 minutes.

### Propagation Timeline

| Time | Status | Action |
|------|--------|--------|
| 0-5 min | Not propagated | Freshly configured, keep waiting |
| 5-30 min | Usually propagated | Check DNS or refresh GitHub Pages settings |
| 30 min-2 hrs | Partially propagated | Some servers found it, others haven't |
| 2-48 hrs | Fully propagated | All DNS servers worldwide have updated |

---

## GitHub Pages Settings

Once DNS propagates, configure GitHub:

1. **GitHub Repository Settings:**
   ```
   https://github.com/shweba2/IT-Pulse/settings/pages
   ```

2. **What you'll see:**
   - Source: Deploy from a branch (if set)
   - Branch: main / (root) [or your config]
   - Custom domain: shweba2.dpdns.org ← **will auto-populate**

3. **Enable HTTPS:**
   - Check: ☑ "Enforce HTTPS"
   - GitHub automatically provisions Let's Encrypt certificate
   - Takes 5-30 minutes after DNS propagation

4. **Result:**
   ```
   Your site is published at https://shweba2.dpdns.org
   ```

---

## Troubleshooting

### DNS Check Shows Your Domain But HTTPS Not Working

**Cause:** Certificate is still being generated.  
**Solution:** Wait 10-30 minutes, refresh GitHub Pages settings.

### "CNAME can't be null" Error on GitHub

**Cause:** CNAME file is empty or in wrong place.  
**Solution:** Run the script again, confirm CNAME contains `shweba2.dpdns.org`.

### DNS Shows Old/Wrong Records

**Cause:** DNS cache hasn't cleared.  
**Solution:**
```bash
# Force local DNS cache clear (OS-dependent)
sudo systemd-resolve --flush-caches

# Or use public DNS for testing
nslookup shweba2.dpdns.org 8.8.8.8
```

### GitHub Still Shows "Unverified" After DNS Propagates

**Cause:** GitHub hasn't rechecked DNS yet.  
**Solution:** Wait 5 minutes, then refresh the GitHub Pages settings page.

### HTTPS Enforcement Unavailable (Grayed Out)

**Cause:** DNS hasn't fully propagated or isn't correct.  
**Solution:**
1. Re-run DNS check: `nslookup shweba2.dpdns.org`
2. Verify all 4 A records resolve (or CNAME if using that option)
3. Wait 30 minutes and refresh GitHub settings

---

## Security & HTTPS

### Let's Encrypt Certificate

- **Automatic:** GitHub provides free SSL certificate
- **Duration:** Valid for 90 days, auto-renewed
- **Enforcement:** Check "Enforce HTTPS" to redirect all HTTP → HTTPS
- **Mixed Content:** All resources (CSS, JS, images) must be HTTPS too

### Why HTTPS Matters

- Encrypts traffic between user and GitHub's servers
- Protects against man-in-the-middle attacks
- Required for modern browsers and SEO

---

## What to Do After Setup

1. **Test your site:**
   ```
   https://shweba2.dpdns.org
   ```

2. **Share your new URL:**
   Your GitHub Pages site is now at the custom domain instead of `shweba2.github.io`

3. **Update external references:**
   - Update any links/bookmarks pointing to the old `shweba2.github.io` URL
   - (The old URL still works but redirects to new domain)

4. **Monitor logs (optional):**
   - GitHub Pages build logs: Repository → Actions
   - Verify no build errors occurred

---

## Reference: Script Arguments & Customization

The provided script is **self-contained** and requires no modifications. However, if you need to customize:

### To Change Domain

Edit line in script:
```bash
DOMAIN="your-custom-domain.com"
```

### To Use Different Branch

Edit lines:
```bash
git push origin main  # Change 'main' to your branch
```

### To Add Custom Git Message

Edit line:
```bash
git commit -m "Your custom message"
```

---

## Support & Resources

- **GitHub Pages Docs:** https://docs.github.com/en/pages
- **Custom Domain Setup:** https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site
- **DNS Configuration:** https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site#configuring-a-subdomain

---

## Quick Command Reference

```bash
# Run the setup script
bash setup-custom-domain.sh

# Check DNS manually
nslookup shweba2.dpdns.org
dig shweba2.dpdns.org

# View CNAME file
cat CNAME

# Check git status
git status

# View recent commits
git log --oneline -5
```

---

**Status:** Ready to run!  
**Domain:** shweba2.dpdns.org  
**GitHub Pages Settings:** https://github.com/shweba2/IT-Pulse/settings/pages
