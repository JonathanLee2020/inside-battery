cask "inside-battery" do
  version "0.2.1"
  sha256 "e9d0b3147a8976c87bce83cc89cf079fbe59c8c0af18b6234d83f5076460d84a"

  url "https://github.com/JonathanLee2020/inside-battery/releases/download/v0.2.1/InsideBattery-0.2.1-arm64.zip"
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
