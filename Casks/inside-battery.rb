cask "inside-battery" do
  version "0.2.4"
  sha256 "595bb25bad99d449c61bbf7e171bbe9352fd8663ef91cd45c54fc16e2eb1f62d"

  url "https://github.com/JonathanLee2020/inside-battery/releases/download/v0.2.4/InsideBattery-0.2.4-arm64.zip"
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
