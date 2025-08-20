{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "emojify-go";
  version = "0.0.0"; # This will be replaced by GoReleaser

  src = fetchFromGitHub {
    owner = "damienbutt";
    repo = "emojify-go";
    rev = "v${version}";
    hash = ""; # This will be filled by GoReleaser
  };

  vendorHash = null; # Use vendorHash = null for pure Go modules or calculate specific hash

  ldflags = [
    "-s"
    "-w"
    "-X github.com/damienbutt/emojify-go/internal/version.Version=${version}"
  ];

  subPackages = [ "cmd/emojify" ];

  # Tests require network access for integration tests
  doCheck = false;

  meta = with lib; {
    description = "Lightning-fast Go rewrite of emojify - convert emoji aliases to Unicode emojis";
    longDescription = ''
      emojify-go is a lightning-fast Go rewrite of the popular emojify tool.
      It converts emoji aliases (like :smile:) to their Unicode emoji equivalents.
      Perfect for processing Markdown files, commit messages, or any text containing emoji aliases.
    '';
    homepage = "https://github.com/damienbutt/emojify-go";
    changelog = "https://github.com/damienbutt/emojify-go/blob/main/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ]; # Add your nixpkgs maintainer handle here
    mainProgram = "emojify";
    platforms = platforms.unix;
  };
}
