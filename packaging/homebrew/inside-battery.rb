cask "inside-battery" do
  version "0.2.5"
  sha256 "a805d49b5f01792ca9651f62110aea7f470cc401712dc8f9fa885aba32d6e19c"

  url "https://github.com/JonathanLee2020/inside-battery/releases/download/v0.2.5/InsideBattery-0.2.5-arm64.zip"
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
