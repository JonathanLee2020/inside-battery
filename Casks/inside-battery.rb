cask "inside-battery" do
  version "0.2.3"
  sha256 "dcb147b30eca979996ec2768dac00f2943995d31cfea69dff610a3e00cccca53"

  url "https://github.com/JonathanLee2020/inside-battery/releases/download/v0.2.3/InsideBattery-0.2.3-arm64.zip"
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
