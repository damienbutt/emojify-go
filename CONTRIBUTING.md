# Contributing to Emojify

Thank you for your interest in contributing to Emojify! This document provides guidelines and information for contributors.

## Development Setup

### Prerequisites

- Go 1.23 or later
- Git
- Make (optional, for convenience)

### Setting Up the Development Environment

1. Fork the repository on GitHub
2. Clone your fork:

   ```bash
   git clone https://github.com/yourusername/emojify.git
   cd emojify
   ```

3. Install dependencies:

   ```bash
   go mod download
   ```

4. Build the project:

   ```bash
   go build -o emojify ./cmd/emojify
   ```

5. Run tests:
   ```bash
   go test ./...
   ```

## Development Workflow

### Making Changes

1. Create a new branch for your feature or bugfix:

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following our coding standards
3. Add or update tests as necessary
4. Ensure all tests pass:

   ```bash
   go test ./...
   ```

5. Run benchmarks to ensure performance:
   ```bash
   go test -bench=. ./...
   ```

### Code Style

- Follow standard Go formatting (`gofmt`)
- Use `golangci-lint` for linting
- Write clear, descriptive commit messages
- Add comments for complex logic
- Keep functions focused and small

### Testing

- Write unit tests for new functionality
- Maintain or improve test coverage
- Include benchmarks for performance-critical code
- Test edge cases and error conditions

### Performance Considerations

Emojify is designed to be fast and efficient. When contributing:

- Profile your changes if they affect performance
- Use benchmarks to validate performance improvements
- Consider memory allocation patterns
- Test with large inputs

## Submitting Changes

### Pull Request Process

1. Push your changes to your fork:

   ```bash
   git push origin feature/your-feature-name
   ```

2. Create a pull request on GitHub
3. Fill out the pull request template
4. Ensure CI checks pass
5. Respond to review feedback

### Pull Request Guidelines

- Include a clear description of the changes
- Reference any related issues
- Keep pull requests focused and atomic
- Update documentation if necessary
- Add tests for new functionality

## Coding Standards

### Go Style Guide

Follow the [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments) and:

- Use meaningful variable and function names
- Keep line length reasonable (100-120 characters)
- Group imports logically
- Use interfaces for abstraction
- Handle errors appropriately

### Project Structure

```
emojify/
├── cmd/emojify/          # Main application entry point
├── internal/             # Private application packages
│   ├── emojify/         # Core emoji processing logic
│   ├── emoji/           # Emoji mappings and data
│   └── version/         # Version information
├── test/                # Test utilities and data
├── .goreleaser.yaml     # Release configuration
├── .github/workflows/   # CI/CD pipelines
└── README.md
```

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
type(scope): description

feat(cli): add --count flag to show emoji statistics
fix(processor): handle edge case with consecutive emojis
docs(readme): update installation instructions
test(emoji): add tests for Unicode edge cases
```

Types: `feat`, `fix`, `docs`, `test`, `refactor`, `style`, `chore`

## Adding New Features

### Emoji Mappings

When adding new emoji mappings:

1. Update `internal/emoji/mappings.go`
2. Ensure the mapping follows existing patterns
3. Add comprehensive tests
4. Verify Unicode compatibility
5. Update documentation if needed

### CLI Features

For new command-line features:

1. Update the CLI definition in `cmd/emojify/main.go`
2. Add processing logic in `internal/emojify/`
3. Include help text and examples
4. Add integration tests
5. Update the README

### Performance Optimizations

When optimizing performance:

1. Profile before and after changes
2. Include benchmarks in your tests
3. Document the optimization rationale
4. Ensure correctness is maintained
5. Consider memory vs. speed tradeoffs

## Testing

### Running Tests

```bash
# Run all tests
go test ./...

# Run tests with coverage
go test -cover ./...

# Run benchmarks
go test -bench=. ./...

# Run specific test
go test -run TestSpecificFunction ./...
```

### Test Categories

- **Unit Tests**: Test individual functions and methods
- **Integration Tests**: Test component interactions
- **Benchmark Tests**: Measure performance
- **Edge Case Tests**: Test boundary conditions

### Writing Tests

Use the testify framework for assertions:

```go
func TestEmojiReplacement(t *testing.T) {
    processor := emojify.NewProcessor()
    result := processor.Process("Hello :grin:")
    assert.Equal(t, "Hello 😁", result)
}
```

## Documentation

### Code Documentation

- Add godoc comments for public functions
- Include examples in documentation
- Document complex algorithms
- Explain performance characteristics

### User Documentation

- Update README for new features
- Include usage examples
- Document configuration options
- Maintain changelog

## Release Process

Releases are automated through GitHub Actions and GoReleaser:

1. Create a new tag: `git tag v1.x.x`
2. Push the tag: `git push origin v1.x.x`
3. GitHub Actions will build and release automatically
4. Update release notes on GitHub

## Getting Help

- Open an issue for bugs or feature requests
- Use discussions for questions
- Check existing issues before creating new ones
- Be respectful and constructive in communications

## Recognition

Contributors will be acknowledged in:

- CONTRIBUTORS.md file
- Release notes
- GitHub contributors graph

Thank you for contributing to Emojify! 🎉
