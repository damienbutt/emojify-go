#!/usr/bin/env bash

# AUR Repository Cleanup Script
# This removes all files from AUR repositories to make them empty again

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly AUR_PACKAGES=("emojify-go-bin" "emojify-go")
readonly TEMP_DIR="/tmp/aur-cleanup-$$"

# Logging functions
log() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

echo -e "${BLUE}🧹 AUR Repository Cleanup${NC}"
echo "=========================="
echo

# Clean up AUR repository
cleanup_aur_repository() {
    local package_name="$1"

    log "Cleaning up AUR repository for '$package_name'..."

    # Create temporary directory
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"

    # Clone the existing repository
    if git clone "ssh://aur@aur.archlinux.org/${package_name}.git"; then
        cd "$package_name"

        # Check if there are any files to remove
        if [ "$(ls -A .)" ]; then
            log "Removing all files from $package_name repository..."

            # Remove all files except .git
            find . -maxdepth 1 ! -name '.' ! -name '..' ! -name '.git' -exec rm -rf {} +

            # Commit the removal
            git add -A
            git commit -m "Clear repository - prepare for automated management"
            git push origin master

            success "Cleaned AUR repository for '$package_name'"
        else
            success "Repository '$package_name' is already empty"
        fi
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

        if cleanup_aur_repository "$package_name"; then
            success "Successfully cleaned AUR repository for $package_name"
        else
            error "Failed to clean AUR repository for $package_name"
            exit 1
        fi
    done

    echo ""
    success "AUR repository cleanup complete!"
    echo ""
    echo "Both repositories are now empty and ready for:"
    echo "  - GoReleaser to manage emojify-go-bin automatically"
    echo "  - Manual management of emojify-go when needed"
}

main "$@"
