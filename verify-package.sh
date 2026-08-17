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
        "debian/changelog"
        "debian/copyright"
        "debian/install"
        "debian/source/format"
        "bin/tamil-keyboard-setup"
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

    if [ -f "$pkg_dir/bin/tamil-keyboard-setup" ] && [ ! -x "$pkg_dir/bin/tamil-keyboard-setup" ]; then
        echo "  ERROR: bin/tamil-keyboard-setup is not executable"
        ((ERRORS++))
    fi

    # Check the shipped script parses
    if [ -f "$pkg_dir/bin/tamil-keyboard-setup" ]; then
        if ! bash -n "$pkg_dir/bin/tamil-keyboard-setup" 2>/dev/null; then
            echo "  ERROR: bin/tamil-keyboard-setup has a syntax error"
            ((ERRORS++))
        fi
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

    # The changelog must parse; an unexpanded template here breaks the build
    if ! (cd "$pkg_dir" && dpkg-parsechangelog >/dev/null 2>&1); then
        echo "  ERROR: debian/changelog does not parse"
        ((ERRORS++))
    fi

    echo "  ✓ $pkg_name structure looks good"
    echo ""
}

check_package "tamil-keyboard" "tamil-keyboard"

if [ $ERRORS -eq 0 ]; then
    echo "✓ All checks passed! Package is ready to build."
    exit 0
else
    echo "✗ Found $ERRORS error(s). Please fix them before building."
    exit 1
fi
