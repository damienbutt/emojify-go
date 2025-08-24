# Build configuration
APP_NAME := emojify
GO_MODULE := github.com/damienbutt/emojify-go
BUILD_DIR := build
DIST_DIR := dist
SRC_DIR := cmd/emojify
SCRAPER_SRC := cmd/emojify-scraper
INSTALL_DIR := /usr/local/bin

# Go build settings
CGO_ENABLED := 0

# Version information (from git tags and commit)
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_TIME := $(shell date -u '+%Y-%m-%d_%H:%M:%S')

# Optimization flags for smallest possible binary
GCFLAGS := -gcflags="all=-l"
ASMFLAGS := -asmflags="all=-trimpath=$(PWD)"
LDFLAGS_BASE := -s -w -buildid= -X main.version=$(VERSION) -X main.commit=$(COMMIT) -X main.buildTime=$(BUILD_TIME)
LDFLAGS := -ldflags "$(LDFLAGS_BASE)"
LDFLAGS_RELEASE := -ldflags "$(LDFLAGS_BASE) -extldflags '-static'"

# Build tags for optimized builds
BUILD_TAGS := netgo osusergo

# Additional optimization settings
GOOS_BUILD := $(if $(GOOS),$(GOOS),$(shell go env GOOS))
GOARCH_BUILD := $(if $(GOARCH),$(GOARCH),$(shell go env GOARCH))

# Default target
.PHONY: all
all: clean build

# Create build directory
.PHONY: build-dir
build-dir:
	@echo "📁 Creating build directory..."
	@mkdir -p $(BUILD_DIR)

# Build the binary
.PHONY: build
build: build-dir
	@echo "🔨 Building $(APP_NAME)..."
	@CGO_ENABLED=$(CGO_ENABLED) go build $(LDFLAGS) -tags "$(BUILD_TAGS)" -o $(BUILD_DIR)/$(APP_NAME) ./$(SRC_DIR)
	@echo "✅ Build complete: $(BUILD_DIR)/$(APP_NAME)"

# Build for development (with debug info)
.PHONY: build-dev
build-dev: build-dir
	@echo "🔨 Building $(APP_NAME) (development)..."
	@go build -gcflags="all=-N -l" -o $(BUILD_DIR)/$(APP_NAME)-dev ./$(SRC_DIR)
	@echo "✅ Development build complete: $(BUILD_DIR)/$(APP_NAME)-dev"

# Build for multiple platforms
.PHONY: build-all
build-all: build-dir
	@echo "🔨 Building $(APP_NAME) for multiple platforms..."
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=linux GOARCH=amd64 go build $(LDFLAGS_RELEASE) $(GCFLAGS) $(ASMFLAGS) -tags "$(BUILD_TAGS)" -o $(BUILD_DIR)/$(APP_NAME)-linux-amd64 ./$(SRC_DIR)
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=linux GOARCH=arm64 go build $(LDFLAGS_RELEASE) $(GCFLAGS) $(ASMFLAGS) -tags "$(BUILD_TAGS)" -o $(BUILD_DIR)/$(APP_NAME)-linux-arm64 ./$(SRC_DIR)
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) $(GCFLAGS) $(ASMFLAGS) -tags "$(BUILD_TAGS)" -o $(BUILD_DIR)/$(APP_NAME)-darwin-amd64 ./$(SRC_DIR)
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=darwin GOARCH=arm64 go build $(LDFLAGS) $(GCFLAGS) $(ASMFLAGS) -tags "$(BUILD_TAGS)" -o $(BUILD_DIR)/$(APP_NAME)-darwin-arm64 ./$(SRC_DIR)
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=windows GOARCH=amd64 go build $(LDFLAGS) $(GCFLAGS) $(ASMFLAGS) -tags "$(BUILD_TAGS)" -o $(BUILD_DIR)/$(APP_NAME)-windows-amd64.exe ./$(SRC_DIR)
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=windows GOARCH=arm64 go build $(LDFLAGS) $(GCFLAGS) $(ASMFLAGS) -tags "$(BUILD_TAGS)" -o $(BUILD_DIR)/$(APP_NAME)-windows-arm64.exe ./$(SRC_DIR)
	@echo "✅ Multi-platform build complete"

# Test the Go code
.PHONY: test
test:
	@echo "🧪 Running tests..."
	@go test ./internal/... ./tests/...

# Run tests with verbose output
.PHONY: test-verbose
test-verbose:
	@echo "🧪 Running tests (verbose)..."
	@go test -v ./internal/... ./tests/...

# Run tests with coverage
.PHONY: test-coverage
test-coverage:
	@echo "🧪 Running tests with coverage..."
	@go test -race -coverprofile=coverage.out ./internal/... ./tests/...
	@go tool cover -html=coverage.out -o coverage.html
	@go tool cover -func=coverage.out | tail -1
	@echo "✅ Coverage report generated: coverage.html"

# Run tests with coverage and open in browser
.PHONY: test-coverage-view
test-coverage-view: test-coverage
	@echo "🌐 Opening coverage report..."
	@open coverage.html

# Run tests with race detection
.PHONY: test-race
test-race:
	@echo "🧪 Running tests with race detection..."
	@go test -race ./...

# Run benchmarks
.PHONY: benchmark
benchmark:
	@echo "⚡ Running benchmarks..."
	@go test -bench=. -benchmem ./internal/... ./tests/...

# Run specific benchmark
.PHONY: benchmark-processor
benchmark-processor:
	@echo "⚡ Running processor benchmarks..."
	@go test -bench=BenchmarkProcessor -benchmem ./internal/emojify

# Run integration tests only
.PHONY: test-integration
test-integration:
	@echo "🧪 Running integration tests..."
	@go test -v ./tests/...

# Run unit tests only (exclude integration tests)
.PHONY: test-unit
test-unit:
	@echo "🧪 Running unit tests..."
	@go test -v ./internal/...

# Run tests and benchmarks
.PHONY: test-all
test-all: test benchmark
	@echo "✅ All tests and benchmarks complete"

# Generate test report
.PHONY: test-report
test-report:
	@echo "📊 Generating test reports..."
	@go test -json ./... > test-results.json
	@go test -bench=. -benchmem ./... > benchmark-results.txt
	@echo "✅ Test reports generated: test-results.json, benchmark-results.txt"

# Create release binary (optimized)
.PHONY: release
release: build-dir
	@echo "🔨 Building optimized release binary..."
	@CGO_ENABLED=$(CGO_ENABLED) go build $(LDFLAGS_RELEASE) $(GCFLAGS) $(ASMFLAGS) -tags "$(BUILD_TAGS)" -o $(BUILD_DIR)/$(APP_NAME) ./$(SRC_DIR)
	@echo "✅ Release build complete: $(BUILD_DIR)/$(APP_NAME)"
	@echo "📊 Binary size: $$(du -h $(BUILD_DIR)/$(APP_NAME) | cut -f1)"

# Create ultra-optimized binary with UPX compression
.PHONY: release-ultra
release-ultra: release
	@echo "🗜️  Creating ultra-compressed binary..."
	@if command -v upx >/dev/null 2>&1; then \
		cp $(BUILD_DIR)/$(APP_NAME) $(BUILD_DIR)/$(APP_NAME)-uncompressed; \
		upx --best --lzma $(BUILD_DIR)/$(APP_NAME); \
		echo "📊 Compressed size: $$(du -h $(BUILD_DIR)/$(APP_NAME) | cut -f1)"; \
		echo "📊 Original size: $$(du -h $(BUILD_DIR)/$(APP_NAME)-uncompressed | cut -f1)"; \
	else \
		echo "⚠️  UPX not found, skipping compression"; \
		echo "💡 Install UPX for even smaller binaries: brew install upx"; \
	fi

# Show binary size comparison
.PHONY: size-comparison
size-comparison: build-dir
	@echo "📊 Building binaries with different optimization levels..."
	@echo ""
	@echo "🔨 Building with no optimization..."
	@CGO_ENABLED=$(CGO_ENABLED) go build -o $(BUILD_DIR)/$(APP_NAME)-debug ./$(SRC_DIR)
	@echo "🔨 Building with basic optimization..."
	@CGO_ENABLED=$(CGO_ENABLED) go build -ldflags "-s -w" -o $(BUILD_DIR)/$(APP_NAME)-basic ./$(SRC_DIR)
	@echo "🔨 Building with full optimization..."
	@CGO_ENABLED=$(CGO_ENABLED) go build $(LDFLAGS_RELEASE) $(GCFLAGS) $(ASMFLAGS) -tags "$(BUILD_TAGS)" -o $(BUILD_DIR)/$(APP_NAME)-optimized ./$(SRC_DIR)
	@echo ""
	@echo "📊 Size Comparison:"
	@echo "   Debug build:      $$(du -h $(BUILD_DIR)/$(APP_NAME)-debug | cut -f1)"
	@echo "   Basic optimized:  $$(du -h $(BUILD_DIR)/$(APP_NAME)-basic | cut -f1)"
	@echo "   Fully optimized:  $$(du -h $(BUILD_DIR)/$(APP_NAME)-optimized | cut -f1)"
	@if command -v upx >/dev/null 2>&1; then \
		cp $(BUILD_DIR)/$(APP_NAME)-optimized $(BUILD_DIR)/$(APP_NAME)-upx; \
		upx --best --lzma $(BUILD_DIR)/$(APP_NAME)-upx >/dev/null 2>&1; \
		echo "   UPX compressed:   $$(du -h $(BUILD_DIR)/$(APP_NAME)-upx | cut -f1)"; \
	fi
	@echo ""

# Clean build artifacts
.PHONY: clean
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)/
	@rm -rf $(DIST_DIR)/
	@rm -f coverage.out coverage.html
	@rm -f test-results.json benchmark-results.txt
	@rm -f $(APP_NAME) $(APP_NAME)_test
	@echo "✅ Clean complete"

# Install the binary to system
.PHONY: install
install: build
	@echo "📦 Installing $(APP_NAME) to $(INSTALL_DIR)..."
	@sudo cp $(BUILD_DIR)/$(APP_NAME) $(INSTALL_DIR)/
	@sudo chmod +x $(INSTALL_DIR)/$(APP_NAME)
	@echo "✅ Installation complete: $(INSTALL_DIR)/$(APP_NAME)"

# Install to $GOPATH/bin
.PHONY: install-go
install-go:
	@echo "📦 Installing $(APP_NAME) to $GOPATH/bin..."
	@go install ./$(SRC_DIR)
	@echo "✅ Go installation complete"

# Uninstall the binary from system
.PHONY: uninstall
uninstall:
	@echo "🗑️  Uninstalling $(APP_NAME)..."
	@sudo rm -f $(INSTALL_DIR)/$(APP_NAME)
	@echo "✅ Uninstall complete"

# Run the application directly
.PHONY: run
run: build
	@echo "🚀 Running $(APP_NAME)..."
	@./$(BUILD_DIR)/$(APP_NAME)

# Run the application in development mode
.PHONY: run-dev
run-dev:
	@echo "🚀 Running $(APP_NAME) (development)..."
	@go run ./$(SRC_DIR)

# Run with example
.PHONY: run-example
run-example:
	@echo "🚀 Running $(APP_NAME) with example..."
	@echo "Hello :wink: :tada:" | go run ./$(SRC_DIR)

# Run linting and formatting (strict)
.PHONY: lint
lint: fmt vet
	@echo "🔍 Running linter..."
	@echo "🔍 Running golangci-lint..."
	@go tool golangci-lint run
	@echo "✅ Linting complete"

# Run linting with auto-fix for development
.PHONY: lint-fix
lint-fix: fmt vet
	@echo "🔧 Running linter with auto-fix..."
	@echo "🔍 Running golangci-lint with fixes..."
	@go tool golangci-lint run --fix
	@echo "✅ Linting with fixes complete"

# Run linting with relaxed rules for development
.PHONY: lint-dev
lint-dev: fmt vet
	@echo "🔧 Running development linter..."
	@echo "🔍 Running golangci-lint (essential checks only)..."
	@go tool golangci-lint run --config=/dev/null --disable-all --enable=errcheck,gosimple,govet,ineffassign,staticcheck,typecheck,unused --fix
	@echo "✅ Development linting complete"

# Format Go code with goimports (handles formatting + imports)
.PHONY: fmt
fmt:
	@echo "📝 Formatting Go code with goimports..."
	@go tool goimports -w . || go fmt ./...
	@echo "✅ Formatting complete"

# Format Go code (basic go fmt only)
.PHONY: fmt-basic
fmt-basic:
	@echo "📝 Basic Go formatting..."
	@go fmt ./...
	@echo "✅ Basic formatting complete"

# Run go vet
.PHONY: vet
vet:
	@echo "🔎 Running go vet..."
	@go vet ./...
	@echo "✅ Vet complete"

# Tidy Go modules
.PHONY: tidy
tidy:
	@echo "📦 Tidying Go modules..."
	@go mod tidy
	@echo "✅ Module tidy complete"

# Download dependencies
.PHONY: deps
deps:
	@echo "📥 Downloading dependencies..."
	@go mod download
	@echo "✅ Dependencies downloaded"

# Verify dependencies
.PHONY: verify
verify: tidy
	@echo "🔍 Verifying dependencies..."
	@go mod verify && \
	(git diff --exit-code go.mod go.sum || (echo "❌ go.mod or go.sum is not tidy" && exit 1))
	@echo "✅ Dependencies verified"

# Development setup
.PHONY: dev-setup
dev-setup: deps tidy
	@echo "✅ Development environment setup complete"

# Update emoji data from GitHub
.PHONY: update-emoji
update-emoji:
	@echo "🔄 Updating emoji data from GitHub..."
	@go run ./$(SCRAPER_SRC)
	@echo "✅ Emoji data updated"

# Run vulnerability check
.PHONY: vuln-check
vuln-check:
	@echo "🔍 Checking for vulnerabilities..."
	@go tool govulncheck ./... || echo "⚠️  govulncheck not found, skipping"
	@echo "✅ Vulnerability check complete"

# Generate man page
.PHONY: man
man:
	@echo "📖 Generating man page..."
	@./man/manage-man.sh generate

# Preview man page
.PHONY: preview-man
preview-man:
	@echo "👀 Previewing man page..."
	@./man/manage-man.sh preview

# Install man page locally
.PHONY: install-man
install-man:
	@echo "📥 Installing man page locally..."
	@./man/manage-man.sh install-local

# Development workflow: clean, build, and run
.PHONY: dev
dev: clean build run
	@echo "✅ Development workflow complete"

# GoReleaser targets
.PHONY: goreleaser-check
goreleaser-check:
	@echo "🔍 Checking GoReleaser configuration..."
	@go tool goreleaser check || echo "⚠️  goreleaser not found"

.PHONY: goreleaser-test
goreleaser-test:
	@echo "🧪 Running comprehensive GoReleaser test suite..."
	@./scripts/test-goreleaser.sh

# Changelog generation targets
.PHONY: changelog
changelog:
	@echo "📝 Generating changelog..."
	@TAG=$$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.1.0") && \
		NEXT_TAG=$$(echo $$TAG | sed 's/v//') && \
		NEXT_TAG="v$$(echo $$NEXT_TAG | awk -F. '{$$NF = $$NF + 1;} 1' | sed 's/ /./g')" && \
		echo "📋 Generating for tag: $$NEXT_TAG" && \
		go tool git-chglog --next-tag "$$NEXT_TAG" --output CHANGELOG.md && \
		echo "✅ CHANGELOG.md updated"

.PHONY: changelog-preview
changelog-preview:
	@echo "📝 Previewing changelog..."
	@TAG=$$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.1.0") && \
		NEXT_TAG=$$(echo $$TAG | sed 's/v//') && \
		NEXT_TAG="v$$(echo $$NEXT_TAG | awk -F. '{$$NF = $$NF + 1;} 1' | sed 's/ /./g')" && \
		echo "📋 Preview for tag: $$NEXT_TAG" && \
		go tool git-chglog --next-tag "$$NEXT_TAG"

# Pre-commit hook simulation
.PHONY: pre-commit
pre-commit: fmt lint test
	@echo "✅ Pre-commit checks passed"

# CI/CD targets
.PHONY: ci
ci: deps lint test build
	@echo "✅ CI pipeline completed successfully"

# Full CI with coverage
.PHONY: ci-full
ci-full: deps lint test-coverage build-all
	@echo "✅ Full CI pipeline completed successfully"

# Show build information
.PHONY: info
info:
	@echo "📋 Build Information:"
	@echo "   App Name:    $(APP_NAME)"
	@echo "   Version:     $(VERSION)"
	@echo "   Commit:      $(COMMIT)"
	@echo "   Build Time:  $(BUILD_TIME)"
	@echo "   Go Module:   $(GO_MODULE)"
	@echo "   Build Dir:   $(BUILD_DIR)"
	@echo "   Dist Dir:    $(DIST_DIR)"

# Show help
.PHONY: help
help:
	@echo "🔨 Emojify Build System"
	@echo ""
	@echo "Available targets:"
	@echo ""
	@echo "📦 Build targets:"
	@echo "  build        Build the application for current platform"
	@echo "  build-dev    Build with debug information"
	@echo "  build-all    Build for multiple platforms"
	@echo "  release      Build optimized release binary"
	@echo "  release-ultra Build ultra-compressed binary (requires UPX)"
	@echo "  clean        Remove build artifacts"
	@echo ""
	@echo "🚀 Run targets:"
	@echo "  run          Build and run the application"
	@echo "  run-dev      Run in development mode (go run)"
	@echo "  run-example  Run with example emoji text"
	@echo "  install      Install to system ($(INSTALL_DIR))"
	@echo "  install-go   Install to GOPATH/bin"
	@echo "  uninstall    Remove from system"
	@echo ""
	@echo "🧪 Testing targets:"
	@echo "  test         Run tests"
	@echo "  test-verbose Run tests with verbose output"
	@echo "  test-coverage Run tests with coverage report"
	@echo "  test-race    Run tests with race detection"
	@echo "  test-unit    Run unit tests only"
	@echo "  test-integration Run integration tests only"
	@echo "  test-all     Run tests and benchmarks"
	@echo "  benchmark    Run benchmarks"
	@echo "  test-report  Generate test reports"
	@echo ""
	@echo "🔍 Code quality targets:"
	@echo "  lint         Run full linting (strict)"
	@echo "  lint-fix     Run linting with auto-fix"
	@echo "  lint-dev     Run essential linting only (for development)"
	@echo "  fmt          Format Go code with goimports"
	@echo "  fmt-basic    Format Go code (basic go fmt)"
	@echo "  vet          Run go vet"
	@echo "  vuln-check   Check for vulnerabilities"
	@echo ""
	@echo "📦 Dependency targets:"
	@echo "  deps         Download dependencies"
	@echo "  tidy         Tidy Go modules"
	@echo "  verify       Verify dependencies are clean"
	@echo "  dev-setup    Setup development environment"
	@echo ""
	@echo "🎯 CI/CD targets:"
	@echo "  ci           Basic CI pipeline (deps + lint + test + build)"
	@echo "  ci-full      Full CI pipeline with coverage and multi-platform builds"
	@echo "  pre-commit   Simulate pre-commit hooks"
	@echo ""
	@echo "📦 Release targets:"
	@echo "  goreleaser-check   Check GoReleaser configuration"
	@echo "  goreleaser-test    Run comprehensive GoReleaser test suite"
	@echo "  changelog          Generate CHANGELOG.md for next version"
	@echo "  changelog-preview  Preview changelog for next version"
	@echo ""
	@echo "🔄 Utility targets:"
	@echo "  update-emoji Update emoji data from GitHub"
	@echo "  dev          Development workflow (clean + build + run)"
	@echo "  info         Show build information"
	@echo "  size-comparison Compare binary sizes with different optimizations"
	@echo "  help         Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make ci              # Run CI pipeline"
	@echo "  make pre-commit      # Check before committing"
	@echo "  make dev             # Quick development cycle"
	@echo "  make release-ultra   # Build smallest possible binary"
	@echo "  make size-comparison # Compare optimization levels"

# Default help if no target specified
.DEFAULT_GOAL := help
