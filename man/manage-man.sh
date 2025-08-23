#!/usr/bin/env bash

# Man Page Generator and Tester
# This script helps generate, test, and install the emojify man page

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MAN_SOURCE="$REPO_ROOT/man/emojify.1"
MAN_OUTPUT_DIR="$REPO_ROOT/build/man"

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

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Generate man page in different formats
generate_man() {
    log "Generating man page..."

    mkdir -p "$MAN_OUTPUT_DIR"

    # Copy source to output directory
    cp "$MAN_SOURCE" "$MAN_OUTPUT_DIR/"

    # Generate HTML version if pandoc is available
    if command_exists pandoc; then
        log "Generating HTML version..."
        pandoc -s -f man -t html "$MAN_SOURCE" -o "$MAN_OUTPUT_DIR/emojify.1.html"
        success "HTML man page generated: $MAN_OUTPUT_DIR/emojify.1.html"
    else
        warn "pandoc not found, skipping HTML generation"
    fi

    # Generate PDF version if pandoc and wkhtmltopdf are available
    if command_exists pandoc && command_exists wkhtmltopdf; then
        log "Generating PDF version..."
        pandoc -s -f man -t html "$MAN_SOURCE" | wkhtmltopdf - "$MAN_OUTPUT_DIR/emojify.1.pdf"
        success "PDF man page generated: $MAN_OUTPUT_DIR/emojify.1.pdf"
    else
        warn "pandoc or wkhtmltopdf not found, skipping PDF generation"
    fi

    success "Man page generated successfully"
}

# Test the man page
test_man() {
    log "Testing man page..."

    if [[ ! -f "$MAN_SOURCE" ]]; then
        error "Man page source not found: $MAN_SOURCE"
        return 1
    fi

    # Check man page syntax
    if command_exists groff; then
        log "Checking man page syntax with groff..."
        if groff -man -Tascii "$MAN_SOURCE" >/dev/null 2>&1; then
            success "Man page syntax is valid"
        else
            error "Man page has syntax errors"
            return 1
        fi
    else
        warn "groff not found, skipping syntax check"
    fi

    # Check for common issues
    log "Checking for common issues..."

    # Check for proper header
    if grep -q "^\.TH EMOJIFY" "$MAN_SOURCE"; then
        log "✓ Proper TH header found"
    else
        error "✗ Missing or incorrect TH header"
        return 1
    fi

    # Check for required sections
    local required_sections=("NAME" "SYNOPSIS" "DESCRIPTION" "OPTIONS" "EXAMPLES")
    for section in "${required_sections[@]}"; do
        if grep -q "^\.SH $section" "$MAN_SOURCE"; then
            log "✓ Section $section found"
        else
            error "✗ Missing required section: $section"
            return 1
        fi
    done

    success "Man page tests passed"
}

# Preview the man page
preview_man() {
    log "Previewing man page..."

    if [[ ! -f "$MAN_SOURCE" ]]; then
        error "Man page source not found: $MAN_SOURCE"
        return 1
    fi

    if command_exists man; then
        man "$MAN_SOURCE"
    elif command_exists groff; then
        groff -man -Tascii "$MAN_SOURCE" | less
    else
        error "Neither man nor groff found for preview"
        return 1
    fi
}

# Install man page locally for testing
install_local() {
    log "Installing man page locally..."

    local local_man_dir="$HOME/.local/share/man/man1"
    mkdir -p "$local_man_dir"

    cp "$MAN_SOURCE" "$local_man_dir/"

    # Update man database if available
    if command_exists mandb; then
        mandb "$HOME/.local/share/man" 2>/dev/null || true
    fi

    success "Man page installed to $local_man_dir"
    log "You can now run: man emojify"
}

# Update version in man page
update_version() {
    local version="${1:-}"

    if [[ -z "$version" ]]; then
        error "Version is required"
        echo "Usage: $0 update-version <version>"
        return 1
    fi

    log "Updating man page version to $version..."

    # Update the TH line with new version
    sed -i.bak "s/\"emojify-go [^\"]*\"/\"emojify-go $version\"/g" "$MAN_SOURCE"
    rm -f "$MAN_SOURCE.bak"

    success "Version updated to $version"
}

# Validate man page against style guidelines
validate_style() {
    log "Validating man page style..."

    local issues=0

    # Check line length (should be reasonable)
    local long_lines=$(grep -n ".\{80\}" "$MAN_SOURCE" | wc -l)
    if [[ $long_lines -gt 0 ]]; then
        warn "Found $long_lines lines longer than 80 characters"
        ((issues++))
    fi

    # Check for proper option formatting
    if grep -q "\\\\fB.*\\\\fR" "$MAN_SOURCE"; then
        log "✓ Options properly formatted with bold"
    else
        warn "Options may not be properly formatted"
        ((issues++))
    fi

    # Check for examples section
    if grep -q "^\.SS.*Example" "$MAN_SOURCE"; then
        log "✓ Examples section found"
    else
        warn "Consider adding more examples"
    fi

    if [[ $issues -eq 0 ]]; then
        success "Style validation passed"
    else
        warn "Style validation completed with $issues issues"
    fi
}

# Show help
show_help() {
    echo "Man Page Generator and Tester"
    echo "============================="
    echo
    echo "Usage: $0 <command> [arguments]"
    echo
    echo "Commands:"
    echo "  generate        Generate man page in multiple formats"
    echo "  test           Test man page syntax and structure"
    echo "  preview        Preview the man page"
    echo "  install-local  Install man page locally for testing"
    echo "  update-version Update version in man page"
    echo "  validate-style Validate man page style"
    echo "  help           Show this help message"
    echo
    echo "Examples:"
    echo "  $0 generate"
    echo "  $0 test"
    echo "  $0 preview"
    echo "  $0 update-version 1.2.3"
}

# Main function
main() {
    case "${1:-help}" in
        "generate")
            generate_man
            ;;
        "test")
            test_man
            ;;
        "preview")
            preview_man
            ;;
        "install-local")
            install_local
            ;;
        "update-version")
            update_version "${2:-}"
            ;;
        "validate-style")
            validate_style
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
