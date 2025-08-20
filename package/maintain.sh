#!/usr/bin/env bash

# Package Manifest Maintenance Script
# This script helps test and validate package manifests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Test Homebrew formula
test_homebrew() {
    log "Testing Homebrew formula..."

    if ! command_exists brew; then
        warn "Homebrew not installed, skipping Homebrew tests"
        return 0
    fi

    local formula_path="$REPO_ROOT/package/homebrew/emojify-go.rb"

    if [[ ! -f "$formula_path" ]]; then
        error "Homebrew formula not found at $formula_path"
        return 1
    fi

    log "Auditing Homebrew formula..."
    # Note: brew audit requires formula names, not file paths
    # For now, we'll just check basic syntax and structure

    if grep -q "class.*< Formula" "$formula_path"; then
        log "✓ Formula class structure found"
    else
        error "Formula class structure not found"
        return 1
    fi

    # Check for required methods
    if grep -q "def install" "$formula_path"; then
        log "✓ Install method found"
    else
        error "Install method not found"
        return 1
    fi

    if grep -q "def test" "$formula_path"; then
        log "✓ Test method found"
    else
        warn "Test method not found (recommended)"
    fi

    success "Homebrew formula passed validation"

    log "Formula syntax looks good!"
}

# Test AUR packages
test_aur() {
    log "Testing AUR packages..."

    local aur_dir="$REPO_ROOT/package/aur"

    if [[ ! -d "$aur_dir" ]]; then
        error "AUR directory not found at $aur_dir"
        return 1
    fi

    local packages=("emojify-go" "emojify-go-bin")
    local failed=0

    for package in "${packages[@]}"; do
        local pkgbuild="$aur_dir/$package/PKGBUILD"

        if [[ ! -f "$pkgbuild" ]]; then
            error "PKGBUILD not found for $package at $pkgbuild"
            ((failed++))
            continue
        fi

        log "Checking $package PKGBUILD..."

        # Check required fields
        local required_fields=("pkgname" "pkgver" "pkgrel" "pkgdesc" "arch" "url" "license")

        for field in "${required_fields[@]}"; do
            if grep -q "^$field=" "$pkgbuild"; then
                log "✓ Field '$field' present in $package"
            else
                error "✗ Required field '$field' missing in $package"
                ((failed++))
            fi
        done
    done

    if [[ $failed -eq 0 ]]; then
        success "AUR packages passed validation"
    else
        error "$failed AUR package issue(s) found"
        return 1
    fi
}

# Test Nix packages
test_nix() {
    log "Testing Nix packages..."

    local nix_dir="$REPO_ROOT/package/nix"

    if [[ ! -d "$nix_dir" ]]; then
        error "Nix directory not found at $nix_dir"
        return 1
    fi

    # Check flake.nix
    local flake_nix="$nix_dir/flake.nix"
    if [[ -f "$flake_nix" ]]; then
        log "Checking flake.nix..."

        # Basic syntax check (if nix is available)
        if command_exists nix; then
            if nix flake check "$nix_dir" 2>/dev/null; then
                log "✓ flake.nix syntax valid"
            else
                warn "flake.nix may have syntax issues"
            fi
        else
            warn "nix not installed, skipping flake validation"
        fi

        # Check for required sections
        if grep -q "description\s*=" "$flake_nix"; then
            log "✓ Description found in flake.nix"
        else
            warn "Description missing in flake.nix"
        fi

        success "Nix flake validation completed"
    else
        error "flake.nix not found at $flake_nix"
        return 1
    fi

    # Check default.nix
    local default_nix="$nix_dir/default.nix"
    if [[ -f "$default_nix" ]]; then
        log "✓ default.nix found"
    else
        warn "default.nix not found (optional)"
    fi
}

# Test WinGet manifests
test_winget() {
    log "Testing WinGet manifests..."

    local winget_dir="$REPO_ROOT/package/winget"

    if [[ ! -d "$winget_dir" ]]; then
        error "WinGet directory not found at $winget_dir"
        return 1
    fi

    # Check for required manifest files
    local manifests=(
        "damienbutt.emojify-go.yaml"
        "damienbutt.emojify-go.locale.en-US.yaml"
        "damienbutt.emojify-go.installer.yaml"
    )

    local failed=0

    for manifest in "${manifests[@]}"; do
        local manifest_file="$winget_dir/$manifest"

        if [[ ! -f "$manifest_file" ]]; then
            error "WinGet manifest not found: $manifest"
            ((failed++))
            continue
        fi

        log "Checking $manifest..."

        # Basic YAML validation if available
        if command_exists yq || command_exists python3; then
            if command_exists yq; then
                if yq eval . "$manifest_file" >/dev/null 2>&1; then
                    log "✓ YAML syntax valid for $manifest"
                else
                    error "✗ YAML syntax invalid for $manifest"
                    ((failed++))
                fi
            elif python3 -c "import yaml; yaml.safe_load(open('$manifest_file'))" 2>/dev/null; then
                log "✓ YAML syntax valid for $manifest"
            else
                error "✗ YAML syntax invalid for $manifest"
                ((failed++))
            fi
        else
            warn "No YAML validator found, skipping syntax check"
        fi
    done

    if [[ $failed -eq 0 ]]; then
        success "WinGet manifests passed validation"
    else
        error "$failed WinGet manifest issue(s) found"
        return 1
    fi
}

# Test Chocolatey package
test_chocolatey() {
    log "Testing Chocolatey package..."

    local choco_dir="$REPO_ROOT/package/chocolatey"

    if [[ ! -d "$choco_dir" ]]; then
        error "Chocolatey directory not found at $choco_dir"
        return 1
    fi

    # Check for required files
    local nuspec_file="$choco_dir/emojify-go.nuspec"
    local tools_dir="$choco_dir/tools"
    local install_script="$tools_dir/chocolateyinstall.ps1"
    local uninstall_script="$tools_dir/chocolateyuninstall.ps1"

    local failed=0

    if [[ ! -f "$nuspec_file" ]]; then
        error "Chocolatey nuspec file not found: $nuspec_file"
        ((failed++))
    else
        log "✓ Nuspec file found"

        # Check required nuspec elements
        local required_elements=("id" "version" "authors" "description" "projectUrl" "licenseUrl")

        for element in "${required_elements[@]}"; do
            if grep -q "<$element>" "$nuspec_file"; then
                log "✓ Element '$element' found in nuspec"
            else
                error "✗ Required element '$element' missing in nuspec"
                ((failed++))
            fi
        done
    fi

    if [[ ! -d "$tools_dir" ]]; then
        error "Chocolatey tools directory not found: $tools_dir"
        ((failed++))
    else
        log "✓ Tools directory found"
    fi

    if [[ ! -f "$install_script" ]]; then
        error "Chocolatey install script not found: $install_script"
        ((failed++))
    else
        log "✓ Install script found"
    fi

    if [[ ! -f "$uninstall_script" ]]; then
        warn "Chocolatey uninstall script not found (optional): $uninstall_script"
    else
        log "✓ Uninstall script found"
    fi

    if [[ $failed -eq 0 ]]; then
        success "Chocolatey package passed validation"
    else
        error "$failed Chocolatey package issue(s) found"
        return 1
    fi
}

# Test Scoop manifest
test_scoop() {
    log "Testing Scoop manifest..."

    local manifest_path="$REPO_ROOT/package/scoop/emojify-go.json"

    if [[ ! -f "$manifest_path" ]]; then
        error "Scoop manifest not found at $manifest_path"
        return 1
    fi

    # Validate JSON syntax
    if command_exists jq; then
        log "Validating JSON syntax..."
        if jq empty "$manifest_path" >/dev/null 2>&1; then
            success "Scoop manifest JSON is valid"
        else
            error "Scoop manifest JSON is invalid"
            return 1
        fi
    else
        warn "jq not installed, skipping JSON validation"
    fi

    # Check required fields
    log "Checking required fields..."
    local required_fields=("version" "description" "homepage" "license" "architecture" "bin")

    if command_exists jq; then
        for field in "${required_fields[@]}"; do
            if jq -e ".$field" "$manifest_path" >/dev/null 2>&1; then
                log "✓ Field '$field' present"
            else
                error "✗ Required field '$field' missing"
                return 1
            fi
        done
        success "All required fields present"
    fi
}

# Update version placeholders
update_versions() {
    local new_version="${1:-}"

    if [[ -z "$new_version" ]]; then
        error "Please provide a version number"
        echo "Usage: $0 update-version <version>"
        echo "Example: $0 update-version 1.2.3"
        return 1
    fi

    log "Updating version to $new_version..."

    # Update Homebrew formula
    local homebrew_formula="$REPO_ROOT/package/homebrew/emojify-go.rb"
    if [[ -f "$homebrew_formula" ]]; then
        log "Updating Homebrew formula version..."
        sed -i.bak "s/version \"[^\"]*\"/version \"$new_version\"/g" "$homebrew_formula"
        sed -i.bak "s/\/v[0-9]\+\.[0-9]\+\.[0-9]\+\//\/v$new_version\//g" "$homebrew_formula"
        sed -i.bak "s/_[0-9]\+\.[0-9]\+\.[0-9]\+_/_${new_version}_/g" "$homebrew_formula"
        rm -f "${homebrew_formula}.bak"
        success "Updated Homebrew formula"
    fi

    # Update Scoop manifest
    local scoop_manifest="$REPO_ROOT/package/scoop/emojify-go.json"
    if [[ -f "$scoop_manifest" ]]; then
        log "Updating Scoop manifest version..."
        if command_exists jq; then
            jq --arg version "$new_version" '.version = $version' "$scoop_manifest" > "${scoop_manifest}.tmp"
            mv "${scoop_manifest}.tmp" "$scoop_manifest"

            # Update URLs
            jq --arg version "$new_version" '
                .architecture."64bit".url = "https://github.com/damienbutt/emojify-go/releases/download/v\($version)/emojify-go_\($version)_windows_amd64.zip" |
                .architecture."32bit".url = "https://github.com/damienbutt/emojify-go/releases/download/v\($version)/emojify-go_\($version)_windows_386.zip" |
                .architecture.arm64.url = "https://github.com/damienbutt/emojify-go/releases/download/v\($version)/emojify-go_\($version)_windows_arm64.zip"
            ' "$scoop_manifest" > "${scoop_manifest}.tmp"
            mv "${scoop_manifest}.tmp" "$scoop_manifest"

            success "Updated Scoop manifest"
        else
            warn "jq not installed, skipping Scoop manifest update"
        fi
    fi

    success "Version updated to $new_version"
    warn "Note: You'll need to update checksums manually or let GoReleaser handle them"
}

# Show current package status
show_status() {
    log "Package Manifest Status"
    echo "========================"
    echo

    # Homebrew
    local homebrew_formula="$REPO_ROOT/package/homebrew/emojify-go.rb"
    if [[ -f "$homebrew_formula" ]]; then
        echo "🍺 Homebrew Formula: ✅"
        local version=$(grep -o 'version "[^"]*"' "$homebrew_formula" | cut -d'"' -f2)
        echo "   Version: $version"
        echo "   Path: package/homebrew/emojify-go.rb"
    else
        echo "🍺 Homebrew Formula: ❌"
    fi
    echo

    # Scoop
    local scoop_manifest="$REPO_ROOT/package/scoop/emojify-go.json"
    if [[ -f "$scoop_manifest" ]]; then
        echo "🪣 Scoop Manifest: ✅"
        if command_exists jq; then
            local version=$(jq -r '.version' "$scoop_manifest")
            echo "   Version: $version"
        fi
        echo "   Path: package/scoop/emojify-go.json"
    else
        echo "🪣 Scoop Manifest: ❌"
    fi
    echo

    # Show available architectures
    if command_exists jq && [[ -f "$scoop_manifest" ]]; then
        echo "Supported Windows Architectures:"
        jq -r '.architecture | keys[]' "$scoop_manifest" | sed 's/^/   - /'
    fi
}

# Help function
show_help() {
    echo "Package Manifest Maintenance Script"
    echo "=================================="
    echo
    echo "Usage: $0 <command> [arguments]"
    echo
    echo "Commands:"
    echo "  test              Test all package manifests"
    echo "  test-homebrew     Test Homebrew formula only"
    echo "  test-scoop        Test Scoop manifest only"
    echo "  test-aur          Test AUR packages only"
    echo "  test-nix          Test Nix packages only"
    echo "  test-winget       Test WinGet manifests only"
    echo "  test-chocolatey   Test Chocolatey package only"
    echo "  update-version    Update version in all manifests"
    echo "  status            Show current package status"
    echo "  help              Show this help message"
    echo
    echo "Examples:"
    echo "  $0 test"
    echo "  $0 update-version 1.2.3"
    echo "  $0 status"
}

# Main function
main() {
    case "${1:-help}" in
        "test")
            test_homebrew
            test_scoop
            test_aur
            test_nix
            test_winget
            test_chocolatey
            ;;
        "test-homebrew")
            test_homebrew
            ;;
        "test-scoop")
            test_scoop
            ;;
        "test-aur")
            test_aur
            ;;
        "test-nix")
            test_nix
            ;;
        "test-winget")
            test_winget
            ;;
        "test-chocolatey")
            test_chocolatey
            ;;
        "update-version")
            update_versions "${2:-}"
            ;;
        "status")
            show_status
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
