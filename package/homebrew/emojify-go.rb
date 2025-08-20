class EmojifyGo < Formula
  desc "Lightning-fast Go rewrite of emojify - convert emoji aliases to Unicode emojis"
  homepage "https://github.com/damienbutt/emojify-go"
  url "https://github.com/damienbutt/emojify-go/releases/download/v0.0.0/emojify-go_0.0.0_darwin_amd64.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"
  version "0.0.0"

  # Dependencies
  depends_on "git" => :optional

  # Version support
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  def install
    bin.install "emojify"

    # Install man page if available
    if File.exist?("emojify.1")
      man1.install "emojify.1"
    end

    # Install shell completions if available
    if File.exist?("emojify.bash")
      bash_completion.install "emojify.bash" => "emojify"
    end

    if File.exist?("emojify.fish")
      fish_completion.install "emojify.fish"
    end

    if File.exist?("_emojify")
      zsh_completion.install "_emojify"
    end
  end

  test do
    # Test version output
    assert_match version.to_s, shell_output("#{bin}/emojify --version")

    # Test basic functionality
    output = shell_output("echo 'Hello :grin: world' | #{bin}/emojify")
    assert_match "Hello 😁 world", output

    # Test encoding mode
    output = shell_output("echo 'Hello 😁 world' | #{bin}/emojify --decode")
    assert_match "Hello :grin: world", output

    # Test help output
    help_output = shell_output("#{bin}/emojify --help")
    assert_match "emojify", help_output.downcase
    assert_match "emoji", help_output.downcase
  end
end
