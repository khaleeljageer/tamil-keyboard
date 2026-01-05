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
mkdir -p docs/pool/main/t/tamil-99-keyboard
mkdir -p docs/pool/main/t/tamil-phonetic-keyboard
mkdir -p docs/dists/stable/main/binary-amd64

# Create placeholder files
touch docs/pool/main/t/tamil-99-keyboard/.gitkeep
touch docs/pool/main/t/tamil-phonetic-keyboard/.gitkeep
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
echo "deb https://khaleeljageer.github.io/tamil-keyboard stable main" | sudo tee /etc/apt/sources.list.d/tamil-keyboard.list

wget -qO - https://khaleeljageer.github.io/tamil-keyboard/public-key.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/tamil-keyboard.gpg

sudo apt update
sudo apt install tamil-99-keyboard
```

This repository is automatically updated by GitHub Actions when new releases are tagged.
EOF

echo "✓ Repository structure created"
echo ""
echo "Next steps:"
echo "1. Export your GPG public key:"
echo "   gpg --armor --export B09F79B51206F699 > docs/public-key.asc"
echo ""
echo "2. Add GitHub Secrets (Settings → Secrets and variables → Actions):"
echo "   - GPG_PRIVATE_KEY: Export with 'gpg --armor --export-secret-keys B09F79B51206F699'"
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
echo "See GITHUB-PAGES-APT-REPO.md for detailed instructions."

