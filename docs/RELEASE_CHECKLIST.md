# Release Prerequisites Checklist

Use this checklist to ensure you have everything set up for releases.

## GitHub Secrets Required

### Essential Secrets

-   [ ] `GITHUB_TOKEN` (auto-provided by GitHub Actions)
-   [ ] `HOMEBREW_TAP_GITHUB_TOKEN` (PAT for homebrew-tap repo)
-   [ ] `SCOOP_BUCKET_GITHUB_TOKEN` (PAT for scoop-bucket repo)
-   [ ] `WINGET_GITHUB_TOKEN` (PAT for winget-pkgs fork)
-   [ ] `CHOCOLATEY_API_KEY` (API key from chocolatey.org)
-   [ ] `AUR_KEY` (SSH private key for AUR)
-   [ ] `GPG_PRIVATE_KEY` (GPG private key for signing)
-   [ ] `GPG_PASSPHRASE` (GPG key passphrase)

### Optional Secrets

-   [ ] `CODECOV_TOKEN` (for enhanced coverage reporting)
-   [ ] `SNAPCRAFT_STORE_CREDENTIALS` (for Snap Store publishing)
-   [ ] `GPG_KEY_FILE` (for RPM package signing)

## Required Repositories

-   [ ] `damienbutt/homebrew-tap` (Homebrew formulas)
-   [ ] `damienbutt/scoop-bucket` (Scoop manifests)
-   [ ] Fork of `microsoft/winget-pkgs` (WinGet packages)

## External Account Setup

-   [ ] Chocolatey.org account and API key
-   [ ] AUR account and SSH key (publishes both `emojify-go` and `emojify-go-bin`)
-   [ ] Codecov.io account (optional)
-   [ ] Snapcraft.io account (optional)

## Validation

-   [ ] Run `./scripts/validate-release-prerequisites.sh`
-   [ ] All checks pass ✅

## Quick Setup Commands

```bash
# Make validation script executable
chmod +x scripts/validate-release-prerequisites.sh

# Run validation
./scripts/validate-release-prerequisites.sh

# Test release (dry-run)
git tag v0.0.1-test
git push origin v0.0.1-test
# Watch GitHub Actions, then delete test tag:
git tag -d v0.0.1-test
git push origin :refs/tags/v0.0.1-test
```

---

📖 **Full Documentation**: [docs/RELEASE_SETUP.md](./RELEASE_SETUP.md)
