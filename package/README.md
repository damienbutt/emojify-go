# Package Manifests

This directory contains package manifest files maintained directly in the repository for various package managers.

## Structure

```
packaging/
├── homebrew/
│   └── emojify-go.rb          # Homebrew formula
├── scoop/
│   └── emojify-go.json        # Scoop manifest
└── README.md                  # This file
```

## Homebrew Formula

**File**: `homebrew/emojify-go.rb`

-   **Purpose**: Homebrew formula for macOS/Linux installations
-   **Distribution**: Automatically updated by GoReleaser to `homebrew-tap` repository
-   **Local Copy**: Maintained here for reference and manual testing
-   **Testing**: Use `brew install --formula ./packaging/homebrew/emojify-go.rb` for local testing

### Manual Installation

```bash
# Install directly from local formula
brew install --formula ./packaging/homebrew/emojify-go.rb

# Or install from tap (recommended)
brew tap damienbutt/tap
brew install emojify-go
```

## Scoop Manifest

**File**: `scoop/emojify-go.json`

-   **Purpose**: Scoop manifest for Windows installations
-   **Distribution**: Automatically updated by GoReleaser to main Scoop bucket
-   **Local Copy**: Maintained here for reference and manual testing
-   **Testing**: Use `scoop install ./packaging/scoop/emojify-go.json` for local testing

### Manual Installation

```powershell
# Install directly from local manifest
scoop install ./packaging/scoop/emojify-go.json

# Or install from bucket (recommended)
scoop bucket add damienbutt https://github.com/damienbutt/scoop-bucket
scoop install emojify-go
```

## Automated Updates

These manifest files are automatically updated during releases by GoReleaser:

1. **During Release**: GoReleaser reads these templates
2. **Version Substitution**: Replaces version placeholders with actual release version
3. **Checksum Calculation**: Updates SHA256 hashes for release artifacts
4. **Repository Updates**: Pushes updated manifests to respective package repositories

## Development Workflow

### Testing Changes

1. **Homebrew**:

    ```bash
    # Test local formula
    brew install --formula ./packaging/homebrew/emojify-go.rb

    # Audit formula
    brew audit --strict ./packaging/homebrew/emojify-go.rb
    ```

2. **Scoop**:

    ```powershell
    # Test local manifest
    scoop install ./packaging/scoop/emojify-go.json

    # Validate manifest
    scoop checkver ./packaging/scoop/emojify-go.json
    ```

### Manual Updates

If you need to manually update these files:

1. Update version numbers and URLs
2. Recalculate checksums from release artifacts
3. Test locally before committing
4. GoReleaser will use these as templates for the next release

## Related Files

-   **GoReleaser Config**: `.goreleaser.yml` - Automated release configuration
-   **AUR Packages**: `aur/` - Arch Linux packages
-   **Nix Packages**: `flake.nix`, `default.nix` - Nix ecosystem packages

## Package Manager Status

| Package Manager | Status     | Repository                                                   | Auto-Update |
| --------------- | ---------- | ------------------------------------------------------------ | ----------- |
| Homebrew        | ✅ Active  | [homebrew-tap](https://github.com/damienbutt/homebrew-tap)   | Yes         |
| Scoop           | ✅ Active  | [Main bucket](https://github.com/ScoopInstaller/Main)        | Yes         |
| Chocolatey      | ✅ Active  | [chocolatey.org](https://chocolatey.org/packages/emojify-go) | Yes         |
| AUR             | ✅ Active  | [emojify-go](https://aur.archlinux.org/packages/emojify-go)  | Semi-auto   |
| Nix             | ✅ Active  | [NUR](https://github.com/damienbutt/nur-packages)            | Yes         |
| Snap            | 🔄 Planned | [snapcraft.io](https://snapcraft.io/)                        | TBD         |
