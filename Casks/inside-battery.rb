cask "inside-battery" do
  version "0.2.8"
  sha256 "6a1131e65682fcb8b9089b9a35427618e4ff9eec7a233abf756fcd3063d4abae"

  url "https://github.com/JonathanLee2020/inside-battery/releases/download/v0.2.8/InsideBattery-0.2.8-arm64.zip"
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
