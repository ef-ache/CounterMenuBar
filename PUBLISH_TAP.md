# Publishing Your Homebrew Tap

Your Homebrew tap is ready! Follow these steps to publish it:

## 1. Create a new GitHub repository

Go to https://github.com/new and create a new repository named `homebrew-countermenubar`

**Important:** The repository name MUST start with `homebrew-` for Homebrew to recognize it as a tap.

## 2. Push your tap to GitHub

```bash
cd homebrew-countermenubar
git remote add origin https://github.com/ef-ache/homebrew-countermenubar.git
git branch -M main
git push -u origin main
```

## 3. Test the installation

Once pushed, users can install your app with:

```bash
# Add your tap
brew tap ef-ache/countermenubar

# Install the app
brew install --cask ef-ache/countermenubar/countermenubar
```

Or in a single command:
```bash
brew install --cask ef-ache/countermenubar/countermenubar
```

## Alternative: Quick Setup

If you prefer a simpler approach without a separate tap:

1. Users can install directly from your main repo's formula:
```bash
brew install --cask https://raw.githubusercontent.com/ef-ache/CounterMenuBar/main/countermenubar.rb
```

But having a dedicated tap is more professional and easier for users.

## Verification

After pushing to GitHub, verify it works:
```bash
# Remove local tap if it exists
brew untap ef-ache/countermenubar 2>/dev/null || true

# Install fresh from GitHub
brew install --cask ef-ache/countermenubar/countermenubar
```

## Updating Your App

When you release a new version:
1. Update the version and sha256 in `Casks/countermenubar.rb`
2. Commit and push to the tap repository
3. Users can update with: `brew upgrade --cask countermenubar`