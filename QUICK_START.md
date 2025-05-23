# 🚀 Quick Start Guide - How to Run the Interactive Script

## Step-by-Step Instructions for Windows

### 1. Open Command Prompt
- Press `Windows + R`
- Type `cmd` and press Enter
- Or search for "Command Prompt" in Start menu

### 2. Navigate to Your Project Directory
```cmd
cd c:\MS_Assignment
```
(Replace with your actual project path)

### 3. Run the Interactive Script
```cmd
make quick-manage
```

**Alternative for Windows (if make doesn't work):**
```cmd
scripts\quick-manage.bat
```

## What You'll See

The script will launch an interactive menu like this:

```
🚀 AKS Infrastructure Quick Manager
==================================

[INFO] Checking current infrastructure status...
[SUCCESS] Infrastructure is currently DESTROYED
[SUCCESS] Monthly cost: $0

Available actions:
  1) Deploy infrastructure (AKS + ACR + NGINX)
  2) Destroy infrastructure (save costs)
  3) Show current status
  4) Show cost information
  5) Exit

Choose an action (1-5):
```

## How to Use the Menu

### To Deploy Infrastructure:
1. Type `1` and press Enter
2. The script will automatically:
   - Initialize Terraform
   - Deploy AKS cluster
   - Deploy ACR
   - Install NGINX Ingress
   - Show you the results

### To Destroy Infrastructure:
1. Type `2` and press Enter
2. Confirm when prompted (type `y`)
3. Everything gets destroyed to save costs

### To Check Status:
1. Type `3` and press Enter
2. See if infrastructure is deployed or destroyed
3. View current monthly costs

## Alternative: Direct Commands

If you prefer direct commands instead of the interactive menu:

### Deploy Everything:
```bash
make init
make dev-deploy-all
```

### Destroy Everything:
```bash
make dev-destroy
```

### Check Status:
```bash
make aks-info
```

## Prerequisites

Make sure you have these installed:
- ✅ Azure CLI (`az --version`)
- ✅ Terraform (`terraform --version`)
- ✅ Make utility (usually pre-installed)

## Example Session

Here's what a complete session looks like:

```bash
# Navigate to project
cd c:/MS_Assignment

# Run interactive script
make quick-manage

# You'll see the menu, choose option 1 to deploy
Choose an action (1-5): 1

# Wait 2-3 minutes for deployment
🏗️ Deploying infrastructure...
✅ Ready to use!

# Later, choose option 2 to destroy
Choose an action (1-5): 2
Are you sure you want to destroy everything? (y/N): y

# Wait 1-2 minutes for destruction
💥 Destroying infrastructure...
✅ Infrastructure destroyed - $0/month cost!
```

## Troubleshooting for Windows

### If `make quick-manage` doesn't work:

**Option 1: Run Windows batch script directly**
```cmd
scripts\quick-manage.bat
```

**Option 2: Check if Make is installed**
```cmd
make --version
```
If Make is not installed, always use Option 1 above.

**Option 3: Install Make for Windows**
- Install Chocolatey: https://chocolatey.org/install
- Then run: `choco install make`

### If you get "command not found" errors:

**For Terraform:**
- Download from: https://www.terraform.io/downloads
- Add to PATH environment variable

**For Azure CLI:**
- Download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows
- Or run: `winget install Microsoft.AzureCLI`

### Windows-Specific Notes:
```cmd
# Make script executable
chmod +x scripts/quick-manage.sh
```

## What Each Option Does

| Menu Option | What It Does | Time | Cost Impact |
|-------------|--------------|------|-------------|
| **1) Deploy** | Creates full AKS+ACR infrastructure | ~2 min | Starts billing (~$55/month) |
| **2) Destroy** | Deletes all infrastructure | ~2 min | Stops billing ($0/month) |
| **3) Status** | Shows current state and costs | Instant | No change |
| **4) Cost Info** | Displays cost breakdown | Instant | No change |
| **5) Exit** | Closes the script | Instant | No change |

## 💡 Pro Tips

1. **Always check status first** (option 3) to see what's currently deployed
2. **Use option 4** to understand costs before deploying
3. **Remember to destroy** (option 2) when finished to save money
4. **Keep the terminal open** during deploy/destroy to see progress

---

**Ready to try it?** Just run: `make quick-manage` from your project directory!