# Setting Up an APT Repository for Tamil Keyboard Packages

This guide explains how to set up a Debian/APT repository so users can install the packages with `apt install`.

## Quick Setup (Using reprepro)

### 1. Install Required Tools

```bash
sudo apt-get install reprepro gnupg
```

### 2. Create Repository Directory

```bash
export REPO_DIR=/path/to/your/repo
mkdir -p $REPO_DIR/{conf,dists,pool}
```

### 3. Generate GPG Key (if you don't have one)

```bash
gpg --full-generate-key
# Choose: (1) RSA and RSA, 4096 bits, no expiration
# Note your key ID from the output
```

### 4. Create Repository Configuration

Create `$REPO_DIR/conf/distributions`:

```
Origin: Kaniyam Foundation
Label: Tamil Keyboard Repository
Codename: stable
Architectures: amd64 i386 arm64
Components: main
Description: Tamil keyboard layout packages for Debian/Ubuntu
SignWith: YOUR_GPG_KEY_ID
```

Note: Use the last 16 characters of your GPG key fingerprint as the SignWith value. You can find your key ID with `gpg --list-keys` or use the full fingerprint.

### 5. Build the Packages

```bash
cd /home/zs-khaleel/Documents/tamil-keyboard
./build-packages.sh
```

### 6. Add Packages to Repository

```bash
cd $REPO_DIR
reprepro includedeb stable /path/to/tamil-keyboard_*.deb
```

### 7. Export GPG Public Key

```bash
gpg --armor --export YOUR_GPG_KEY_ID > $REPO_DIR/KEY.gpg
```

### 8. Serve the Repository

#### Option A: Using Apache/Nginx

Configure your web server to serve `$REPO_DIR` directory.

#### Option B: Using Python (for testing)

```bash
cd $REPO_DIR
python3 -m http.server 8000
```

### 9. Client Configuration

On client systems, add the repository:

```bash
# Add repository
echo "deb http://your-server:8000 stable main" | sudo tee /etc/apt/sources.list.d/tamil-keyboard.list

# Add GPG key
wget -qO - http://your-server:8000/KEY.gpg | sudo apt-key add -

# Or for newer systems (Debian 11+, Ubuntu 22.04+)
wget -qO - http://your-server:8000/KEY.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/tamil-keyboard.gpg

# Update and install
sudo apt update
sudo apt install tamil-keyboard
```

## Alternative: Simple Directory-Based Repository

For a simpler setup without reprepro:

### 1. Create Directory Structure

```bash
export REPO_DIR=/path/to/your/repo
mkdir -p $REPO_DIR/pool/main
```

### 2. Copy Packages

```bash
cp tamil-keyboard_*.deb $REPO_DIR/pool/main/
```

### 3. Generate Packages Index

```bash
cd $REPO_DIR
dpkg-scanpackages pool/ /dev/null | gzip -9c > dists/stable/main/binary-amd64/Packages.gz
```

### 4. Create Release File

Create `dists/stable/Release`:

```
Origin: Kaniyam Foundation
Label: Tamil Keyboard Repository
Codename: stable
Architectures: amd64 all
Components: main
Description: Tamil keyboard layout packages
```

### 5. Sign Release File

```bash
cd $REPO_DIR/dists/stable
gpg -abs -o Release.gpg Release
```

### 6. Serve and Use

Same as steps 8-9 above.

## Updating the Repository

When you update packages:

```bash
# Rebuild packages
./build-packages.sh

# Remove old versions from repository
reprepro remove stable tamil-keyboard

# Add new versions
reprepro includedeb stable /path/to/tamil-keyboard_*.deb
```

## Testing Locally

You can test the packages locally without setting up a full repository:

```bash
# Build packages
./build-packages.sh

# Install directly
sudo dpkg -i tamil-keyboard_*.deb
sudo apt-get install -f  # Install dependencies

# Or use apt with local file
sudo apt-get install ./tamil-keyboard_*.deb
```

## Troubleshooting

### GPG Key Issues

- Ensure the GPG key is exported and accessible
- For newer Debian/Ubuntu, use `gpg --dearmor` instead of `apt-key add`

### Repository Not Found

- Check that the repository URL is correct
- Verify `apt update` runs without errors
- Check repository structure matches expected format

### Package Installation Fails

- Check dependencies are available: `sudo apt-get install -f`
- Verify package architecture matches your system
- Check package integrity: `dpkg -I package.deb`

