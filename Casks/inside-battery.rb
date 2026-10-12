cask "inside-battery" do
  version "0.2.6"
  sha256 "3e8f8a92b038f4a7cb6d9530ebcf9b7c40866d106de9d15841b30313b95445a8"

  url "https://github.com/JonathanLee2020/inside-battery/releases/download/v0.2.6/InsideBattery-0.2.6-arm64.zip"
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
