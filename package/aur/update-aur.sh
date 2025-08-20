#!/bin/bash

# Script to update AUR source package (emojify-go) for new versions
# Note: The binary package (emojify-go-bin) is automatically updated by GoReleaser
# Usage: ./update-aur.sh <version>

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.1.0"
    echo ""
    echo "This script updates the SOURCE package only."
    echo "The BINARY package (emojify-go-bin) is automatically updated by GoReleaser."
    exit 1
fi

VERSION="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUR_DIR="$SCRIPT_DIR"

# Function to update version in PKGBUILD
update_pkgbuild_version() {
    local pkgbuild_path="$1"
    local version="$2"

    echo "Updating $pkgbuild_path..."
    sed -i "s/^pkgver=.*/pkgver=$version/" "$pkgbuild_path"
    sed -i "s/^pkgrel=.*/pkgrel=1/" "$pkgbuild_path"
}

# Function to generate .SRCINFO
generate_srcinfo() {
    local pkg_dir="$1"
    echo "Generating .SRCINFO for $pkg_dir..."
    (cd "$pkg_dir" && makepkg --printsrcinfo > .SRCINFO)
}

# Function to get source tarball checksum
get_source_checksum() {
    local version="$1"
    local tarball_url="https://github.com/damienbutt/emojify-go/archive/refs/tags/v${version}.tar.gz"

    echo "Calculating source tarball checksum..."
    local checksum=$(curl -sfL "$tarball_url" | sha256sum | cut -d' ' -f1)
    echo "Source checksum: $checksum"

    # Update source PKGBUILD with checksum
    sed -i "s/sha256sums=('SKIP')/sha256sums=('$checksum')/" "$AUR_DIR/emojify-go/PKGBUILD"
}

echo "Updating AUR source package (emojify-go) for version $VERSION"
echo "Note: Binary package (emojify-go-bin) is automatically updated by GoReleaser"

# Update source package only
echo "=== Updating source package ==="
update_pkgbuild_version "$AUR_DIR/emojify-go/PKGBUILD" "$VERSION"
get_source_checksum "$VERSION"
generate_srcinfo "$AUR_DIR/emojify-go"

echo "=== Update complete ==="
echo "Please review the changes and test the source package before uploading to AUR:"
echo "  cd aur/emojify-go && makepkg -si"
echo ""
echo "The binary package (emojify-go-bin) will be automatically updated by GoReleaser"
echo "when you create a GitHub release."
