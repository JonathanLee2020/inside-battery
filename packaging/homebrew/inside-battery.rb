cask "inside-battery" do
  version "0.2.10"
  sha256 "733cdb3b5040352c0063e8619cd68464cd308869ef8ca8617b1cbd55eaac8155"

  url "https://github.com/JonathanLee2020/inside-battery/releases/download/v0.2.10/InsideBattery-0.2.10-arm64.zip"
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
