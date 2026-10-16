cask "inside-battery" do
  version "0.2.11"
  sha256 "f0ac96501cd352baad932b04c04e55795183e89f57c6f88fb4f389221e6213bb"

  url "https://github.com/JonathanLee2020/inside-battery/releases/download/v0.2.11/InsideBattery-0.2.11-arm64.zip"
  name "Inside Battery"
  desc "Battery percentage inside a native macOS menu-bar icon"
  homepage "https://github.com/JonathanLee2020/inside-battery"

  depends_on arch: :arm64
  depends_on macos: :ventura
  app "Inside Battery.app"

  caveats do
    <<~EOS
      This is a development preview unless the release is marked notarized.
      Power-helper approval and fresh-install switching need verification.
      This cask does not grant administrator approval or bypass Gatekeeper.
    EOS
  end
end
