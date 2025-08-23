# 📖 Man Page Management Guide

## Overview

The `emojify` command includes a Unix manual page that is distributed through package managers. This follows the standard approach used by major Go CLI tools like GitHub CLI, kubectl, and Helm.

## 🎯 Distribution Methods

### **Package Manager Integration** ✅ IMPLEMENTED

Each package manager automatically installs the man page from `man/emojify.1`:

#### **🍎 Homebrew (macOS/Linux)**

```ruby
# In Formula/emojify-go.rb
if File.exist?("man/emojify.1")
  man1.install "man/emojify.1"  # Automatic installation
end
```

**Installation**: `brew install damienbutt/tap/emojify-go`
**Man page location**: `/opt/homebrew/share/man/man1/emojify.1`
**Usage**: `man emojify`

#### **🐧 AUR (Arch Linux)**

```bash
# In PKGBUILD
install -Dm644 man/emojify.1 "$pkgdir/usr/share/man/man1/emojify.1"
```

**Installation**: `paru -S emojify-go-bin`
**Man page location**: `/usr/share/man/man1/emojify.1`
**Usage**: `man emojify`

#### **🪟 Chocolatey (Windows)**

```powershell
# For WSL/MSYS2/Cygwin compatibility
$manDir = Join-Path $env:ChocolateyInstall 'share\man\man1'
Copy-Item -Path $manPath -Destination (Join-Path $manDir 'emojify.1')
```

**Installation**: `choco install emojify-go`
**Man page location**: `C:\ProgramData\chocolatey\share\man\man1\emojify.1`
**Usage**: `man emojify` (in WSL/MSYS2/Cygwin)

### **Manual Installation**

For direct binary downloads:

```bash
# Download and extract release
curl -L https://github.com/damienbutt/emojify-go/releases/latest/download/emojify-go_linux_amd64.tar.gz | tar xz

# Install binary
sudo mv emojify /usr/local/bin/

# Install man page
sudo cp man/emojify.1 /usr/share/man/man1/
sudo mandb  # Update man database
```

## 🏗️ Architecture

### **Simple Design**

-   **Single source**: `man/emojify.1` is the only man page file
-   **Package managers**: Handle installation to system directories
-   **No embedding**: Follows standard Go CLI tool patterns
-   **Clean distribution**: Included in release archives

### **How Major Go Tools Handle This**

-   **GitHub CLI**: Generates man pages during build, packages handle installation
-   **kubectl**: Uses cobra doc generation, no embedding
-   **Helm**: Standard package manager distribution
    sudo mandb # Update man database

```

## 🔧 Implementation Details

### **Embedded Man Page Code**

The man page is embedded using a clean, single-source approach:

**File Structure:**

```

man/emojify.1 # ← Single source of truth
cmd/emojify/emojify.1 -> ../../man/emojify.1 # ← Symbolic link for embed
man.go # ← Root-level package for embedding

````

**Implementation:**

```go
// In man.go (root package)
package man

import _ "embed"

//go:embed man/emojify.1
var Page []byte

func Install() error { /* ... */ }
func Show() error { /* ... */ }
func Uninstall() error { /* ... */ }
````

```go
// In cmd/emojify/main.go
import man "github.com/damienbutt/emojify-go"

// Usage in CLI flags
if c.Bool("install-man") {
    return man.Install()
}
```

**Key Benefits:**

-   **Single source**: Only `docs/man/emojify.1` needs maintenance
-   **Clean embedding**: Root package can access docs/ directory
-   **No duplication**: Symbolic link enables embed without file copying

### **Smart Installation Logic**

1. **Directory Detection**: Finds writable man directories
2. **Permission Handling**: Prefers user directories over system
3. **Database Updates**: Automatically runs `mandb`/`makewhatis`
4. **Cross-platform**: Handles Unix and Windows environments

### **GoReleaser Integration**

Man page included in all release archives:

```yaml
# .goreleaser.yml
archives:
    - files:
          - README.md
          - LICENSE.md
          - man/emojify.1 # ← Included in all packages
```

## 🎯 User Experience

### **Package Manager Users** (Recommended)

-   **Zero effort**: Man page automatically installed
-   **System integration**: Works with standard `man emojify`
-   **Updates**: Man page updated with package

### **Direct Binary Users**

-   **Self-service**: `emojify --install-man` for easy setup
-   **Portable**: `emojify --show-man` works anywhere
-   **Clean removal**: `emojify --uninstall-man` for cleanup

### **Developer/CI Users**

-   **Embedded access**: Always available without files
-   **Scriptable**: Can pipe output or redirect to files
-   **Universal**: Works in containers, restricted environments

## 🏆 Best Practices

### **For Package Maintainers**

1. Always include man page in packages
2. Install to standard locations (`/usr/share/man/man1/`)
3. Update man database after installation
4. Remove man page during uninstall

### **For Users**

1. Prefer package manager installation when available
2. Use `--show-man` for quick reference
3. Use `--install-man` for permanent access
4. Check `man emojify` works after installation

### **For Developers**

1. Keep embedded man page in sync with CLI
2. Update version in man page header
3. Test man page display on all platforms
4. Include man page in release archives

## 📋 Testing

```bash
# Test embedded functionality
emojify --show-man | head -10
emojify --install-man
man emojify
emojify --uninstall-man

# Test package installation
brew install damienbutt/tap/emojify-go
man emojify

# Test manual installation
sudo cp man/emojify.1 /usr/share/man/man1/
sudo mandb
man emojify
```

## 🎉 Summary

**Multi-layered approach ensures maximum compatibility:**

1. 📦 **Package managers** handle automatic installation
2. 🔧 **Embedded support** provides universal access
3. 📖 **Manual installation** covers edge cases
4. 🧪 **Comprehensive testing** validates all methods

**Result**: Users get professional Unix documentation regardless of installation method! 🚀
