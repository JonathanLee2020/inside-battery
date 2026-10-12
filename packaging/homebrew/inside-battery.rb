cask "inside-battery" do
  version "0.2.9"
  sha256 "c9cb1602b5bd19f20e004fb89c7f4004fc042fbd93c4cc22f8a7a073ba4941e2"

  url "https://github.com/JonathanLee2020/inside-battery/releases/download/v0.2.9/InsideBattery-0.2.9-arm64.zip"
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
