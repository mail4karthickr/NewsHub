# NewsHub Deep Link Launch Guide

This guide explains how to launch the NewsHub app with deep links using command-line arguments.

## Table of Contents

- [Overview](#overview)
- [Methods](#methods)
  - [Method 1: Using the Launch Script (Recommended)](#method-1-using-the-launch-script-recommended)
  - [Method 2: Manual xcodebuild + simctl](#method-2-manual-xcodebuild--simctl)
  - [Method 3: Xcode Scheme Arguments](#method-3-xcode-scheme-arguments)
  - [Method 4: Runtime Deep Link (Existing App)](#method-4-runtime-deep-link-existing-app)
- [Supported Deep Links](#supported-deep-links)
- [Troubleshooting](#troubleshooting)

---

## Overview

NewsHub supports deep linking via the `newshub://` URL scheme. You can launch the app with a specific tab pre-selected using:

1. **Launch Arguments** - Pass deep link URL when launching the app
2. **Runtime URL** - Send deep link to already running app

The app reads the `-DeepLinkURL` launch argument and automatically navigates to the specified tab.

---

## Methods

### Method 1: Using the Launch Script (Recommended)

The easiest way to launch the app with a deep link is using the provided script.

#### Setup (One-time)

```bash
chmod +x launch-with-deeplink.sh
```

#### Usage

```bash
# Basic usage - launch with deep link
./launch-with-deeplink.sh newshub://search

# Specify a different simulator
./launch-with-deeplink.sh --simulator "iPhone 15 Pro" newshub://profile

# See all options
./launch-with-deeplink.sh --help
```

#### What the script does

1. ✓ Finds and boots the specified simulator
2. ✓ Builds the NewsHub app
3. ✓ Installs the app on the simulator
4. ✓ Launches with the deep link URL
5. ✓ App opens on the correct tab

#### Examples

```bash
# Open app on Home tab
./launch-with-deeplink.sh newshub://home

# Open app on Search tab
./launch-with-deeplink.sh newshub://search

# Open app on Bookmarks tab
./launch-with-deeplink.sh newshub://bookmarks

# Open app on Profile tab
./launch-with-deeplink.sh newshub://profile

# Use iPhone 15 Pro simulator
./launch-with-deeplink.sh --simulator "iPhone 15 Pro" newshub://search
```

---

### Method 2: Manual xcodebuild + simctl

For more control, you can manually run the commands.

#### Steps

1. **Boot the simulator**

```bash
# List available simulators
xcrun simctl list devices | grep iPhone

# Boot a specific simulator (replace with actual UDID)
xcrun simctl boot <SIMULATOR_UDID>

# Or boot by name
UDID=$(xcrun simctl list devices | grep "iPhone 16" | grep -v "unavailable" | head -1 | grep -oE '[0-9A-F-]{36}')
xcrun simctl boot $UDID
```

2. **Build the app**

```bash
xcodebuild -project NewsHub.xcodeproj \
    -scheme NewsHub \
    -destination "id=$UDID" \
    -derivedDataPath .build \
    build
```

3. **Install the app**

```bash
# Find the app bundle
APP_PATH=$(find .build/Build/Products/Debug-iphonesimulator -name "NewsHub.app" -maxdepth 1 | head -1)

# Install on simulator
xcrun simctl install $UDID "$APP_PATH"
```

4. **Launch with deep link**

```bash
# Launch with -DeepLinkURL argument
xcrun simctl launch $UDID com.karthickramasamy.NewsHub -DeepLinkURL "newshub://search"
```

#### Complete Example

```bash
# All in one
UDID=$(xcrun simctl list devices | grep "iPhone 16" | grep -v "unavailable" | head -1 | grep -oE '[0-9A-F-]{36}')
xcrun simctl boot $UDID
xcodebuild -project NewsHub.xcodeproj -scheme NewsHub -destination "id=$UDID" -derivedDataPath .build build
APP_PATH=$(find .build/Build/Products/Debug-iphonesimulator -name "NewsHub.app" -maxdepth 1 | head -1)
xcrun simctl install $UDID "$APP_PATH"
xcrun simctl launch $UDID com.karthickramasamy.NewsHub -DeepLinkURL "newshub://profile"
```

---

### Method 3: Xcode Scheme Arguments

You can configure Xcode to automatically pass launch arguments.

#### Steps

1. **Open Xcode** → Select **NewsHub** scheme
2. Click **Product** → **Scheme** → **Edit Scheme...**
3. Select **Run** → **Arguments** tab
4. Under **Arguments Passed On Launch**, click **+**
5. Add: `-DeepLinkURL newshub://search`
6. Click **Close**

Now when you build and run from Xcode, the app will launch with the deep link.

#### Multiple Configurations

Create different schemes for each tab:

- **NewsHub-Home**: `-DeepLinkURL newshub://home`
- **NewsHub-Search**: `-DeepLinkURL newshub://search`
- **NewsHub-Bookmarks**: `-DeepLinkURL newshub://bookmarks`
- **NewsHub-Profile**: `-DeepLinkURL newshub://profile`

To create a new scheme:

1. **Product** → **Scheme** → **Manage Schemes...**
2. Click **+** (duplicate existing scheme)
3. Rename it (e.g., "NewsHub-Search")
4. Edit the new scheme and set the launch arguments

---

### Method 4: Runtime Deep Link (Existing App)

If the app is already running, you can send a deep link without relaunching.

#### Usage

```bash
# Get simulator UDID (booted simulator)
UDID=$(xcrun simctl list devices | grep "Booted" | grep -oE '[0-9A-F-]{36}' | head -1)

# Send deep link to running app
xcrun simctl openurl $UDID "newshub://search"
```

This method is covered in detail in `DEEPLINK_GUIDE.md`.

---

## Supported Deep Links

| Deep Link URL | Tab | Alternative |
|--------------|-----|-------------|
| `newshub://home` | Home | - |
| `newshub://search` | Search | - |
| `newshub://bookmarks` | Bookmarks | `newshub://saved` |
| `newshub://profile` | Profile | `newshub://settings` |

### URL Format

```
newshub://<tab-name>
```

Where `<tab-name>` is one of:
- `home`
- `search`
- `bookmarks` (or `saved`)
- `profile` (or `settings`)

---

## Troubleshooting

### Issue: "Simulator not found"

**Solution**: Check available simulators

```bash
xcrun simctl list devices | grep iPhone
```

Use the exact simulator name or specify a different one:

```bash
./launch-with-deeplink.sh --simulator "iPhone 15 Pro" newshub://home
```

### Issue: "Build failed"

**Solution**: Build manually in Xcode first

```bash
# Open in Xcode and build (⌘B)
open NewsHub.xcodeproj

# Or use xcodebuild with verbose output
xcodebuild -project NewsHub.xcodeproj -scheme NewsHub -destination "generic/platform=iOS Simulator" build
```

### Issue: "App launches but doesn't navigate"

**Cause**: The deep link handler might need more time to initialize.

**Solution**: The launch script includes a 0.5s delay. You can adjust this in `NewsHubApp.swift`:

```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Increase delay
    coordinator.handleDeepLink(url)
}
```

### Issue: "Cannot find bundle identifier"

**Cause**: Bundle ID doesn't match.

**Solution**: Check your bundle identifier in Xcode:

1. Open `NewsHub.xcodeproj`
2. Select **NewsHub** target
3. Check **Bundle Identifier** under **General** tab
4. Update the script if needed:

```bash
xcrun simctl launch $UDID <YOUR_BUNDLE_ID> -DeepLinkURL "newshub://search"
```

### Issue: "App crashes on launch"

**Cause**: Most likely a Swift concurrency issue or missing dependencies.

**Solution**: Check Console logs:

```bash
# Get simulator UDID
UDID=$(xcrun simctl list devices | grep "Booted" | grep -oE '[0-9A-F-]{36}' | head -1)

# View logs
xcrun simctl spawn $UDID log stream --predicate 'processImagePath contains "NewsHub"'
```

---

## Advanced Usage

### Launch with Multiple Arguments

You can pass additional launch arguments:

```bash
xcrun simctl launch $UDID com.karthickramasamy.NewsHub \
    -DeepLinkURL "newshub://search" \
    -AppleLanguages "(en)" \
    -AppleLocale "en_US"
```

### Environment Variables

Pass environment variables:

```bash
xcrun simctl launch $UDID com.karthickramasamy.NewsHub \
    -DeepLinkURL "newshub://search" \
    DYLD_PRINT_STATISTICS=1
```

### Debug Launch Arguments

Enable debugging:

```bash
xcrun simctl launch $UDID com.karthickramasamy.NewsHub \
    -DeepLinkURL "newshub://search" \
    -com.apple.CoreData.ConcurrencyDebug 1 \
    -com.apple.CoreData.SQLDebug 1
```

---

## Testing Workflow

### 1. Quick Test (Existing Test Script)

For testing deep links on an already-running app:

```bash
./test-deeplinks.sh
```

See `DEEPLINK_GUIDE.md` for details.

### 2. Launch Test (New Launch Script)

For testing deep links from app launch:

```bash
# Test each tab
./launch-with-deeplink.sh newshub://home
./launch-with-deeplink.sh newshub://search
./launch-with-deeplink.sh newshub://bookmarks
./launch-with-deeplink.sh newshub://profile
```

### 3. Automated Testing

Create a comprehensive test script:

```bash
#!/bin/bash

TABS=("home" "search" "bookmarks" "profile")

for tab in "${TABS[@]}"; do
    echo "Testing newshub://$tab..."
    ./launch-with-deeplink.sh "newshub://$tab"
    sleep 5  # Wait to observe
done

echo "All tests complete!"
```

---

## Files Overview

| File | Purpose |
|------|---------|
| `launch-with-deeplink.sh` | Launch app with deep link via launch arguments |
| `test-deeplinks.sh` | Test deep links on running app |
| `DEEPLINK_GUIDE.md` | Guide for runtime deep linking |
| `LAUNCH_DEEPLINK_GUIDE.md` | This file - guide for launch arguments |
| `NewsHubApp.swift` | Handles launch arguments |
| `NavigationCoordinator.swift` | Handles deep link routing |

---

## Next Steps

1. ✅ Make the launch script executable: `chmod +x launch-with-deeplink.sh`
2. ✅ Test with: `./launch-with-deeplink.sh newshub://search`
3. ✅ Configure Xcode schemes for quick testing
4. ✅ Integrate into CI/CD for automated UI testing

---

## Summary

**For development**: Use the launch script for quick testing  
**For CI/CD**: Use manual simctl commands  
**For Xcode**: Configure scheme arguments  
**For runtime testing**: Use `test-deeplinks.sh`

The launch argument method ensures the app opens with the correct tab immediately, without any visible tab switching animation.
