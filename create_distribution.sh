#!/bin/bash

# Script to create distribution archive for Homebrew Cask
# Run this after building the app in Xcode (Product → Archive → Export)

APP_NAME="CounterMenuBar"
VERSION="1.0.0"  # Update this with your version

echo "Creating distribution for $APP_NAME v$VERSION"

# Check if app exists
if [ ! -d "$APP_NAME.app" ]; then
    echo "Error: $APP_NAME.app not found!"
    echo "Please:"
    echo "1. Open CounterMenuBar.xcodeproj in Xcode"
    echo "2. Product → Archive"
    echo "3. In Organizer, click 'Distribute App'"
    echo "4. Choose 'Copy App' and export to this directory"
    echo "5. Run this script again"
    exit 1
fi

# Create a zip archive
echo "Creating zip archive..."
zip -r "$APP_NAME-$VERSION.zip" "$APP_NAME.app"

# Generate SHA256
echo "Generating SHA256 checksum..."
SHA256=$(shasum -a 256 "$APP_NAME-$VERSION.zip" | awk '{print $1}')
echo "SHA256: $SHA256"

# Create DMG (optional, but preferred for Homebrew Cask)
echo "Creating DMG..."
mkdir -p "$APP_NAME-dmg"
cp -R "$APP_NAME.app" "$APP_NAME-dmg/"
ln -s /Applications "$APP_NAME-dmg/Applications"

hdiutil create -volname "$APP_NAME" \
  -srcfolder "$APP_NAME-dmg" \
  -ov -format UDZO "$APP_NAME-$VERSION.dmg"

rm -rf "$APP_NAME-dmg"

# Generate SHA256 for DMG
DMG_SHA256=$(shasum -a 256 "$APP_NAME-$VERSION.dmg" | awk '{print $1}')
echo "DMG SHA256: $DMG_SHA256"

echo ""
echo "Distribution files created:"
echo "  - $APP_NAME-$VERSION.zip (SHA256: $SHA256)"
echo "  - $APP_NAME-$VERSION.dmg (SHA256: $DMG_SHA256)"
echo ""
echo "Next steps:"
echo "1. Upload these files to a GitHub Release"
echo "2. Use the DMG SHA256 in the Homebrew Cask formula"