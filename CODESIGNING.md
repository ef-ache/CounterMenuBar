# Code Signing and Notarization Guide

## The Problem
Your app shows "Apple cannot verify it is free from malware" because it's not signed with an Apple Developer certificate.

## Solution Options

### Option 1: Free - For Open Source/Personal Use
Users can bypass the warning by:
1. Right-clicking the app and selecting "Open"
2. Or running: `xattr -cr /Applications/CounterMenuBar.app`

Add this to your README:
```markdown
## First Launch
On first launch, macOS may show a security warning. To open:
1. Right-click CounterMenuBar in Applications
2. Select "Open" 
3. Click "Open" in the dialog
```

### Option 2: Apple Developer Program ($99/year)
Get proper code signing and notarization:

#### 1. Join Apple Developer Program
- Sign up at https://developer.apple.com
- Cost: $99/year
- Provides Developer ID certificates

#### 2. Sign Your App in Xcode
```bash
# In Xcode project settings:
# - Signing & Capabilities tab
# - Check "Automatically manage signing"
# - Select your Developer ID team
# - Build with: Product → Archive
```

#### 3. Notarize Your App
```bash
# Export signed app from Xcode Organizer
# Then notarize:
xcrun notarytool submit CounterMenuBar-1.0.0.dmg \
  --apple-id "your-apple-id@email.com" \
  --team-id "YOUR_TEAM_ID" \
  --password "app-specific-password" \
  --wait

# Staple the ticket
xcrun stapler staple CounterMenuBar.app
xcrun stapler staple CounterMenuBar-1.0.0.dmg
```

#### 4. Update Your Homebrew Formula
After notarizing, update the SHA256 in your formula and push:
```bash
shasum -a 256 CounterMenuBar-1.0.0.dmg
# Update countermenubar.rb with new SHA256
git commit -am "Update to notarized version"
git push
```

### Option 3: Ad-hoc Signing (Free, Limited)
Sign without Developer ID (still shows warning but less scary):
```bash
# Sign the app locally
codesign --force --deep --sign - CounterMenuBar.app

# Create new DMG
./create_distribution.sh

# Update Homebrew formula with new SHA256
```

## Quick Fix for Current Installation

Run this command to remove the quarantine flag:
```bash
xattr -cr /Applications/CounterMenuBar.app
```

Or reinstall with --no-quarantine:
```bash
brew uninstall --cask countermenubar
brew install --cask --no-quarantine ef-ache/countermenubar/countermenubar
```

## Recommended Approach

1. **For now**: Add instructions to your README about right-clicking to open
2. **Long term**: If you plan to distribute widely, get an Apple Developer account
3. **Update Homebrew formula**: Add a caveat about first launch:

```ruby
caveats <<~EOS
  On first launch, right-click CounterMenuBar and select "Open" to bypass macOS security.
EOS
```