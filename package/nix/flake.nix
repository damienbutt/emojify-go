{
  description = "Lightning-fast Go rewrite of emojify - convert emoji aliases to Unicode emojis";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.buildGoModule {
          pname = "emojify-go";
          version = "0.0.0-dev";

          src = ./.;

          vendorHash = null; # Use vendorHash = null for pure Go modules or calculate specific hash

          ldflags = [
            "-s"
            "-w"
            "-X github.com/damienbutt/emojify-go/internal/version.Version=dev"
            "-X github.com/damienbutt/emojify-go/internal/version.Commit=dev"
            "-X github.com/damienbutt/emojify-go/internal/version.Date=1970-01-01T00:00:00Z"
          ];

          subPackages = [ "cmd/emojify" ];

          # Tests require network access for integration tests
          doCheck = false;

          meta = with pkgs.lib; {
            description = "Lightning-fast Go rewrite of emojify - convert emoji aliases to Unicode emojis";
            homepage = "https://github.com/damienbutt/emojify-go";
            license = licenses.mit;
            maintainers = [ maintainers.damienbutt ];
            mainProgram = "emojify";
          };
        };

        packages.emojify-go = self.packages.${system}.default;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go_1_22
            golangci-lint
            goreleaser
            git
            gnumake
          ];

          shellHook = ''
            echo "emojify-go development environment"
            echo "Go version: $(go version)"
          '';
        };

        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
          name = "emojify";
        };

        apps.emojify = self.apps.${system}.default;
      });
}
