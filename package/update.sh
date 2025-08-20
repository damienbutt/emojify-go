#!/usr/bin/env bash

# Package Update Helper for CI/CD
# This script helps update package manifests during automated releases

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Update package manifests for a new release
update_manifests() {
    local version="${1:-}"
    local sha256_linux_amd64="${2:-}"
    local sha256_darwin_amd64="${3:-}"
    local sha256_windows_amd64="${4:-}"

    if [[ -z "$version" ]]; then
        error "Version is required"
        echo "Usage: $0 update-manifests <version> [sha256_linux] [sha256_darwin] [sha256_windows]"
        exit 1
    fi

    log "Updating package manifests for version $version"

    # Update Homebrew formula
    local homebrew_formula="package/homebrew/emojify-go.rb"
    if [[ -f "$homebrew_formula" ]]; then
        log "Updating Homebrew formula..."

        # Update version
        sed -i.bak "s/version \"[^\"]*\"/version \"$version\"/g" "$homebrew_formula"

        # Update URLs
        sed -i.bak "s|/v[0-9]\+\.[0-9]\+\.[0-9]\+/|/v$version/|g" "$homebrew_formula"
        sed -i.bak "s|_[0-9]\+\.[0-9]\+\.[0-9]\+_|_${version}_|g" "$homebrew_formula"

        # Update checksum if provided
        if [[ -n "$sha256_darwin_amd64" ]]; then
            sed -i.bak "s/sha256 \"[^\"]*\"/sha256 \"$sha256_darwin_amd64\"/g" "$homebrew_formula"
        fi

        rm -f "${homebrew_formula}.bak"
        success "Updated Homebrew formula"
    fi

    # Update Scoop manifest
    local scoop_manifest="package/scoop/emojify-go.json"
    if [[ -f "$scoop_manifest" ]] && command -v jq >/dev/null 2>&1; then
        log "Updating Scoop manifest..."

        # Update version
        jq --arg version "$version" '.version = $version' "$scoop_manifest" > "${scoop_manifest}.tmp"
        mv "${scoop_manifest}.tmp" "$scoop_manifest"

        # Update URLs
        jq --arg version "$version" '
            .architecture."64bit".url = "https://github.com/damienbutt/emojify-go/releases/download/v\($version)/emojify-go_\($version)_windows_amd64.zip" |
            .architecture."32bit".url = "https://github.com/damienbutt/emojify-go/releases/download/v\($version)/emojify-go_\($version)_windows_386.zip" |
            .architecture.arm64.url = "https://github.com/damienbutt/emojify-go/releases/download/v\($version)/emojify-go_\($version)_windows_arm64.zip"
        ' "$scoop_manifest" > "${scoop_manifest}.tmp"
        mv "${scoop_manifest}.tmp" "$scoop_manifest"

        # Update checksums if provided
        if [[ -n "$sha256_windows_amd64" ]]; then
            jq --arg hash "$sha256_windows_amd64" '.architecture."64bit".hash = $hash' "$scoop_manifest" > "${scoop_manifest}.tmp"
            mv "${scoop_manifest}.tmp" "$scoop_manifest"
        fi

        success "Updated Scoop manifest"
    fi

    log "Package manifests updated successfully"
    log "Note: Commit these changes if running locally"
}

# Validate checksums from release artifacts
validate_checksums() {
    local checksums_file="${1:-checksums.txt}"

    if [[ ! -f "$checksums_file" ]]; then
        error "Checksums file not found: $checksums_file"
        exit 1
    fi

    log "Validating checksums from $checksums_file"

    # Extract relevant checksums
    local sha256_linux_amd64=$(grep "_linux_amd64\.tar\.gz" "$checksums_file" | cut -d' ' -f1)
    local sha256_darwin_amd64=$(grep "_darwin_amd64\.tar\.gz" "$checksums_file" | cut -d' ' -f1)
    local sha256_windows_amd64=$(grep "_windows_amd64\.zip" "$checksums_file" | cut -d' ' -f1)

    echo "Linux AMD64:   $sha256_linux_amd64"
    echo "Darwin AMD64:  $sha256_darwin_amd64"
    echo "Windows AMD64: $sha256_windows_amd64"

    success "Checksums extracted successfully"
}

# Help function
show_help() {
    echo "Package Update Helper for CI/CD"
    echo "==============================="
    echo
    echo "Usage: $0 <command> [arguments]"
    echo
    echo "Commands:"
    echo "  update-manifests   Update package manifests for new release"
    echo "  validate-checksums Extract checksums from GoReleaser output"
    echo "  help              Show this help message"
    echo
    echo "Examples:"
    echo "  $0 update-manifests 1.2.3 sha256... sha256... sha256..."
    echo "  $0 validate-checksums dist/checksums.txt"
}

# Main function
main() {
    case "${1:-help}" in
        "update-manifests")
            update_manifests "${2:-}" "${3:-}" "${4:-}" "${5:-}"
            ;;
        "validate-checksums")
            validate_checksums "${2:-}"
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            error "Unknown command: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
