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
if go tool goreleaser check 2>/dev/null; then
    print_success "Configuration is valid"
else
    echo "   Checking with warnings..."
    go tool goreleaser check || {
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
check_secret "RELEASE_TOKEN" "true" || ((MISSING_SECRETS++))
check_secret "AUR_SSH_PRIVATE_KEY" "true" || ((MISSING_SECRETS++))
check_secret "GPG_PRIVATE_KEY" "true" || ((MISSING_SECRETS++))
check_secret "GPG_FINGERPRINT" "true" || ((MISSING_SECRETS++))

if [[ $MISSING_SECRETS -eq 0 ]]; then
    print_success "All secrets configured ✅"
else
    print_warning "$MISSING_SECRETS required secrets missing ⚠️"
    exit 1
fi
echo

# 3. GoReleaser Test (without publishing)
print_status "3. Testing GoReleaser process (no publishing)..."

# Base skip flags - always skip these for testing
SKIP_FLAGS="--skip=publish --skip=sign --skip=validate"

if go tool goreleaser release --snapshot --clean $SKIP_FLAGS --verbose; then
    print_success "GoReleaser process completed successfully"
else
    print_error "GoReleaser process failed"
    exit 1
fi
echo

# 6. Summary
print_status "📋 Test Summary"
echo "==============="
echo

print_success "Configuration valid ✅"
print_success "GoReleaser process works ✅"
