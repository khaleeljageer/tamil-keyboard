#!/bin/bash

# Build script for the tamil-keyboard Debian package

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building the tamil-keyboard Debian package..."
echo ""

# Check if required tools are installed
if ! command -v dpkg-buildpackage >/dev/null 2>&1; then
    echo "Error: dpkg-buildpackage not found. Please install devscripts:"
    echo "  sudo apt-get install devscripts build-essential debhelper"
    exit 1
fi

cd tamil-keyboard
dpkg-buildpackage -b -us -uc
cd ..

echo ""
echo "Build complete! The package is in the parent directory:"
echo "  - tamil-keyboard_*.deb"
echo ""
echo "To install locally:"
echo "  sudo apt-get install ../tamil-keyboard_*.deb"
echo ""
echo "Then enable a layout as your normal user (not with sudo):"
echo "  tamil-keyboard-setup tamil99"
