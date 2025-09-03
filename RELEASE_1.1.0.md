# Release v1.1.0 Instructions

## What's New
- **Added counter persistence**: Counter value now persists across app restarts using UserDefaults
- Counter automatically saves when changed
- Counter automatically loads on app startup

## Build Instructions
1. Open Xcode:
   ```
   open CounterMenuBar.xcodeproj
   ```

2. Build and Archive:
   - Select Product → Archive from menu
   - Wait for build to complete
   - In Organizer, click "Distribute App"
   - Choose "Copy App" 
   - Select "Export" and save to this directory (replacing the existing CounterMenuBar.app)

3. Create distribution files:
   ```
   ./create_distribution.sh
   ```

## Create GitHub Release
After building, run these commands:

```bash
# Create and push a tag
git tag -a v1.1.0 -m "Release v1.1.0 - Add counter persistence"
git push origin v1.1.0

# Create GitHub release with the DMG file
gh release create v1.1.0 \
  CounterMenuBar-1.1.0.dmg \
  --title "v1.1.0 - Counter Persistence" \
  --notes "## What's New
- Counter value now persists across app restarts
- Automatically saves counter state to UserDefaults
- Restores counter value on app launch

## Installation
Download the DMG file and drag CounterMenuBar to your Applications folder."
```

## Update Homebrew Formula
The SHA256 will be displayed after running create_distribution.sh. Update the Homebrew formula with the new version and SHA256.