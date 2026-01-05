#!/bin/bash

# Build script for Tamil keyboard Debian packages
# This script builds both tamil-99-keyboard and tamil-phonetic-keyboard packages

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building Tamil keyboard Debian packages..."
echo ""

# Check if required tools are installed
if ! command -v dpkg-buildpackage >/dev/null 2>&1; then
    echo "Error: dpkg-buildpackage not found. Please install devscripts:"
    echo "  sudo apt-get install devscripts build-essential"
    exit 1
fi

# Build tamil-99-keyboard
echo "Building tamil-99-keyboard..."
cd tamil-99-keyboard
dpkg-buildpackage -b -us -uc
cd ..

# Build tamil-phonetic-keyboard
echo "Building tamil-phonetic-keyboard..."
cd tamil-phonetic-keyboard
dpkg-buildpackage -b -us -uc
cd ..

echo ""
echo "Build complete! Debian packages are in the parent directory:"
echo "  - tamil-99-keyboard_*.deb"
echo "  - tamil-phonetic-keyboard_*.deb"
echo ""
echo "To install locally:"
echo "  sudo dpkg -i tamil-99-keyboard_*.deb"
echo "  sudo dpkg -i tamil-phonetic-keyboard_*.deb"
echo ""
echo "Or to install dependencies automatically:"
echo "  sudo apt-get install -f"
echo "  sudo apt-get install ./tamil-99-keyboard_*.deb"
echo "  sudo apt-get install ./tamil-phonetic-keyboard_*.deb"

