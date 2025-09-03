# Publishing Guide for CounterMenuBar

## Publishing Options

### Option 1: Direct Distribution (Easiest & Free)
Distribute the app directly to users without the Mac App Store.

**Steps:**
1. **Developer ID Certificate** (Required for notarization)
   - Join Apple Developer Program ($99/year) at https://developer.apple.com
   - Create a Developer ID Application certificate in your Apple Developer account

2. **Code Signing in Xcode**
   - Open `CounterMenuBar.xcodeproj` in Xcode
   - Select the project in navigator
   - Go to "Signing & Capabilities" tab
   - Enable "Automatically manage signing"
   - Select your Team (your Developer ID)
   - Bundle Identifier: Change to something unique like `com.yourname.CounterMenuBar`

3. **Archive and Export**
   - In Xcode: Product → Archive
   - In Organizer: Click "Distribute App"
   - Choose "Developer ID" → Next
   - Choose "Upload" (for notarization) or "Export" (for manual notarization)
   - Select your Developer ID certificate

4. **Notarization** (Required for macOS 10.15+)
   ```bash
   # If you exported manually, notarize via command line:
   xcrun altool --notarize-app \
     --primary-bundle-id "com.yourname.CounterMenuBar" \
     --username "your-apple-id@example.com" \
     --password "app-specific-password" \
     --file CounterMenuBar.app.zip
   
   # Check notarization status:
   xcrun altool --notarization-info <RequestUUID> \
     --username "your-apple-id@example.com" \
     --password "app-specific-password"
   
   # Once approved, staple the ticket:
   xcrun stapler staple CounterMenuBar.app
   ```

5. **Distribution**
   - Zip the notarized app: `zip -r CounterMenuBar.zip CounterMenuBar.app`
   - Host on GitHub Releases, your website, or file sharing service
   - Users download, unzip, and drag to Applications folder

### Option 2: Mac App Store
More complex but provides automatic updates and wider reach.

**Additional Requirements:**
- Mac App Store distribution certificate
- App Store provisioning profile
- App Store Connect account
- More restrictive entitlements
- App review process (can take 1-2 weeks)

**Steps:**
1. Configure for App Store in Xcode Signing & Capabilities
2. Remove any incompatible features (if any)
3. Create app in App Store Connect
4. Upload via Xcode Organizer
5. Submit for review

### Option 3: GitHub Release (For Developers)
Perfect for open-source distribution without notarization.

**Steps:**
1. **Create GitHub Repository**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/yourusername/CounterMenuBar.git
   git push -u origin main
   ```

2. **Build Release Version**
   - In Xcode: Product → Archive
   - Export without code signing (for developer use)

3. **Create Release**
   - Go to GitHub repo → Releases → "Create a new release"
   - Tag version (e.g., v1.0.0)
   - Upload the .app (zipped) or .dmg file
   - Add release notes

**Note:** Users will need to right-click → Open to bypass Gatekeeper

### Option 4: Homebrew Cask (Advanced)
For technical users who prefer command-line installation.

**Steps:**
1. Create a formula file
2. Submit PR to homebrew-cask repository
3. Users install via: `brew install --cask countermenubar`

## Pre-Publishing Checklist

- [ ] **App Icon**: Add a proper app icon in Assets.xcassets
- [ ] **Version Number**: Update CFBundleShortVersionString in Info.plist
- [ ] **Bundle ID**: Set unique identifier (com.yourname.CounterMenuBar)
- [ ] **Testing**: Test on multiple macOS versions
- [ ] **Credits**: Update copyright information
- [ ] **README**: Create user documentation
- [ ] **Privacy**: Ensure no personal data in code (remove hardcoded emails)

## Creating a DMG Installer (Optional)

For a professional distribution:

```bash
# Create a folder for DMG contents
mkdir -p CounterMenuBar-Installer
cp -R CounterMenuBar.app CounterMenuBar-Installer/
ln -s /Applications CounterMenuBar-Installer/Applications

# Create DMG
hdiutil create -volname "CounterMenuBar" \
  -srcfolder CounterMenuBar-Installer \
  -ov -format UDZO CounterMenuBar.dmg

# Clean up
rm -rf CounterMenuBar-Installer
```

## Cost Summary

- **Free Options**: GitHub Release, direct distribution (unsigned)
- **$99/year**: Apple Developer Program (required for notarization and App Store)
- **No additional costs**: Once you have Developer account

## Recommended Path for First-Time Publishers

1. Start with **GitHub Release** for initial testing and feedback
2. Once stable, get Apple Developer account for **Direct Distribution** with notarization
3. Consider **Mac App Store** if you want wider reach and automatic updates

## Important Notes

- **Notarization** is effectively required for apps distributed outside the App Store on macOS 10.15+
- **Code signing** prevents "unidentified developer" warnings
- The app currently has no analytics or crash reporting - consider adding these before wide distribution
- Test thoroughly on different macOS versions (minimum is set in project settings)