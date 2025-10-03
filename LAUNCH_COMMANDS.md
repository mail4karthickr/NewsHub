# NewsHub Launch Commands Quick Reference

This guide provides quick copy-paste commands for launching NewsHub with deep links on iPhone 16 (iOS 26).

## 🚀 Quick Launch Commands

### Using the Simplified Launcher (Recommended)

The `launch-newshub.sh` script always uses the correct iPhone 16 (iOS 26) simulator:

```bash
# Launch to Home tab
./launch-newshub.sh newshub://home

# Launch to Search tab
./launch-newshub.sh newshub://search

# Launch to Bookmarks tab
./launch-newshub.sh newshub://bookmarks

# Launch to Profile tab
./launch-newshub.sh newshub://profile
```

### Using the Full Launcher

The `launch-with-deeplink.sh` script auto-detects the simulator or allows manual specification:

```bash
# Auto-detect iPhone 16 and launch to Home
./launch-with-deeplink.sh newshub://home

# Specify exact simulator UDID
./launch-with-deeplink.sh --udid 1327A774-72AF-47FB-8835-A99F80B1F28D newshub://home

# Use environment variable
NEWSHUB_SIMULATOR_UDID=1327A774-72AF-47FB-8835-A99F80B1F28D ./launch-with-deeplink.sh newshub://home
```

## 📱 Simulator Information

**iPhone 16 (iOS 26)**
- **UDID:** `1327A774-72AF-47FB-8835-A99F80B1F28D`
- **iOS Version:** 18.4 (internally iOS 26)
- **Status:** Booted and ready
- **Bundle ID:** `com.karthick.NewsHub`

## 🔗 Supported Deep Links

| Deep Link URL | Tab | Description |
|--------------|-----|-------------|
| `newshub://home` | Home | Navigate to Home feed |
| `newshub://search` | Search | Navigate to Search |
| `newshub://bookmarks` | Bookmarks | Navigate to saved articles |
| `newshub://profile` | Profile | Navigate to user profile |

## 📋 Complete Workflow

The launch scripts automatically handle all steps:

1. ✅ Find/boot iPhone 16 (iOS 26) simulator
2. ✅ Build the NewsHub app for the simulator
3. ✅ Install the app on the simulator
4. ✅ Launch the app
5. ✅ Send the deep link to navigate to the correct tab

## 🛠️ Manual Commands (Advanced)

If you need to run individual steps manually:

```bash
# 1. Boot simulator
xcrun simctl boot 1327A774-72AF-47FB-8835-A99F80B1F28D

# 2. Build app
xcodebuild -project NewsHub.xcodeproj \
    -scheme NewsHub \
    -destination "id=1327A774-72AF-47FB-8835-A99F80B1F28D" \
    -derivedDataPath .build \
    build

# 3. Install app
APP_PATH=$(find .build/Build/Products/Debug-iphonesimulator -name "NewsHub.app" | head -1)
xcrun simctl install 1327A774-72AF-47FB-8835-A99F80B1F28D "$APP_PATH"

# 4. Launch app
xcrun simctl launch 1327A774-72AF-47FB-8835-A99F80B1F28D com.karthick.NewsHub

# 5. Send deep link
xcrun simctl openurl 1327A774-72AF-47FB-8835-A99F80B1F28D newshub://home
```

## 🔍 Testing Deep Links on Running App

If the app is already running and you just want to test deep links:

```bash
# Use the test script
./test-deeplinks.sh newshub://search

# Or manually
xcrun simctl openurl 1327A774-72AF-47FB-8835-A99F80B1F28D newshub://search
```

## ⚙️ Troubleshooting

### Simulator not booting
```bash
# Check simulator status
xcrun simctl list devices | grep "1327A774-72AF-47FB-8835-A99F80B1F28D"

# Force boot
xcrun simctl boot 1327A774-72AF-47FB-8835-A99F80B1F28D
```

### Build errors
```bash
# Clean build
xcodebuild -project NewsHub.xcodeproj -scheme NewsHub clean

# Or use the script with a fresh build
rm -rf .build
./launch-newshub.sh newshub://home
```

### Deep link not working
```bash
# 1. Check if app is running
xcrun simctl launch 1327A774-72AF-47FB-8835-A99F80B1F28D com.karthick.NewsHub

# 2. Wait a moment for app to initialize
sleep 3

# 3. Send deep link again
xcrun simctl openurl 1327A774-72AF-47FB-8835-A99F80B1F28D newshub://home
```

## 📝 Examples

### Switch between tabs quickly
```bash
# Go to Home
./launch-newshub.sh newshub://home

# Then switch to Search
./test-deeplinks.sh newshub://search

# Then to Bookmarks
./test-deeplinks.sh newshub://bookmarks
```

### Fresh install and launch
```bash
# Uninstall app first
xcrun simctl uninstall 1327A774-72AF-47FB-8835-A99F80B1F28D com.karthick.NewsHub

# Clean build
rm -rf .build

# Launch with deep link (will rebuild and reinstall)
./launch-newshub.sh newshub://home
```

## 🎯 Best Practices

1. **Use `launch-newshub.sh`** for most cases - it's pre-configured with the correct simulator
2. **Use `test-deeplinks.sh`** when the app is already running and you just want to test navigation
3. **Use `launch-with-deeplink.sh`** when you need flexibility with different simulators
4. **Check simulator status** before running if you encounter issues
5. **Allow 2-3 seconds** after app launch before sending deep links for best results

## 🔄 CI/CD Integration

For automated testing or CI/CD pipelines:

```bash
#!/bin/bash
set -e

# Boot simulator
xcrun simctl boot 1327A774-72AF-47FB-8835-A99F80B1F28D || true

# Build and launch with deep link
./launch-newshub.sh newshub://home

# Wait for app to settle
sleep 5

# Run your UI tests here
# ...
```

---

**Related Documentation:**
- [DEEPLINK_GUIDE.md](./DEEPLINK_GUIDE.md) - Deep linking implementation details
- [LAUNCH_DEEPLINK_GUIDE.md](./LAUNCH_DEEPLINK_GUIDE.md) - Comprehensive launch guide
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - General quick reference
