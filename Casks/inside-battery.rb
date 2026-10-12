cask "inside-battery" do
  version "0.2.7"
  sha256 "a472bd327db825cf57cf4019fd3611da7a024171451757f77cb9a1b8c6d96d5b"

  url "https://github.com/JonathanLee2020/inside-battery/releases/download/v0.2.7/InsideBattery-0.2.7-arm64.zip"
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
