cask "inside-battery" do
  version "0.2.0"
  sha256 "43e560904c309f8cbd52781ed5f4b0ff6a9782413e1be634d06f4781b3fc36dd"

  url "https://github.com/JonathanLee2020/inside-battery/releases/download/v0.2.0/InsideBattery-0.2.0-arm64.zip"
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
