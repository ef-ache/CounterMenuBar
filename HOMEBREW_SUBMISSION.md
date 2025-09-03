# Homebrew Cask Submission Guide for CounterMenuBar

## Prerequisites

Before submitting to Homebrew Cask, you need:
1. ✅ A GitHub repository for your app
2. ✅ A stable release with signed/notarized app (recommended)
3. ✅ A permanent download URL (GitHub Releases work well)

## Step-by-Step Instructions

### 1. Prepare Your App for Release

#### Build and Export in Xcode:
1. Open `CounterMenuBar.xcodeproj` in Xcode
2. Update version number in Info.plist if needed
3. Product → Archive
4. In Organizer window, click "Distribute App"
5. Choose "Copy App" (or "Developer ID" if you have signing certificate)
6. Export the app to this directory

#### Create Distribution Archive:
```bash
# Run the distribution script
./create_distribution.sh
```

This will create:
- `CounterMenuBar-1.0.0.zip` 
- `CounterMenuBar-1.0.0.dmg` (preferred for Homebrew)
- SHA256 checksums for both

### 2. Create GitHub Release

1. Push your code to GitHub:
```bash
git add .
git commit -m "Prepare for v1.0.0 release"
git push origin main
```

2. Create a new release on GitHub:
```bash
# Create a git tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

3. Go to https://github.com/YOUR_USERNAME/CounterMenuBar/releases
4. Click "Create a new release"
5. Choose the tag `v1.0.0`
6. Upload `CounterMenuBar-1.0.0.dmg`
7. Add release notes describing the app
8. Publish the release

### 3. Update Homebrew Formula

Edit `countermenubar.rb` with your actual values:
- Replace `YOUR_USERNAME` with your GitHub username
- Replace `REPLACE_WITH_DMG_SHA256` with the SHA256 from step 1
- Update `com.yourname.CounterMenuBar` with your actual bundle ID

### 4. Test Your Formula Locally

```bash
# Install homebrew-cask if not already installed
brew tap homebrew/cask

# Test your formula locally
brew install --cask ./countermenubar.rb

# Verify it works
open /Applications/CounterMenuBar.app

# Audit the formula for issues
brew audit --cask ./countermenubar.rb

# Uninstall after testing
brew uninstall --cask countermenubar
```

### 5. Submit to Homebrew Cask

#### Fork and Clone:
```bash
# Fork homebrew-cask on GitHub first
git clone https://github.com/YOUR_USERNAME/homebrew-cask.git
cd homebrew-cask
git remote add upstream https://github.com/Homebrew/homebrew-cask.git
```

#### Create Your Cask:
```bash
# Create a new branch
git checkout -b add-countermenubar

# Copy your formula
cp ../countermenubar.rb Casks/c/countermenubar.rb

# Commit
git add Casks/c/countermenubar.rb
git commit -m "Add CounterMenuBar v1.0.0"

# Push to your fork
git push origin add-countermenubar
```

#### Submit Pull Request:
1. Go to https://github.com/YOUR_USERNAME/homebrew-cask
2. Click "Pull requests" → "New pull request"
3. Ensure it's merging to `Homebrew/homebrew-cask:master`
4. Title: "Add CounterMenuBar v1.0.0"
5. Description should include:
   - What the app does
   - Link to homepage
   - Confirmation you've tested locally
   - Any relevant notes

### 6. After Submission

The Homebrew maintainers will:
- Review your submission
- Run automated tests
- Provide feedback if changes are needed
- Merge if everything looks good

Once merged, users can install with:
```bash
brew install --cask countermenubar
```

## Important Notes

### For Unsigned Apps
If your app isn't notarized, it might be rejected. Consider:
- Getting an Apple Developer account ($99/year)
- Code signing and notarizing your app
- Or clearly noting in the PR that it's an open-source tool

### Formula Requirements
- App must be stable (no beta/pre-release versions)
- Download URL must be permanent
- App should be useful to others (not personal tools)
- Must follow Homebrew's acceptable cask criteria

### Updating Your App
After your cask is accepted, to update versions:
1. Create new release on GitHub
2. Submit PR updating version and SHA256 in the formula
3. Use `brew bump-cask-pr` tool for easier updates

## Alternative: Personal Tap

If your app doesn't meet Homebrew Cask requirements or for faster iteration:

```bash
# Create your own tap
mkdir -p homebrew-tap/Casks
cp countermenubar.rb homebrew-tap/Casks/

# Push to GitHub as homebrew-tap repository
# Users can then install with:
brew tap YOUR_USERNAME/tap
brew install --cask YOUR_USERNAME/tap/countermenubar
```

## Troubleshooting

### Common Issues:
1. **"unidentified developer"**: App needs notarization
2. **SHA256 mismatch**: Regenerate and update formula
3. **Audit failures**: Run `brew audit --cask` and fix issues
4. **URL not reachable**: Ensure GitHub release is public

### Getting Help:
- Homebrew Discourse: https://discourse.brew.sh
- Homebrew Cask Documentation: https://docs.brew.sh/Cask-Cookbook
- Example Casks: https://github.com/Homebrew/homebrew-cask/tree/master/Casks

## Checklist Before Submission

- [ ] App is built and exported from Xcode
- [ ] DMG created with `create_distribution.sh`
- [ ] GitHub repository is public
- [ ] Release created on GitHub with DMG attached
- [ ] Formula updated with correct SHA256 and URLs
- [ ] Tested installation locally with brew
- [ ] Formula passes `brew audit --cask`
- [ ] Bundle ID and app name are consistent