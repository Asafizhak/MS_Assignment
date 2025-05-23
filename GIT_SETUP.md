# Git Authentication Setup

You're getting a push error because you need to authenticate with GitHub. Here are the authentication options:

## Option 1: Personal Access Token (Recommended)

### Step 1: Create a Personal Access Token
1. Go to GitHub.com → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a name like "MS_Assignment_Token"
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)
5. Click "Generate token"
6. **Copy the token immediately** (you won't see it again)

### Step 2: Configure Git with Token
```bash
# Set your GitHub username
git config --global user.name "Your GitHub Username"
git config --global user.email "your-email@example.com"

# When pushing, use token as password
git push origin main
# Username: your-github-username
# Password: paste-your-personal-access-token-here
```

### Step 3: Store Credentials (Optional)
To avoid entering credentials every time:
```bash
# Store credentials in Git credential manager
git config --global credential.helper store

# Or use Windows Credential Manager (if on Windows)
git config --global credential.helper manager-core
```

## Option 2: SSH Key Authentication

### Step 1: Generate SSH Key
```bash
# Generate new SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# Start SSH agent
eval "$(ssh-agent -s)"

# Add SSH key to agent
ssh-add ~/.ssh/id_ed25519
```

### Step 2: Add SSH Key to GitHub
```bash
# Copy public key to clipboard
cat ~/.ssh/id_ed25519.pub
```

1. Go to GitHub.com → Settings → SSH and GPG keys
2. Click "New SSH key"
3. Paste your public key
4. Give it a title and save

### Step 3: Change Remote URL to SSH
```bash
# Change remote URL from HTTPS to SSH
git remote set-url origin git@github.com:Asafizhak/MS_Assignment.git

# Test connection
ssh -T git@github.com

# Now you can push
git push origin main
```

## Option 3: GitHub CLI (Easiest)

### Step 1: Install GitHub CLI
```bash
# Windows (using winget)
winget install --id GitHub.cli

# Or download from: https://cli.github.com/
```

### Step 2: Authenticate
```bash
# Login to GitHub
gh auth login

# Follow the prompts:
# - Choose GitHub.com
# - Choose HTTPS
# - Authenticate via web browser
```

### Step 3: Push Changes
```bash
git push origin main
```

## Quick Fix for Current Situation

If you want to push immediately, use Personal Access Token:

```bash
# Add and commit your changes
git add .
git commit -m "Add modular Terraform project for ACR with remote state"

# Push with token authentication
git push https://your-token@github.com/Asafizhak/MS_Assignment.git main
```

Replace `your-token` with your actual Personal Access Token.

## Troubleshooting

### Error: "Support for password authentication was removed"
- GitHub no longer accepts passwords for Git operations
- You must use a Personal Access Token or SSH key

### Error: "Permission denied (publickey)"
- Your SSH key is not properly configured
- Make sure you added the public key to your GitHub account

### Error: "Authentication failed"
- Check your username and token/password
- Ensure the token has the correct permissions

## Security Best Practices

1. **Never commit tokens or passwords** to your repository
2. **Use environment variables** for sensitive data
3. **Set token expiration dates** for security
4. **Use SSH keys** for better security (no password needed)
5. **Enable 2FA** on your GitHub account

## Next Steps After Authentication

Once you can push successfully:

1. **Push your code**:
   ```bash
   git push origin main
   ```

2. **Set up GitHub Secrets** for Terraform deployment:
   - Go to your repository → Settings → Secrets and variables → Actions
   - Add the Azure secrets mentioned in the README

3. **Test the GitHub Actions workflow**:
   - The workflow will trigger automatically on push to main
   - Check the Actions tab to see the deployment progress

Your Terraform project is ready - you just need to authenticate with GitHub first!