# Nix Package Support

This directory contains Nix package definitions and configuration for emojify-go.

## Files

-   `../flake.nix`: Main Nix flake configuration with development shell
-   `../default.nix`: Traditional Nix expression for package builds
-   `../.envrc`: direnv configuration for automatic development environment

## Installation

### Using Nix Flakes (Recommended)

```bash
# Install directly from GitHub
nix profile install github:damienbutt/emojify-go

# Or run without installing
nix run github:damienbutt/emojify-go
```

### Using Traditional Nix

```bash
# Build from source
nix-build

# Install to user profile
nix-env -f default.nix -i emojify-go
```

### Development Environment

With direnv and Nix flakes:

```bash
# Clone repository
git clone https://github.com/damienbutt/emojify-go.git
cd emojify-go

# Allow direnv (if using)
direnv allow

# Or manually enter development shell
nix develop
```

The development shell includes:

-   Go 1.22
-   golangci-lint
-   goreleaser
-   git
-   make

## Package Distribution

emojify-go will be available through:

1. **Nixpkgs** (via GoReleaser automation)
2. **NUR (Nix User Repository)** - Personal overlay
3. **Direct flake installation** - This repository

## Building Locally

```bash
# Build with flakes
nix build

# Build traditional
nix-build

# Development build
nix develop -c make build
```

## Contributing

When updating dependencies:

1. Update `go.mod` and `go.sum`
2. If needed, update `vendorHash` in Nix files
3. Test builds with `nix build`
4. Verify development environment with `nix develop`

The `vendorHash` can be calculated by:

1. Setting it to an empty string `""`
2. Running `nix build`
3. Using the hash from the error message
