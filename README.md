# 🎉 Emojify

[![CI](https://github.com/damienbutt/emojify-go/workflows/CI/badge.svg)](https://github.com/damienbutt/emojify-go/actions)
[![Go Report Card](https://goreportcard.com/badge/github.com/damienbutt/emojify-go)](https://goreportcard.com/report/github.com/damienbutt/emojify-go)
[![codecov](https://codecov.io/gh/damienbutt/emojify-go/branch/main/graph/badge.svg)](https://codecov.io/gh/damienbutt/emojify-go)
[![Go Version](https://img.shields.io/badge/Go-1.25+-00ADD8?style=flat&logo=go)](https://golang.org)
[![Release](https://img.shields.io/github/v/release/damienbutt/emojify-go)](https://github.com/damienbutt/emojify-go/releases)
[![Downloads](https://img.shields.io/github/downloads/damienbutt/emojify-go/total.svg)](https://github.com/damienbutt/emojify-go/releases)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A lightning-fast, cross-platform command-line tool for bidirectional emoji conversion. Convert between emoji aliases (`:smile:`) and Unicode emoji characters (😄) seamlessly. This is a complete Go rewrite of the original [emojify](https://github.com/mrowa44/emojify) bash script with **169.9x better performance** and modern tooling.

```bash
# Encode aliases to emojis (default behavior)
echo "Deploy completed :rocket: :100:" | emojify
# Deploy completed 🚀 💯

# Decode emojis back to aliases
echo "Deploy completed 🚀 💯" | emojify --decode
# Deploy completed :rocket: :100:

git log --oneline | emojify | head -5
# ✨ feat: add new feature :sparkles:
# 🐛 fix: resolve critical bug :bug:
# 📚 docs: update README :books:
```

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## :book: **Contents**

- [:sparkles: Features](#sparkles-features)
- [:package: Installation](#package-installation)
  - [Package Managers (Recommended)](#package-managers-recommended)
  - [:whale: Docker](#whale-docker)
  - [:inbox_tray: Direct Download](#inbox_tray-direct-download)
  - [:hammer_and_wrench: Build from Source](#hammer_and_wrench-build-from-source)
  - [:inbox_tray: Go Install](#inbox_tray-go-install)
- [:rocket: Usage](#rocket-usage)
  - [Basic Usage](#basic-usage)
  - [Bidirectional Conversion](#bidirectional-conversion)
  - [Pipeline Usage](#pipeline-usage)
  - [Command Options](#command-options)
- [:books: Examples](#books-examples)
  - [Git Integration](#git-integration)
  - [Common Use Cases](#common-use-cases)
  - [Advanced Pipeline Examples](#advanced-pipeline-examples)
- [:zap: Performance](#zap-performance)
  - [Benchmarks](#benchmarks)
- [:book: Documentation](#book-documentation)
  - [Man Page](#man-page)
    - [**Package Manager Installation**](#package-manager-installation)
- [:building_construction: Development](#building_construction-development)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Building](#building)
  - [Testing](#testing)
  - [Code Quality](#code-quality)
- [:wrench: Configuration](#wrench-configuration)
  - [Git Configuration](#git-configuration)
- [:whale: Docker](#whale-docker-1)
  - [Using the Official Image](#using-the-official-image)
  - [Building Custom Image](#building-custom-image)
- [:handshake: Contributing](#handshake-contributing)
  - [Quick Start](#quick-start)
  - [Development Guidelines](#development-guidelines)
  - [Areas for Contribution](#areas-for-contribution)
- [:balance_scale: License](#balance_scale-license)
- [:pray: Acknowledgments](#pray-acknowledgments)
- [:bar_chart: Status](#bar_chart-status)
- [:link: Related Projects](#link-related-projects)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## :sparkles: Features

-   ↔️ **Bidirectional Conversion**: Encode aliases to emojis and decode emojis back to aliases
-   ⚡ **Lightning Fast**: 169.9x faster than bash version (up to 758x on large files)
-   🌍 **Cross-Platform**: Single binary for Linux, macOS, Windows (AMD64 & ARM64)
-   📦 **Zero Dependencies**: No runtime dependencies, just download and run
-   🎯 **100% Compatible**: Drop-in replacement for original emojify
-   🔧 **Pipeline Friendly**: Perfect for git logs, CI/CD, and shell scripts
-   📊 **2,500+ Emojis**: Complete GitHub gemoji database
-   🛡️ **Production Ready**: Comprehensive tests, benchmarks, and error handling
-   🎨 **Modern CLI**: Built with urfave/cli for excellent UX

<!-- ## 🎬 Demo

<p align="center">
  <img src="./assets/img/demo.gif" alt="Emojify-Go Demo" width="800">
</p>

_Lightning-fast emoji conversion in action! See the 169.9x performance improvement over the original bash version._ -->

## :package: Installation

### Package Managers (Recommended)

<details>
<summary><strong>🍎 macOS</strong></summary>

```bash
# Homebrew
brew install damienbutt/tap/emojify-go
```

</details>

<details>
<summary><strong>🐧 Linux</strong></summary>

```bash
# Arch Linux (AUR)
# Install pre-built binary
paru -S emojify-go-bin

# Or build from source
paru -S emojify-go

# Ubuntu/Debian (DEB package)
wget https://github.com/damienbutt/emojify-go/releases/latest/download/emojify-go_linux_amd64.deb
sudo dpkg -i emojify-go_linux_amd64.deb

# RHEL/CentOS/Fedora (RPM package)
sudo rpm -i https://github.com/damienbutt/emojify-go/releases/latest/download/emojify-go_linux_amd64.rpm
```

</details>

<details>
<summary><strong>🪟 Windows</strong></summary>

```powershell
# Scoop
scoop install emojify-go

# WinGet
winget install damienbutt.emojify-go
```

</details>

<details>
<summary><strong>❄️ NixOS / Nix</strong></summary>

`emojify-go` is available in a [Nix User Repository (NUR)](https://github.com/damienbutt/nur).

To install `emojify-go` from the NUR, you first need to add the NUR to your Nix configuration. This is a one-time setup step.

**1. Add the NUR to your Nix configuration**

Add the following to your `~/.config/nixpkgs/config.nix` file:

```nix
{
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/damienbutt/nur/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
```

**2. Install the package**

```bash
nix-env -iA nur.repos.damienbutt.emojify-go
```

**Note on Nix Flakes**

If you're using Nix Flakes, you can install `emojify-go` directly from the NUR repo:

```bash
nix profile install github:damienbutt/nur#emojify-go
```

</details>

### :whale: Docker

```bash
# Run directly
echo "Hello :wave: world" | docker run --rm -i ghcr.io/damienbutt/emojify-go

# Use as alias
alias emojify='docker run --rm -i ghcr.io/damienbutt/emojify-go'
```

### :inbox_tray: Direct Download

Download the latest binary for your platform from the [releases page](https://github.com/damienbutt/emojify/releases).

```bash
# Linux (AMD64)
curl -L https://github.com/damienbutt/emojify-go/releases/latest/download/emojify-go_linux_amd64.tar.gz | tar xz
sudo mv emojify-go /usr/local/bin/emojify

# macOS (ARM64)
curl -L https://github.com/damienbutt/emojify-go/releases/latest/download/emojify-go_darwin_arm64.tar.gz | tar xz
sudo mv emojify-go /usr/local/bin/emojify

# Windows (AMD64)
curl -L https://github.com/damienbutt/emojify-go/releases/latest/download/emojify-go_windows_amd64.zip -o emojify.zip
unzip emojify.zip
```

### :hammer_and_wrench: Build from Source

```bash
git clone https://github.com/damienbutt/emojify-go.git
cd emojify-go
make build
./build/emojify "Hello :wave:"
```

### :inbox_tray: Go Install

```bash
go install github.com/damienbutt/emojify-go/cmd/emojify@latest
```

## :rocket: Usage

### Basic Usage

```bash
# Convert emoji aliases to emojis (default behavior)
emojify "Hey, I just :raising_hand: you, and this is :scream:"
# Output: Hey, I just 🙋 you, and this is 😱

# Explicitly encode aliases to emojis
emojify --encode "To :bee: or not to :bee:"
emojify -e "To :bee: or not to :bee:"
# Output: To 🐝 or not to 🐝

# Decode emojis back to aliases
emojify --decode "Deploy completed 🚀 💯 🎉"
emojify -d "Deploy completed 🚀 💯 🎉"
# Output: Deploy completed :rocket: :100: :tada:
```

### Bidirectional Conversion

```bash
# Round-trip conversion
echo "Hello :wave: world!" | emojify --encode | emojify --decode
# Output: Hello :wave: world!

# Convert emoji-rich text to aliases for storage/transmission
echo "Great work! 👍 🎉 🚀" | emojify --decode
# Output: Great work! :+1: :tada: :rocket:

# Convert back to emojis for display
echo "Great work! :+1: :tada: :rocket:" | emojify --encode
# Output: Great work! � 🎉 🚀
```

### Pipeline Usage

```bash
# Git log with emojis (most popular use case)
git log --oneline --color | emojify | less -r

# Git commit with emojis
git commit -m ":sparkles: Add new feature :rocket:"

# Echo and pipe (default encoding)
echo "Perfect! :100: :tada:" | emojify
# Output: Perfect! 💯 🎉

# Decode emoji-rich output
curl -s "https://api.github.com/repos/user/repo/commits" | jq -r '.[].commit.message' | emojify --decode

# Process files
cat commit_messages.txt | emojify > pretty_commits.txt
cat emoji_output.txt | emojify --decode > clean_text.txt

# CI/CD notifications with bidirectional support
echo "Build status: :white_check_mark: Success :rocket:" | emojify
echo "Build completed 🟢 ✅ 🚀" | emojify --decode
```

### Command Options

```bash
# Encode aliases to emojis (default behavior)
emojify "text with :aliases:"
emojify --encode "text with :aliases:"
emojify -e "text with :aliases:"

# Decode emojis to aliases
emojify --decode "text with 🚀 emojis"
emojify -d "text with 🚀 emojis"

# List all available emojis
emojify --list
emojify -l

# Show version information
emojify --version
emojify -v

# Get help
emojify --help
emojify -h
```

**Note**:

-   `--encode` and `--decode` flags are mutually exclusive.
-   When using shell pipes or arguments with special characters (`!`, `$`, etc.), wrap strings in single quotes or escape them properly.

## :books: Examples

### Git Integration

```bash
# Create a git alias for emoji logs
git config --global alias.elog '!git log --oneline --color | emojify | less -r'

# Create a git alias for clean (no emoji) logs
git config --global alias.clean-log '!git log --oneline --color | emojify --decode | less -r'

# Use the aliases
git elog      # Shows emojified commit messages
git clean-log # Shows clean text commit messages

# Emoji commit messages
git commit -m ":sparkles: feat: add user authentication :lock:"
git commit -m ":bug: fix: resolve memory leak :wrench:"
git commit -m ":books: docs: update API documentation"

# Extract clean commit messages for reports
git log --oneline --since="1 week ago" | emojify --decode > weekly_report.txt
```

### Common Use Cases

```bash
# Shakespeare with emojis
emojify "To :bee: or not to :bee: that is the question :thinking:"

# Convert emoji-rich social media content to clean text
echo "Amazing product 🎉 Love it ❤️ 5 stars ⭐⭐⭐⭐⭐" | emojify --decode
# Output: Amazing product :tada: Love it :heart: 5 stars :star::star::star::star::star:

# Status updates with bidirectional conversion
emojify "Server status: :green_heart: Healthy | Load: :chart_with_upwards_trend:"
echo "Server status: 💚 Healthy | Load: 📈" | emojify --decode

# Code review feedback
emojify "LGTM :+1: Great work :clap: Ship it :rocket:"

# Clean up emoji-heavy slack exports for documentation
cat slack_export.txt | emojify --decode > clean_documentation.txt

# Progress indicators
emojify "Progress: :white_check_mark: Tests | :white_check_mark: Build | :construction: Deploy"

# Convert between formats for different platforms
echo "🎯 Goal achieved 🚀 Next milestone: Q4 targets 📊" | emojify --decode | tee clean_report.txt | emojify
```

### Advanced Pipeline Examples

```bash
# Colorful git statistics
git shortlog -sn | head -10 | sed 's/^/👤 /' | emojify

# Enhanced build notifications
./build.sh && echo ":white_check_mark: Build successful :rocket:" | emojify || echo ":x: Build failed :sob:" | emojify

# Log processing with timestamps
tail -f app.log | while read line; do echo "$(date '+%H:%M:%S') :clock: $line"; done | emojify
```

## :zap: Performance

Emojify is built for speed and handles large inputs efficiently:

| Dataset Size      | Bash Version | Go Version | Speedup     |
| ----------------- | ------------ | ---------- | ----------- |
| Small (151 chars) | 395.6ms      | 177.8ms    | **2.22x**   |
| Medium (1.6KB)    | 659.3ms      | 155.8ms    | **4.23x**   |
| Large (17KB)      | 10.328s      | 126.9ms    | **81.36x**  |
| XLarge (90KB)     | 156.197s     | 205.8ms    | **758.81x** |

**Average Performance Improvement: 169.9x faster** ⚡

### Benchmarks

```bash
# Run performance benchmarks
make benchmark

# Test with large input
seq 1 10000 | sed 's/.*/:rocket: Line &/' | time emojify > /dev/null
```

## :book: Documentation

### Man Page

Emojify includes a comprehensive Unix manual page that provides detailed documentation about all commands and options.

#### **Package Manager Installation**

When installed via package managers, the man page is automatically available:

```bash
# After installing via Homebrew, AUR, etc.
man emojify
```

**Supported Systems**: macOS, Linux, Windows (WSL/MSYS2/Cygwin)

## :building_construction: Development

### Prerequisites

-   Go 1.23 or later
-   Make (optional, for convenience)

### Setup

```bash
git clone https://github.com/damienbutt/emojify-go.git
cd emojify-go
make dev-setup  # Downloads dependencies
```

### Building

```bash
# Build for current platform
make build                    # Output: build/emojify

# Build for all platforms
make build-all               # Output: build/emojify-{os}-{arch}

# Create optimized release binary
make release                 # Output: build/emojify (optimized)
```

### Testing

```bash
# Run all tests
make test

# Run tests with coverage
make test-coverage

# Run benchmarks
make benchmark

# Run specific benchmark
make benchmark-processor

# Integration tests
make test-integration

# Race condition testing
make test-race

# Generate test report
make test-report
```

### Code Quality

```bash
# Run linting
make lint

# Format code
go fmt ./...

# Vet code
go vet ./...

# Security scan
gosec ./...
```

## :wrench: Configuration

### Git Configuration

```bash
# Add emoji git aliases
git config --global alias.ec '!git log --oneline --color | emojify | head -10'
git config --global alias.es '!git status --porcelain | emojify'

# Set up commit template with emojis
cat > ~/.gitmessage << 'EOF'
# :sparkles: feat:
# :bug: fix:
# :books: docs:
# :art: style:
# :recycle: refactor:
# :white_check_mark: test:
# :construction_worker: build:
# :green_heart: ci:
EOF

git config --global commit.template ~/.gitmessage
```

## :whale: Docker

### Using the Official Image

```bash
# Run with stdin
echo "Hello :wave: Docker" | docker run --rm -i ghcr.io/damienbutt/emojify-go

# Process files
docker run --rm -v $(pwd):/workspace -w /workspace ghcr.io/damienbutt/emojify-go "$(cat input.txt)"

# Multi-architecture support
docker run --platform linux/arm64 --rm -i ghcr.io/damienbutt/emojify-go
```

### Building Custom Image

```bash
# Build image
docker build -t my-emojify .

# Run
echo "Custom build :hammer:" | docker run --rm -i my-emojify
```

## :handshake: Contributing

We love contributions! Here's how you can help:

### Quick Start

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Make** your changes
4. **Add** tests for new functionality
5. **Run** tests: `make test`
6. **Commit** with emojis: `git commit -m ":sparkles: feat: add amazing feature"`
7. **Push** to your branch: `git push origin feature/amazing-feature`
8. **Open** a Pull Request

### Development Guidelines

-   Write tests for new features
-   Follow Go conventions and best practices
-   Run `make lint` before committing
-   Include benchmarks for performance-critical code
-   Update documentation for user-facing changes

### Areas for Contribution

-   🌐 Additional package managers
-   🔧 New emoji sources/databases
-   📊 Performance optimizations
-   🧪 Additional test cases
-   📚 Documentation improvements
-   🐛 Bug fixes and edge cases

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## :balance_scale: License

MIT License - see [LICENSE](LICENSE) for details.

## :pray: Acknowledgments

-   **[Original emojify](https://github.com/mrowa44/emojify)** - Inspiration and compatibility
-   **[GitHub Gemoji](https://github.com/github/gemoji)** - Emoji database
-   **[urfave/cli](https://github.com/urfave/cli)** - Excellent CLI framework
-   **[testify](https://github.com/stretchr/testify)** - Testing framework

## :bar_chart: Status

-   ✅ **Production Ready**: Used in CI/CD pipelines and development workflows
-   ✅ **Actively Maintained**: Regular updates and improvements
-   ✅ **Cross-Platform**: Supports all major platforms and architectures
-   ✅ **Well Tested**: Comprehensive test suite with >95% coverage

## :link: Related Projects

-   **[emojify](https://github.com/mrowa44/emojify)** - Original bash implementation
-   **[pyemojify](https://github.com/lord63/pyemojify)** - Python implementation
-   **[node-emojify](https://github.com/heldr/node-emojify)** - Node.js implementation

---

<div align="center">

**[⬆ Back to Top](#-emojify)**

Made with :heart: and :coffee:

**Star ⭐ this repo if you find it useful!**

</div>
