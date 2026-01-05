#!/bin/bash

# Verification script to check package structure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Verifying Debian package structure..."
echo ""

ERRORS=0

check_package() {
    local pkg_dir=$1
    local pkg_name=$2
    
    echo "Checking $pkg_name..."
    
    if [ ! -d "$pkg_dir/debian" ]; then
        echo "  ERROR: debian/ directory missing"
        ((ERRORS++))
        return
    fi
    
    local required_files=(
        "debian/control"
        "debian/rules"
        "debian/postinst"
        "debian/changelog"
        "debian/copyright"
        "debian/compat"
        "debian/source/format"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$pkg_dir/$file" ]; then
            echo "  ERROR: $file missing"
            ((ERRORS++))
        fi
    done
    
    # Check if scripts are executable
    if [ -f "$pkg_dir/debian/rules" ] && [ ! -x "$pkg_dir/debian/rules" ]; then
        echo "  ERROR: debian/rules is not executable"
        ((ERRORS++))
    fi
    
    if [ -f "$pkg_dir/debian/postinst" ] && [ ! -x "$pkg_dir/debian/postinst" ]; then
        echo "  ERROR: debian/postinst is not executable"
        ((ERRORS++))
    fi
    
    # Check control file syntax
    if [ -f "$pkg_dir/debian/control" ]; then
        if ! grep -q "^Package:" "$pkg_dir/debian/control"; then
            echo "  ERROR: debian/control missing Package field"
            ((ERRORS++))
        fi
        if ! grep -q "^Source:" "$pkg_dir/debian/control"; then
            echo "  ERROR: debian/control missing Source field"
            ((ERRORS++))
        fi
    fi
    
    echo "  ✓ $pkg_name structure looks good"
    echo ""
}

check_package "tamil-99-keyboard" "tamil-99-keyboard"
check_package "tamil-phonetic-keyboard" "tamil-phonetic-keyboard"

if [ $ERRORS -eq 0 ]; then
    echo "✓ All checks passed! Packages are ready to build."
    exit 0
else
    echo "✗ Found $ERRORS error(s). Please fix them before building."
    exit 1
fi

