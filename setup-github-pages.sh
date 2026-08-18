#!/bin/bash

# Setup script for GitHub Pages APT Repository
# This script helps set up the initial structure for GitHub Pages

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Setting up GitHub Pages APT Repository structure..."
echo ""

# Create repository structure
echo "Creating repository directories..."
mkdir -p docs/pool/main/t/tamil-keyboard
mkdir -p docs/dists/stable/main/binary-amd64

# Create placeholder files
touch docs/pool/main/t/tamil-keyboard/.gitkeep
touch docs/dists/stable/main/binary-amd64/.gitkeep

# Create README for docs
cat > docs/README.md <<'EOF'
# Tamil Keyboard APT Repository

This directory contains the Debian APT repository for Tamil keyboard packages.

## Repository Structure

- `pool/` - Contains the actual .deb package files
- `dists/` - Contains repository metadata (Packages, Release files)

## For Users

To use this repository, add it to your system:

```bash
sudo install -d -m 0755 /etc/apt/keyrings
wget -qO- https://khaleeljageer.github.io/tamil-keyboard/public-key.asc | sudo tee /etc/apt/keyrings/tamil-keyboard.asc > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/tamil-keyboard.asc] https://khaleeljageer.github.io/tamil-keyboard stable main" | sudo tee /etc/apt/sources.list.d/tamil-keyboard.list

sudo apt update
sudo apt install tamil-keyboard
```

Then enable a layout as your normal user:

```bash
tamil-keyboard-setup tamil99
```

This repository is automatically updated by GitHub Actions when new releases are tagged.
EOF

echo "✓ Repository structure created"
echo ""
echo "Next steps:"
echo "1. No need to export the public key by hand -- the workflow exports it"
echo "   from the private key it signs with, so the two cannot drift."
echo ""
echo "2. Add GitHub Secrets (Settings → Secrets and variables → Actions):"
echo "   - GPG_PRIVATE_KEY: Export with 'gpg --armor --export-secret-keys 2B827D30BE0F7CCA4EE6DE8C521B6C93122B6B88'"
echo "   - GPG_PASSPHRASE: Your GPG key passphrase (if set)"
echo ""
echo "3. Enable GitHub Pages:"
echo "   - Go to Settings → Pages"
echo "   - Source: Deploy from a branch"
echo "   - Branch: gh-pages"
echo "   - Folder: / (root)"
echo ""
echo "4. Create and push gh-pages branch:"
echo "   git checkout -b gh-pages"
echo "   git add docs/"
echo "   git commit -m 'Initial repository structure'"
echo "   git push origin gh-pages"
echo "   git checkout main"
echo ""
echo "5. Create a release tag to trigger the build:"
echo "   git tag -a v1.0.0 -m 'Release 1.0.0'"
echo "   git push origin v1.0.0"
echo ""
echo "See the Releasing section of README.md for details."

