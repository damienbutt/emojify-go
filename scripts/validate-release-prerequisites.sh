#!/bin/bash
# scripts/validate-release-prerequisites.sh
# Validates that all required secrets and prerequisites are in place for releases

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track validation status
MISSING_SECRETS=()
MISSING_REPOS=()
WARNINGS=()

echo -e "${BLUE}🔍 Validating Release Prerequisites${NC}"
echo "=================================================="

# Function to check if a secret exists
check_secret() {
    local secret_name="$1"
    local required="$2"  # true/false
    local description="$3"

    if [ -z "${!secret_name}" ]; then
        if [ "$required" = "true" ]; then
            MISSING_SECRETS+=("$secret_name - $description")
            echo -e "${RED}❌ Missing: $secret_name${NC}"
        else
            WARNINGS+=("$secret_name - $description (optional)")
            echo -e "${YELLOW}⚠️  Optional: $secret_name${NC}"
        fi
    else
        echo -e "${GREEN}✅ Found: $secret_name${NC}"
    fi
}

# Function to check if a GitHub repository exists
check_github_repo() {
    local repo="$1"
    local description="$2"

    # Use GitHub API to check if repo exists
    if curl -s -f -H "Authorization: token ${GITHUB_TOKEN}" \
       "https://api.github.com/repos/$repo" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Repository exists: $repo${NC}"
    else
        MISSING_REPOS+=("$repo - $description")
        echo -e "${RED}❌ Missing repository: $repo${NC}"
    fi
}

echo -e "\n${BLUE}📋 Checking Required Secrets${NC}"
echo "----------------------------------"

# GitHub tokens
check_secret "GITHUB_TOKEN" "true" "GitHub Actions token (auto-provided)"
check_secret "RELEASE_TOKEN" "true" "Token for Homebrew tap repository"

# GPG signing
check_secret "GPG_PRIVATE_KEY" "true" "GPG private key for package signing"
check_secret "GPG_FINGERPRINT" "true" "GPG key fingerprint for package signing"

# Package manager APIs
check_secret "AUR_SSH_PRIVATE_KEY" "true" "SSH private key for AUR publishing (both emojify-go and emojify-go-bin)"

echo -e "\n${BLUE}🏗️  Checking Required Repositories${NC}"
echo "--------------------------------------"

# Check if required repositories exist
if [ -n "${GITHUB_TOKEN}" ]; then
    check_github_repo "damienbutt/homebrew-tap" "Homebrew formula repository"

    check_github_repo "damienbutt/scoop-bucket" "Scoop bucket repository"

    check_github_repo "damienbutt/winget-pkgs" "Winget package repository"
else
    echo -e "${YELLOW}⚠️  Skipping repository checks (no GITHUB_TOKEN)${NC}"
fi

echo -e "\n${BLUE}🔧 Checking Build Tools${NC}"
echo "-------------------------"

# Check if required tools are available
if command -v go &> /dev/null; then
    echo -e "${GREEN}✅ Go compiler available${NC}"
else
    echo -e "${RED}❌ Go compiler not found${NC}"
    exit 1
fi

if command -v git &> /dev/null; then
    echo -e "${GREEN}✅ Git available${NC}"
else
    echo -e "${RED}❌ Git not found${NC}"
    exit 1
fi

# Check Go version
GO_VERSION=$(go version | cut -d' ' -f3 | sed 's/go//')
echo -e "${GREEN}✅ Go version: $GO_VERSION${NC}"

echo -e "\n${BLUE}📊 Validation Summary${NC}"
echo "======================"

if [ ${#MISSING_SECRETS[@]} -eq 0 ] && [ ${#MISSING_REPOS[@]} -eq 0 ]; then
    echo -e "${GREEN}🎉 All required prerequisites are in place!${NC}"
    echo -e "${GREEN}✅ Ready for release${NC}"

    if [ ${#WARNINGS[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}⚠️  Optional items:${NC}"
        for warning in "${WARNINGS[@]}"; do
            echo -e "${YELLOW}   • $warning${NC}"
        done
    fi

    exit 0
else
    echo -e "${RED}❌ Missing required prerequisites:${NC}"

    if [ ${#MISSING_SECRETS[@]} -gt 0 ]; then
        echo -e "\n${RED}Missing Secrets:${NC}"
        for secret in "${MISSING_SECRETS[@]}"; do
            echo -e "${RED}   • $secret${NC}"
        done
    fi

    if [ ${#MISSING_REPOS[@]} -gt 0 ]; then
        echo -e "\n${RED}Missing Repositories:${NC}"
        for repo in "${MISSING_REPOS[@]}"; do
            echo -e "${RED}   • $repo${NC}"
        done
    fi

    echo -e "\n${BLUE}📖 Setup Instructions:${NC}"
    echo "https://github.com/damienbutt/emojify/blob/main/docs/RELEASE_SETUP.md"

    exit 1
fi
