# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Complete Go rewrite of the original bash emojify script
- Comprehensive emoji mapping with 2,558+ unique emojis
- High-performance text processing with buffered I/O
- Cross-platform support (macOS, Linux, Windows)
- Multiple architecture support (AMD64, ARM64)
- Docker container support
- Comprehensive package manager integration:
  - macOS: Homebrew
  - Windows: Scoop, Chocolatey, WinGet
  - Linux: AUR, DEB, RPM, pacman, Snap
- Full CLI compatibility with original bash version
- Extensive test suite with testify framework
- Performance benchmarking and optimization
- CI/CD pipeline with GitHub Actions
- Automated releases with GoReleaser
- Security scanning and code quality checks

### Changed

- Migrated from bash to Go for significantly improved performance
- Enhanced buffer handling for large input processing (10MB max token size)
- Improved error handling and edge case management
- Better Unicode support and emoji validation

### Performance

- **20-70x speed improvement** over original bash implementation
- Efficient memory usage with streaming processing
- Optimized for large input files
- Minimal resource footprint

### Dependencies

- Go 1.23+ runtime requirement
- urfave/cli v2 for command-line interface
- testify for comprehensive testing

### Documentation

- Complete README with installation and usage instructions
- Contributing guidelines for developers
- Comprehensive code documentation
- Performance comparison data
- Multi-platform installation guides

## [1.0.0] - Initial Go Release

### Added

- Initial Go implementation
- Core emoji replacement functionality
- CLI interface with help, list, and version commands
- Stdin and argument processing
- Basic test coverage
- Cross-platform build support

---

**Note**: This changelog represents the Go rewrite of the original bash emojify script. The bash version had its own evolution history, but this Go version starts fresh with modern architecture and significantly enhanced performance.
