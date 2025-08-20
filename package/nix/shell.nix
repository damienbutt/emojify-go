{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    go_1_22
    golangci-lint
    goreleaser
    git
    gnumake
  ];

  shellHook = ''
    echo "🚀 emojify-go development environment"
    echo "Go version: $(go version)"
    echo ""
    echo "Available commands:"
    echo "  make build      - Build the binary"
    echo "  make test       - Run tests"
    echo "  make lint       - Run linters"
    echo "  make release    - Create release (requires env vars)"
    echo ""
  '';
}
