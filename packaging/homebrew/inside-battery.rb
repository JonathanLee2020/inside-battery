cask "inside-battery" do
  version "0.1.0"
  sha256 "REPLACE_WITH_RELEASE_SHA256"

  url "https://github.com/REPLACE_WITH_OWNER/inside-battery/releases/download/v#{version}/InsideBattery-#{version}.zip"
  name "Inside Battery"
  desc "Battery percentage drawn inside a native macOS menu-bar icon"
  homepage "https://github.com/REPLACE_WITH_OWNER/inside-battery"

  depends_on macos: ">= :ventura"

  app "Inside Battery.app"

  zap trash: [
    "~/Library/Preferences/com.insidebattery.app.plist",
  ]
end
