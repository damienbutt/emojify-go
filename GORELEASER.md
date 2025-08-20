# GoReleaser Configuration Comparison

## `.goreleaser.yml` (Production)

**Purpose**: Full production release configuration

-   Publishes to external repositories (homebrew-tap, scoop buckets, etc.)
-   Uploads Docker images to registries
-   Creates GitHub releases
-   Sends notifications
-   Requires authentication tokens
-   Used by CI/CD for actual releases

## `.goreleaser-local.yml` (Testing)

**Purpose**: Local development and testing only

-   Generates package manifests locally in `package/` directory
-   No external uploads (`skip_upload: true`)
-   No authentication required
-   Simplified configuration for testing
-   Used for validating manifest generation before release

## Use Cases

### Production Release (`.goreleaser.yml`)

```bash
# In CI/CD or for actual releases
goreleaser release --clean
```

### Local Testing (`.goreleaser-local.yml`)

```bash
# Test package manifest generation
goreleaser release --config .goreleaser-local.yml --snapshot --clean --skip=publish

# Or use the Makefile target
make test-local-release
```

## Why Both?

1. **Separation of Concerns**: Production config is complex with external integrations
2. **Safe Testing**: Local config can't accidentally publish releases
3. **Development Speed**: Faster iteration without external dependencies
4. **Validation**: Test manifest generation before actual release
5. **No Credentials**: Local testing doesn't require GitHub tokens or publishing permissions

The local config is essentially a "dry run" version that generates the same artifacts but keeps them local for inspection and testing.
