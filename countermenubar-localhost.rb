cask "countermenubar" do
  version "1.0.0"
  sha256 "1fa4c626cdd5f590d834c8bbbbd9aeb89dba696f0bee4bd0665b9da341a86ca6"

  url "http://localhost:8000/CounterMenuBar-#{version}.dmg"
  name "CounterMenuBar"
  desc "Simple menu bar counter app with email generation"
  homepage "https://github.com/ef-ache/CounterMenuBar"

  auto_updates false
  depends_on macos: ">= :big_sur"

  app "CounterMenuBar.app"

  uninstall quit: "com.yourname.CounterMenuBar"

  zap trash: [
    "~/Library/Preferences/com.yourname.CounterMenuBar.plist",
    "~/Library/Application Support/CounterMenuBar",
  ]
end

