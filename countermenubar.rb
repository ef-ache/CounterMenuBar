cask "countermenubar" do
  version "1.0.0"
  sha256 "c2f758e4f0285141a6ea59e6d1c3c046ef16e01fcb7ece5c1bece8e993addb1c" # Replace with actual SHA256 from create_distribution.sh

  url "https://github.com/ef-ache/CounterMenuBar/releases/download/v#{version}/CounterMenuBar-#{version}.dmg"
  name "CounterMenuBar"
  desc "Simple menu bar counter app with email generation"
  homepage "https://github.com/ef-ache/CounterMenuBar"

  auto_updates false
  depends_on macos: ">= :big_sur" # Adjust based on your minimum macOS version

  app "CounterMenuBar.app"

  uninstall quit: "com.yourname.CounterMenuBar" # Replace with your bundle ID

  zap trash: [
    "~/Library/Preferences/com.yourname.CounterMenuBar.plist",
    "~/Library/Application Support/CounterMenuBar",
  ]
end
