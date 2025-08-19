# Release Setup Documentation

This document outlines all the prerequisites and setup steps required for publishing Emojify to various package managers and repositories.

## Overview

Emojify publishes to the following platforms:

-   **GitHub Releases** (binary downloads)
-   **Docker Hub** and **GitHub Container Registry** (container images)
-   **Homebrew** (macOS package manager)
-   **Scoop** (Windows package manager)
-   **Chocolatey** (Windows package manager)
-   **WinGet** (Windows package manager)
-   **AUR** (Arch Linux User Repository)
-   **Snap Store** (Universal Linux packages)
-   **APT/YUM/RPM** (Linux package repositories)

## Required Secrets

### 1. GitHub Personal Access Tokens

You need to create Personal Access Tokens (PATs) for various GitHub repositories:

#### HOMEBREW_TAP_GITHUB_TOKEN

-   **Purpose**: Access to your Homebrew tap repository
-   **Repository**: `damienbutt/homebrew-tap`
-   **Permissions**: `Contents: Write`, `Metadata: Read`
-   **Setup**:
    1. Create repository: `damienbutt/homebrew-tap`
    2. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
    3. Generate new token with permissions above
    4. Add to repository secrets as `HOMEBREW_TAP_GITHUB_TOKEN`

#### WINGET_GITHUB_TOKEN

-   **Purpose**: Create PRs to Microsoft's WinGet repository
-   **Repository**: Fork of `microsoft/winget-pkgs`
-   **Permissions**: `Contents: Write`, `Pull requests: Write`, `Metadata: Read`
-   **Setup**:
    1. Fork `microsoft/winget-pkgs` to your account
    2. Generate PAT with permissions above
    3. Add to repository secrets as `WINGET_GITHUB_TOKEN`

**Note**: No separate token needed for Scoop - it now targets the main `ScoopInstaller/Main` repository using your standard `GITHUB_TOKEN`.

### 2. GPG Signing Keys

For package authenticity and security:

#### GPG_PRIVATE_KEY

-   **Purpose**: Sign releases and packages
-   **Setup**:

    ```bash
    # Generate GPG key
    gpg --generate-key

    # Export private key
    gpg --armor --export-secret-keys YOUR_EMAIL > private.key

    # Copy contents to GitHub secret
    cat private.key
    ```

#### GPG_PASSPHRASE

-   **Purpose**: Passphrase for GPG private key
-   **Setup**: Add the passphrase you used when creating the GPG key

### 3. Package Manager API Keys

#### CHOCOLATEY_API_KEY

-   **Purpose**: Publish packages to Chocolatey.org
-   **Setup**:
    1. Create account at [chocolatey.org](https://chocolatey.org)
    2. Go to Account → API Keys
    3. Generate new API key
    4. Add to GitHub secrets as `CHOCOLATEY_API_KEY`

#### AUR_KEY

-   **Purpose**: Publish to Arch Linux User Repository (both packages)
-   **Packages**: `emojify-go` (source) and `emojify-go-bin` (binary)
-   **Setup**:
    1. Create account at [aur.archlinux.org](https://aur.archlinux.org)
    2. Generate SSH key pair:
        ```bash
        ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/aur
        ```
    3. Add public key to your AUR account
    4. Add private key contents to GitHub secrets as `AUR_KEY`

### 4. Optional Services

#### CODECOV_TOKEN

-   **Purpose**: Enhanced coverage reporting
-   **Setup**:
    1. Sign up at [codecov.io](https://codecov.io)
    2. Connect your GitHub repository
    3. Copy the repository token
    4. Add to GitHub secrets as `CODECOV_TOKEN`

#### SNAPCRAFT_STORE_CREDENTIALS

-   **Purpose**: Publish to Snap Store
-   **Setup**:
    1. Create account at [snapcraft.io](https://snapcraft.io)
    2. Install snapcraft: `sudo snap install snapcraft`
    3. Login and export credentials:
        ```bash
        snapcraft login
        snapcraft export-login snapcraft-credentials
        ```
    4. Add file contents to GitHub secrets as `SNAPCRAFT_STORE_CREDENTIALS`

## Repository Setup

### 1. Create Required Repositories

```bash
# Create Homebrew tap
gh repo create damienbutt/homebrew-tap --public --description "Homebrew tap for Emojify"

# Fork WinGet packages (via GitHub web interface)
# Go to: https://github.com/microsoft/winget-pkgs
# Click Fork → Create fork

# Note: No Scoop bucket needed - we target the main ScoopInstaller/Main repository
```

### 2. Initialize Repositories

#### Homebrew Tap

```bash
git clone https://github.com/damienbutt/homebrew-tap.git
cd homebrew-tap
echo "# Homebrew Tap for Emojify" > README.md
mkdir Formula
git add .
git commit -m "Initial commit"
git push origin main
```

## Validation

### Automated Validation

Run the validation script to check all prerequisites:

```bash
./scripts/validate-release-prerequisites.sh
```

### Manual Verification

1. **GitHub Secrets**: Verify all secrets are set in repository settings
2. **Repository Access**: Ensure PATs have correct permissions
3. **GPG Key**: Test signing with your GPG key
4. **External Services**: Verify API keys work with respective services

## Release Process

Once all prerequisites are in place:

1. **Create Release Tag**:

    ```bash
    git tag v1.0.0
    git push origin v1.0.0
    ```

2. **Monitor CI**: Watch GitHub Actions for the release workflow

3. **Verify Packages**: Check that packages appear in all repositories:
    - GitHub Releases
    - Docker registries
    - Homebrew tap
    - Scoop bucket
    - Chocolatey
    - AUR
    - Snap Store

## Troubleshooting

### Common Issues

1. **Permission Denied**: Check PAT permissions and expiration
2. **GPG Signing Fails**: Verify GPG key and passphrase
3. **Repository Not Found**: Ensure repositories exist and are accessible
4. **API Key Invalid**: Regenerate API keys and update secrets

### Debug Commands

```bash
# Test GPG signing
echo "test" | gpg --clearsign

# Verify repository access
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/damienbutt/homebrew-tap

# Test Chocolatey API
curl -H "X-NuGetApiKey: $CHOCOLATEY_API_KEY" https://push.chocolatey.org/api/v2/Packages
```

## Security Best Practices

1. **Rotate Keys Regularly**: Update API keys and GPG keys periodically
2. **Minimal Permissions**: Grant only necessary permissions to PATs
3. **Monitor Usage**: Watch for unexpected API usage
4. **Backup Keys**: Store GPG private key securely offline
5. **Audit Access**: Regularly review who has access to secrets

## Support

For issues with this setup:

1. Check the validation script output
2. Review GitHub Actions logs
3. Consult service-specific documentation
4. Open an issue in the repository

---

**Last Updated**: August 2025
**Next Review**: Before next major release
