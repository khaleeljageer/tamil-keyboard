# Setting Up GitHub Pages as an APT Repository

This guide explains how to use GitHub Pages to host a Debian/APT repository for your Tamil keyboard packages. This allows users to install your packages directly via `apt install` from your GitHub repository.

## Should You Push Code Along with .deb Packages?

### ❌ **Not Recommended: Source Code + .deb Files in Same Branch**

**Problems:**
- Repository size grows significantly with each release
- Git history becomes bloated with binary files
- Slower clones and operations
- Harder to manage and maintain
- Binary files don't benefit from version control

### ✅ **Recommended Approach: Separate Branches/Repositories**

**Best Practice:**
1. **Main branch** (`main`/`master`): Contains only source code
   - Source package directories (`tamil-keyboard/`, `tamil-keyboard/`)
   - Build scripts and documentation
   - GitHub Actions workflows
   - **No `.deb` files committed**

2. **GitHub Pages branch** (`gh-pages`): Contains only built packages
   - Generated `.deb` files
   - APT repository metadata
   - Automatically updated by GitHub Actions

3. **GitHub Releases**: Optional, for versioned downloads
   - Attach `.deb` files to releases
   - Users can download specific versions
   - Doesn't bloat main repository

**Benefits:**
- ✅ Clean source repository (small, fast)
- ✅ Better Git history (no binary noise)
- ✅ Automated builds via GitHub Actions
- ✅ Easy to maintain and contribute
- ✅ Professional repository structure

**This guide uses the recommended approach.**

## Table of Contents

1. [Repository Structure](#repository-structure)
2. [GitHub Actions Workflow](#github-actions-workflow)
3. [Setting Up GitHub Pages](#setting-up-github-pages)
4. [GPG Key Setup](#gpg-key-setup)
5. [Client Configuration](#client-configuration)
6. [Best Practices](#best-practices)

## Repository Structure

### Recommended Structure

```
tamil-keyboard/
├── .github/
│   └── workflows/
│       └── build-and-publish.yml    # Automated build workflow
├── tamil-keyboard/                # Source package
│   └── debian/
├── tamil-keyboard/          # Source package
│   └── debian/
├── docs/                              # GitHub Pages repository
│   ├── pool/
│   │   └── main/
│   │       └── t/
│   │           ├── tamil-keyboard/
│   │           └── tamil-keyboard/
│   └── dists/
│       └── stable/
│           └── main/
│               └── binary-amd64/
├── README.md
└── .gitignore
```

### Alternative: Separate Repositories

**Option 1: Source Code + Built Packages in Same Repo**
- ✅ Simple, everything in one place
- ❌ Repository size grows with each release
- ❌ Git history includes binary files

**Option 2: Separate Repos (Recommended)**
- ✅ Clean separation of source and binaries
- ✅ Smaller source repository
- ✅ Better for CI/CD
- ✅ Can use GitHub Releases for packages

**Recommended Structure:**
- `tamil-keyboard` - Source code repository
- `tamil-keyboard-repo` - APT repository (GitHub Pages)

## GitHub Actions Workflow

Create `.github/workflows/build-and-publish.yml` to automate building and publishing:

```yaml
name: Build and Publish Debian Packages

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout source code
      uses: actions/checkout@v4
      
    - name: Set up build environment
      run: |
        sudo apt-get update
        sudo apt-get install -y devscripts build-essential debhelper
    
    - name: Build tamil-keyboard
      run: |
        cd tamil-keyboard
        dpkg-buildpackage -b -us -uc
        cd ..
    
    - name: Build tamil-keyboard
      run: |
        cd tamil-keyboard
        dpkg-buildpackage -b -us -uc
        cd ..
    
    - name: Create repository structure
      run: |
        mkdir -p docs/pool/main/t/tamil-keyboard
        mkdir -p docs/dists/stable/main/binary-amd64
    
    - name: Copy packages
      run: |
        cp tamil-keyboard_*.deb docs/pool/main/t/tamil-keyboard/
    
    - name: Generate Packages file
      run: |
        cd docs
        dpkg-scanpackages --arch amd64 pool/ /dev/null | gzip -9c > dists/stable/main/binary-amd64/Packages.gz
    
    - name: Generate Release file
      run: |
        cd docs/dists/stable
        cat > Release <<EOF
        Origin: Kaniyam Foundation
        Label: Tamil Keyboard Repository
        Codename: stable
        Architectures: amd64
        Components: main
        Description: Tamil keyboard layout packages for Debian/Ubuntu
        Date: $(date -u -R)
        EOF
    
    - name: Sign Release file
      env:
        GPG_PRIVATE_KEY: ${{ secrets.GPG_PRIVATE_KEY }}
        GPG_PASSPHRASE: ${{ secrets.GPG_PASSPHRASE }}
      run: |
        echo "$GPG_PRIVATE_KEY" | gpg --import
        cd docs/dists/stable
        gpg --batch --pinentry-mode loopback --passphrase "$GPG_PASSPHRASE" -abs -o Release.gpg Release
    
    - name: Commit and push to docs branch
      run: |
        git config user.name "GitHub Actions"
        git config user.email "actions@github.com"
        git add docs/
        git commit -m "Update repository for $(git describe --tags --always)" || exit 0
        git push origin HEAD:gh-pages || git push origin gh-pages
```

## Setting Up GitHub Pages

### Step 1: Enable GitHub Pages

1. Go to your repository **Settings** → **Pages**
2. Under **Source**, select **Deploy from a branch**
3. Select branch: **gh-pages** (or **main/docs** if using docs folder)
4. Select folder: **/ (root)** or **/docs**
5. Click **Save**

### Step 2: Create Repository Structure

Create the initial repository structure:

```bash
mkdir -p docs/pool/main/t/tamil-keyboard
mkdir -p docs/dists/stable/main/binary-amd64
touch docs/.gitkeep
```

### Step 3: Initial Commit

```bash
git checkout -b gh-pages
git add docs/
git commit -m "Initial repository structure"
git push origin gh-pages
```

## GPG Key Setup

### Step 1: Export Your GPG Key

On your local machine:

```bash
# Export private key (for GitHub Actions)
gpg --armor --export-secret-keys B09F79B51206F699 > private-key.asc

# Export public key (for users)
gpg --armor --export B09F79B51206F699 > public-key.asc
```

### Step 2: Add GitHub Secrets

1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Add the following secrets:
   - `GPG_PRIVATE_KEY`: Contents of `private-key.asc`
   - `GPG_PASSPHRASE`: Your GPG key passphrase (if set)

### Step 3: Host Public Key

Upload `public-key.asc` to your repository root or docs folder so users can download it.

## Client Configuration

Users can add your repository with:

```bash
# Add repository
echo "deb https://khaleeljageer.github.io/tamil-keyboard stable main" | sudo tee /etc/apt/sources.list.d/tamil-keyboard.list

# Download and add GPG key
wget -qO - https://khaleeljageer.github.io/tamil-keyboard/public-key.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/tamil-keyboard.gpg

# Update and install
sudo apt update
sudo apt install tamil-keyboard
```

### Alternative: Using GitHub Releases

If you prefer to use GitHub Releases instead of GitHub Pages:

1. Upload `.deb` files to GitHub Releases
2. Users download and install manually:
   ```bash
   wget https://github.com/khaleeljageer/tamil-keyboard/releases/download/v1.0.0/tamil-keyboard_1.0.0-1_all.deb
   sudo dpkg -i tamil-keyboard_1.0.0-1_all.deb
   sudo apt-get install -f
   ```

## Best Practices

### 1. Repository Organization

**✅ Recommended: Separate Repositories**
- **Source repository**: Contains source code, debian/ directories, build scripts
- **APT repository**: Contains only built `.deb` files and repository metadata (GitHub Pages)

**Why?**
- Keeps source repository clean and small
- Easier to manage releases
- Better Git history (no binary files)
- Can use GitHub Releases for versioning

### 2. Versioning Strategy

```bash
# Tag releases
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# GitHub Actions will automatically build and publish
```

### 3. Security

- ✅ Sign packages with GPG
- ✅ Use GitHub Secrets for sensitive data
- ✅ Verify packages before publishing
- ✅ Use HTTPS for repository access

### 4. Automation

- ✅ Use GitHub Actions for automated builds
- ✅ Build on tag creation
- ✅ Test packages before publishing
- ✅ Generate changelog automatically

### 5. Documentation

Include in your README:

```markdown
## Installation

### From APT Repository

```bash
# Add repository
echo "deb https://khaleeljageer.github.io/tamil-keyboard stable main" | sudo tee /etc/apt/sources.list.d/tamil-keyboard.list

# Add GPG key
wget -qO - https://khaleeljageer.github.io/tamil-keyboard/public-key.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/tamil-keyboard.gpg

# Install
sudo apt update
sudo apt install tamil-keyboard
```

### Manual Installation

Download from [Releases](https://github.com/khaleeljageer/tamil-keyboard/releases) and install:

```bash
sudo dpkg -i tamil-keyboard_*.deb
sudo apt-get install -f
```
```

## Workflow Example

### Development Workflow

1. **Make changes** to source code
2. **Commit and push** to main branch
3. **Create a tag** for release:
   ```bash
   git tag -a v1.0.1 -m "Release 1.0.1"
   git push origin v1.0.1
   ```
4. **GitHub Actions** automatically:
   - Builds packages
   - Signs with GPG
   - Updates APT repository
   - Publishes to GitHub Pages

### Manual Workflow (Alternative)

If you prefer manual control:

1. Build packages locally: `./build-packages.sh`
2. Copy to `docs/pool/main/t/` directories
3. Generate repository metadata
4. Sign Release file
5. Commit and push to `gh-pages` branch

## Troubleshooting

### GitHub Pages Not Updating

- Check GitHub Actions logs
- Verify `gh-pages` branch exists
- Ensure Pages is enabled in Settings
- Check branch protection rules

### GPG Signing Fails

- Verify GPG_PRIVATE_KEY secret is correct
- Check GPG_PASSPHRASE if key is encrypted
- Ensure key ID matches in workflow

### Packages Not Found

- Verify repository structure is correct
- Check Packages.gz is generated
- Ensure Release file is signed
- Verify GitHub Pages is serving files

## Advanced: Multi-Architecture Support

To support multiple architectures, modify the workflow:

```yaml
- name: Generate Packages files for all architectures
  run: |
    cd docs
    for arch in amd64 i386 arm64; do
      mkdir -p dists/stable/main/binary-$arch
      dpkg-scanpackages --arch $arch pool/ /dev/null | gzip -9c > dists/stable/main/binary-$arch/Packages.gz
    done
```

And update Release file:

```
Architectures: amd64 i386 arm64
```

## Summary

**Recommended Approach:**
1. ✅ Keep source code in main repository
2. ✅ Use GitHub Actions to build packages automatically
3. ✅ Publish built packages to GitHub Pages (gh-pages branch)
4. ✅ Use GitHub Releases for versioned downloads
5. ✅ Sign packages with GPG
6. ✅ Provide clear installation instructions

This gives you the best of both worlds: clean source repository and easy-to-use APT repository for end users.

