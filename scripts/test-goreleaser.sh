#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

MISSING_SECRETS=()
MISSING_REPOS=()
MISSING_TOOLS=()
WARNINGS=()

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

check_secret() {
    local secret_name="$1"
    local description="$2"

    if [ -z "${!secret_name}" ]; then
        MISSING_SECRETS+=("$secret_name - $description")
        print_error "Missing: $secret_name"
    else
        print_success "Found: $secret_name"
    fi
}

check_github_repo() {
    local repo="$1"
    local description="$2"
    local token="$3"

    local http_status
    http_status=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: token ${token}" \
        "https://api.github.com/repos/$repo")

    if [ $http_status -eq 200 ]; then
        print_success "Repository exists: $repo"
    else
        MISSING_REPOS+=("$repo - $description (HTTP status: $http_status)")
        print_error "Missing repository: $repo (HTTP status: $http_status)"
    fi
}

check_tool() {
    local tool="$1"

    if ! command -v "$tool" &> /dev/null; then
        MISSING_TOOLS+=("$tool")
        print_error "Missing tool: $tool"
    else
        print_success "Found tool: $tool"
    fi
}

# 1. Configuration validation
print_status "1. 🔍 Validating GoReleaser Configuration..."

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

echo ""

# 2. Required secrets check
print_status "2. 📋 Checking Required Secrets..."

check_secret "GITHUB_TOKEN" "GitHub Actions token (auto-provided)"
check_secret "RELEASE_TOKEN" "Token for Homebrew tap repository"
check_secret "GPG_PRIVATE_KEY" "GPG private key for package signing"
check_secret "GPG_FINGERPRINT" "GPG key fingerprint for package signing"
check_secret "AUR_SSH_PRIVATE_KEY" "SSH private key for AUR publishing (both emojify-go and emojify-go-bin)"
echo ""

# 3. Required repositories check
print_status "3. 🏗️ Checking Required Repositories..."

check_github_repo "damienbutt/homebrew-tap" "Homebrew formula repository" "GITHUB_TOKEN"
check_github_repo "damienbutt/scoop-bucket" "Scoop bucket repository" "GITHUB_TOKEN"
check_github_repo "damienbutt/winget-pkgs" "Winget package repository" "GITHUB_TOKEN"
check_github_repo "damienbutt/nur" "Nix User Repository (NUR)" "GITHUB_TOKEN"
echo ""

# 4. Check build tools
print_status "4. 🔧 Checking Build Tools..."

check_tool "go"
check_tool "git"
check_tool "gpg"
check_tool "nix-hash"
echo ""

print_status "5. 📊 Validation Summary"
echo "======================"

if [ ${#MISSING_SECRETS[@]} -eq 0 ] && \
    [ ${#MISSING_REPOS[@]} -eq 0 ] && \
    [ ${#MISSING_TOOLS[@]} -eq 0 ]; then
    print_success "🎉 All required prerequisites are in place!"

    # GO_VERSION=$(go version | cut -d' ' -f3 | sed 's/go//')
    # print_success "Go version: $GO_VERSION"

    if [ ${#WARNINGS[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}⚠️  Optional items:${NC}"
        print_warning "Optional items:"
        for warning in "${WARNINGS[@]}"; do
            echo -e "${YELLOW}   • $warning${NC}"
        done
    fi
else
    echo -e "${RED}❌ Missing required prerequisites:${NC}"
    print_error "Missing required prerequisites:"

    if [ ${#MISSING_SECRETS[@]} -gt 0 ]; then
        echo -e "\n${RED}❌ Missing Secrets:${NC}"
        for secret in "${MISSING_SECRETS[@]}"; do
            echo -e "${RED}   • $secret${NC}"
        done
    fi

    if [ ${#MISSING_REPOS[@]} -gt 0 ]; then
        echo -e "\n${RED}❌ Missing Repositories:${NC}"
        for repo in "${MISSING_REPOS[@]}"; do
            echo -e "${RED}   • $repo${NC}"
        done
    fi

    if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
        echo -e "\n${RED}❌ Missing Tools:${NC}"
        for tool in "${MISSING_TOOLS[@]}"; do
            echo -e "${RED}   • $tool${NC}"
        done
    fi

    exit 1
fi

# 6. GoReleaser Test (without publishing)
print_status "6. Testing GoReleaser process (no publishing)..."

# Base skip flags - always skip these for testing
SKIP_FLAGS="--skip=publish"

if go tool goreleaser release --snapshot --clean $SKIP_FLAGS --verbose; then
    print_success "GoReleaser process completed successfully"
else
    print_error "GoReleaser process failed"
    exit 1
fi
echo ""

# 6. Summary
print_status "📋 Test Summary"
echo "==============="
echo ""

print_success "GoReleaser configuration is valid."
print_success "All required secrets are present."
print_success "All required repositories are accessible."
print_success "All required build tools are installed."
print_success "GoReleaser release process completed successfully."
echo ""
print_success "🚀 Ready to release!"
