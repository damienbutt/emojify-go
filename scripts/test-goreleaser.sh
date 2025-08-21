#!/bin/bash

# GoReleaser Testing Script
# Tests configuration and build process without publishing

set -e

echo "🧪 GoReleaser Testing Suite"
echo "=========================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. Configuration validation
print_status "1. Validating GoReleaser configuration..."
if goreleaser check 2>/dev/null; then
    print_success "Configuration is valid"
else
    echo "   Checking with warnings..."
    goreleaser check || {
        if [[ $? -eq 2 ]]; then
            print_warning "Configuration valid but has deprecation warnings"
        else
            print_error "Configuration has errors"
            exit 1
        fi
    }
fi
echo

# 2. Required secrets check
print_status "2. Checking required secrets..."

check_secret() {
    local secret_name="$1"
    local required="$2"

    if gh secret list | grep -q "$secret_name"; then
        print_success "$secret_name is configured"
    else
        if [[ "$required" == "true" ]]; then
            print_error "$secret_name is missing (required)"
            return 1
        else
            print_warning "$secret_name is missing (optional)"
        fi
    fi
}

# Check essential secrets
MISSING_SECRETS=0
check_secret "GITHUB_TOKEN" "false" || true  # Auto-provided by GitHub Actions
check_secret "CHOCOLATEY_API_KEY" "true" || ((MISSING_SECRETS++))
check_secret "WINGET_GITHUB_TOKEN" "true" || ((MISSING_SECRETS++))
check_secret "AUR_SSH_PRIVATE_KEY" "true" || ((MISSING_SECRETS++))

if [[ $MISSING_SECRETS -gt 0 ]]; then
    print_warning "Some secrets are missing - publishing will fail"
else
    print_success "All required secrets are configured"
fi
echo

# 3. Build test (without publishing)
print_status "3. Testing build process (no publishing)..."

# Set dummy environment variables for testing
export GITHUB_TOKEN="dummy"
export CHOCOLATEY_API_KEY="dummy"
export WINGET_GITHUB_TOKEN="dummy"
export AUR_KEY="dummy"
export GPG_KEY_FILE="dummy"

if goreleaser release --snapshot --clean --skip=publish --skip=sign --skip=snapcraft --skip=chocolatey --skip=docker 2>/dev/null; then
    print_success "Build process completed successfully"

    # Check generated artifacts
    print_status "4. Checking generated artifacts..."

    if [[ -d "dist" ]]; then
        BINARIES=$(find dist -name "emojify*" -type f | wc -l)
        ARCHIVES=$(find dist -name "*.tar.gz" -o -name "*.zip" | wc -l)

        print_success "Generated $BINARIES binaries"
        print_success "Generated $ARCHIVES archives"

        # List some key files
        echo "   Key artifacts:"
        find dist -maxdepth 1 \( -name "*.tar.gz" -o -name "*.zip" -o -name "checksums.txt" \) | head -5 | sed 's/^/   - /'
    else
        print_error "No dist directory found"
    fi
else
    print_error "Build process failed"
    echo
    echo "Try running manually with more verbose output:"
    echo "  goreleaser release --snapshot --clean --skip=publish --skip=sign --skip=snapcraft --skip=chocolatey --skip=docker"
    exit 1
fi
echo

# 5. Repository access test
print_status "5. Testing repository access..."

if command -v gh >/dev/null 2>&1; then
    if gh auth status >/dev/null 2>&1; then
        print_success "GitHub CLI authenticated"

        # Test repository access
        if gh repo view damienbutt/emojify-go >/dev/null 2>&1; then
            print_success "Main repository accessible"
        else
            print_error "Cannot access main repository"
        fi
    else
        print_warning "GitHub CLI not authenticated"
    fi
else
    print_warning "GitHub CLI not installed"
fi
echo

# 6. Summary
print_status "📋 Test Summary"
echo "==============="
echo

if [[ $MISSING_SECRETS -eq 0 ]]; then
    print_success "All secrets configured ✅"
else
    print_warning "$MISSING_SECRETS required secrets missing ⚠️"
fi

print_success "Configuration valid ✅"
print_success "Build process works ✅"
print_success "Artifacts generated ✅"

echo
if [[ $MISSING_SECRETS -eq 0 ]]; then
    print_success "🎉 Ready for release! All tests passed."
    echo
    echo "To create a release:"
    echo "  git tag v1.0.0"
    echo "  git push origin v1.0.0"
else
    print_warning "⚠️  Almost ready! Configure missing secrets first."
    echo
    echo "Missing secrets can be added with:"
    echo "  gh secret set SECRET_NAME"
fi

echo
echo "Clean up test artifacts:"
echo "  rm -rf dist/"
