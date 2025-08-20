# AUR Packages for emojify-go

This directory contains P## Testing Locally

To test the source PKGBUILD locally before uploading to AUR:

```bash
# Test source package
cd aur/emojify-go
makepkg -si
```

Note: The binary package is automatically tested and deployed by GoReleaser, so manual testing is not required.

## Notes

-   Both packages provide the `emojify` binary and conflict with each other
-   The binary package is automatically updated by GoReleaser on releases
-   The source package should be manually maintained and updated
-   `.SRCINFO` files are generated automatically with `makepkg --printsrcinfo`
-   Only PKGBUILD files are stored in this repositoryrch User Repository (AUR) packages.

## Packages

### emojify-go (Source Package)

-   **Directory**: `emojify-go/`
-   **Package Name**: `emojify-go`
-   **Type**: Source package (builds from source)
-   **AUR URL**: https://aur.archlinux.org/packages/emojify-go/
-   **Installation**: `yay -S emojify-go` or `paru -S emojify-go`

This package downloads the source code and compiles emojify-go locally on your system.

### emojify-go-bin (Binary Package)

-   **Directory**: `emojify-go-bin/`
-   **Package Name**: `emojify-go-bin`
-   **Type**: Binary package (pre-compiled)
-   **AUR URL**: https://aur.archlinux.org/packages/emojify-go-bin/
-   **Installation**: `yay -S emojify-go-bin` or `paru -S emojify-go-bin`

This package downloads pre-compiled binaries from GitHub releases. Faster installation but depends on GitHub releases.

## Package Management

### GoReleaser Integration

-   **Binary Package (`emojify-go-bin`)**: Automatically managed by GoReleaser on each release
    -   GoReleaser generates the PKGBUILD and pushes to AUR
    -   No manual intervention needed for releases
-   **Source Package (`emojify-go`)**: Must be manually maintained
    -   Provides building from source option
    -   Requires manual updates for new versions

## Updating Packages

### For Source Package (`emojify-go`) - Manual Process

1. Update `pkgver` in `PKGBUILD`
2. Update `sha256sums` with the correct checksum of the source tarball
3. Generate `.SRCINFO`: `makepkg --printsrcinfo > .SRCINFO`
4. Test the package: `makepkg -si`
5. Commit and push to the AUR repository

### For Binary Package (`emojify-go-bin`) - Automated

The binary package is automatically updated by GoReleaser when you create a release. The process:

1. GoReleaser reads the AUR configuration from `.goreleaser.yml`
2. Generates PKGBUILD with correct version and checksums
3. Generates `.SRCINFO` automatically
4. Commits and pushes to the AUR repository

## Testing Locally

To test the PKGBUILD files locally:

```bash
# Test source package
cd aur/emojify-go
makepkg -si

# Test binary package
cd aur/emojify-go-bin
makepkg -si
```

## Notes

-   Both packages provide the `emojify` binary and conflict with each other
-   The binary package is automatically updated by GoReleaser on releases
-   The source package should be manually maintained and updated
-   Remember to update checksums when releasing new versions
-   The binary package only supports x86_64 and aarch64 architectures
-   The source package supports additional architectures (armv7h)

## Maintainer Information

Both packages are maintained by Damien Butt <damien@damienbutt.com>.

For issues with the AUR packages, please open an issue in this repository or comment on the AUR package pages.
