#!/usr/bin/env bash

# AUR Repository Setup for emojify-go
# This script creates the initial empty AUR repositories that GoReleaser needs
#
# Usage: ./setup-aur.sh

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly AUR_PACKAGES=("emojify-go-bin" "emojify-go")
readonly TEMP_DIR="/tmp/aur-setup-$$"

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

echo -e "${BLUE}🏗️  AUR Repository Setup for emojify-go${NC}"
echo "==========================================="
echo

# Test SSH connection to AUR
test_ssh_connection() {
    log "Testing SSH connection to AUR..."

    local ssh_output
    ssh_output=$(ssh -o BatchMode=yes -o ConnectTimeout=5 -o ControlMaster=no -T aur@aur.archlinux.org 2>&1 || true)

    if [[ "$ssh_output" =~ "Welcome to AUR" ]]; then
        success "SSH connection to AUR successful"
        return 0
    fi

    error "Cannot connect to AUR via SSH"
    echo "SSH output: $ssh_output"
    echo ""
    echo "Please ensure:"
    echo "1. Your SSH key is added to your AUR account"
    echo "2. SSH config is set up correctly for aur.archlinux.org"
    exit 1
}

# Check if package name is available
check_package_availability() {
    local package_name="$1"

    log "Checking if '$package_name' is available..."

    # Use AUR's RPC API to check if package exists
    local aur_response
    if aur_response=$(curl -s "https://aur.archlinux.org/rpc/?v=5&type=info&arg=${package_name}"); then
        local result_count
        result_count=$(echo "$aur_response" | grep -o '"resultcount":[0-9]*' | cut -d':' -f2)

        if [[ "$result_count" -gt 0 ]]; then
            warn "Package '$package_name' already exists on AUR"
            echo "See: https://aur.archlinux.org/packages/${package_name}"
            return 1
        else
            success "Package name '$package_name' is available"
            return 0
        fi
    else
        error "Could not check package availability"
        return 1
    fi
}

# Create empty AUR repository
create_aur_repository() {
    local package_name="$1"

    log "Creating AUR repository for '$package_name'..."

    # Create temporary directory
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"

    # Clone (which creates) the empty AUR repository
    if git clone "ssh://aur@aur.archlinux.org/${package_name}.git"; then
        success "Created empty AUR repository for '$package_name'"
        return 0
    else
        error "Failed to create AUR repository for '$package_name'"
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
    test_ssh_connection

    for package_name in "${AUR_PACKAGES[@]}"; do
        echo ""
        log "Processing package: $package_name"

        if check_package_availability "$package_name"; then
            if create_aur_repository "$package_name"; then
                success "Successfully set up AUR repository for $package_name"
            else
                error "Failed to set up AUR repository for $package_name"
                exit 1
            fi
        else
            warn "Skipping $package_name (already exists or check failed)"
        fi
    done

    echo ""
    success "AUR repository setup complete!"
    echo ""
    echo "Empty AUR repositories created:"
    for package_name in "${AUR_PACKAGES[@]}"; do
        echo "  - $package_name"
    done
    echo ""
    echo "GoReleaser will populate emojify-go-bin automatically on the next release."
    echo "You'll need to manually maintain emojify-go (source package) as needed."
}

main "$@"
