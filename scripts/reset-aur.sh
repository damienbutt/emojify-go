#!/usr/bin/env bash

# AUR Repository Reset Script
# This resets AUR repositories to minimal placeholder state for GoReleaser

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly AUR_PACKAGES=("emojify-go-bin" "emojify-go")
readonly TEMP_DIR="/tmp/aur-reset-$$"

# Logging functions
log() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

echo -e "${BLUE}🔄 AUR Repository Reset${NC}"
echo "======================="
echo

# Reset AUR repository to minimal state
reset_aur_repository() {
    local package_name="$1"

    log "Resetting AUR repository for '$package_name'..."

    # Create temporary directory
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"

    # Clone the existing repository
    if git clone "ssh://aur@aur.archlinux.org/${package_name}.git"; then
        cd "$package_name"

        # Remove existing files
        rm -f .SRCINFO PKGBUILD README.md

        # Create minimal .SRCINFO (required by AUR)
        cat > .SRCINFO << EOF
pkgbase = ${package_name}
	pkgdesc = Placeholder - managed by GoReleaser
	pkgver = 0.0.0
	pkgrel = 1
	url = https://github.com/damienbutt/emojify-go
	arch = x86_64
	license = MIT

pkgname = ${package_name}
EOF

        # Create minimal PKGBUILD
        cat > PKGBUILD << EOF
# Maintainer: Damien Butt <damien at example dot com>
# This package is managed by GoReleaser - do not edit manually

pkgname=${package_name}
pkgver=0.0.0
pkgrel=1
pkgdesc="Placeholder - managed by GoReleaser"
arch=('x86_64')
url="https://github.com/damienbutt/emojify-go"
license=('MIT')

package() {
    echo "This package will be populated by GoReleaser"
}
EOF

        # Commit and push
        git add .
        git commit -m "Reset to minimal placeholder for GoReleaser"
        git push origin master

        success "Reset AUR repository for '$package_name'"
        return 0
    else
        error "Failed to clone AUR repository for '$package_name'"
        return 1
    fi
}

# Cleanup function
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        log "Cleaning up temporary directory..."
        rm -rf "$TEMP_DIR"
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Main execution
main() {
    for package_name in "${AUR_PACKAGES[@]}"; do
        echo ""
        log "Processing package: $package_name"

        if reset_aur_repository "$package_name"; then
            success "Successfully reset AUR repository for $package_name"
        else
            error "Failed to reset AUR repository for $package_name"
            exit 1
        fi
    done

    echo ""
    success "AUR repository reset complete!"
    echo ""
    echo "Both repositories now contain minimal placeholders that GoReleaser can overwrite."
}

main "$@"
