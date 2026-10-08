cask "inside-battery" do
  version "0.2.2"
  sha256 "c40ea1c8905973172a5c51ab7f58c26861ab491c19b703419f79af567750dcad"

  url "https://github.com/JonathanLee2020/inside-battery/releases/download/v0.2.2/InsideBattery-0.2.2-arm64.zip"
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
