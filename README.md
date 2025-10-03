# NewsHub - Deep Link Launch Methods

This README provides a quick reference for launching NewsHub with deep links.

## Quick Start

### Method 1: Launch Script (Recommended for Testing)

Launch the app directly with a specific tab:

```bash
# Make executable (first time only)
chmod +x launch-with-deeplink.sh

# Launch on Search tab
./launch-with-deeplink.sh newshub://search

# Launch on Profile tab
./launch-with-deeplink.sh newshub://profile

# Use different simulator
./launch-with-deeplink.sh --simulator "iPhone 15 Pro" newshub://home
```

### Method 2: Runtime Deep Links (Running App)

Send deep links to an already running app:

```bash
# Make executable (first time only)
chmod +x test-deeplinks.sh

# Test all tabs
./test-deeplinks.sh

# Or test specific tab manually
xcrun simctl openurl booted "newshub://search"
```

## Deep Link URLs

| URL | Tab |
|-----|-----|
| `newshub://home` | Home |
| `newshub://search` | Search |
| `newshub://bookmarks` | Bookmarks |
| `newshub://profile` | Profile |

## Documentation

- **[LAUNCH_DEEPLINK_GUIDE.md](LAUNCH_DEEPLINK_GUIDE.md)** - Complete guide for launch arguments
- **[DEEPLINK_GUIDE.md](DEEPLINK_GUIDE.md)** - Guide for runtime deep linking
- **[BUILD_SUCCESS.md](BUILD_SUCCESS.md)** - Build status and verification
- **[CRASH_FIX.md](CRASH_FIX.md)** - Actor isolation crash fix documentation

## Project Structure

```
NewsHub/
├── NewsHub/                        # Main app target
│   ├── NewsHubApp.swift           # App entry point (handles launch args)
│   ├── ContentView.swift          # Main tab view
│   └── Navigation/
│       └── NavigationCoordinator.swift  # Tab & deep link routing
├── NewsList/                      # News feature package
│   └── Sources/NewsList/
│       ├── Views/                 # News UI components
│       ├── ViewModels/            # News view models
│       ├── Services/              # News & bookmark services
│       └── Models/                # News data models
├── launch-with-deeplink.sh        # Launch with deep link
└── test-deeplinks.sh              # Test deep links on running app
```

## Implementation Details

### Launch Arguments Flow

1. App launches with `-DeepLinkURL` argument
2. `NewsHubApp.swift` reads the argument in `onAppear`
3. After 0.5s delay, calls `coordinator.handleDeepLink(url)`
4. `NavigationCoordinator` parses URL and switches tab
5. User sees the app open on the correct tab

### Code Locations

- **Launch argument handling**: `NewsHub/NewsHubApp.swift`
- **Deep link routing**: `NewsHub/Navigation/NavigationCoordinator.swift`
- **Tab switching**: `NewsHub/ContentView.swift`
- **URL scheme config**: `NewsHub/Info.plist`

## Testing

### Test Launch Arguments

```bash
# Test all tabs
for tab in home search bookmarks profile; do
    ./launch-with-deeplink.sh "newshub://$tab"
    sleep 5
done
```

### Test Runtime Deep Links

```bash
# First build and run the app
xcodebuild -project NewsHub.xcodeproj -scheme NewsHub -destination "platform=iOS Simulator,name=iPhone 16" build
xcrun simctl install booted $(find .build/Build/Products/Debug-iphonesimulator -name "NewsHub.app" -maxdepth 1)
xcrun simctl launch booted com.karthickramasamy.NewsHub

# Then test deep links
./test-deeplinks.sh
```

### Verify in Xcode

1. Open `NewsHub.xcodeproj`
2. Edit Scheme → Run → Arguments
3. Add: `-DeepLinkURL newshub://search`
4. Run (⌘R)
5. App should open on Search tab

## Troubleshooting

### App doesn't navigate to tab

**Solution**: Increase delay in `NewsHubApp.swift`:

```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Increase from 0.5
    coordinator.handleDeepLink(url)
}
```

### Simulator not found

**Solution**: List available simulators:

```bash
xcrun simctl list devices | grep iPhone
```

Update script or use `--simulator` flag with exact name.

### Build fails

**Solution**: Build in Xcode first:

```bash
open NewsHub.xcodeproj
# Press ⌘B to build
```

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Build and Test Deep Links
  run: |
    # Boot simulator
    UDID=$(xcrun simctl list devices | grep "iPhone 16" | head -1 | grep -oE '[0-9A-F-]{36}')
    xcrun simctl boot $UDID
    
    # Build
    xcodebuild -project NewsHub.xcodeproj -scheme NewsHub -destination "id=$UDID" build
    
    # Install
    APP_PATH=$(find .build/Build/Products/Debug-iphonesimulator -name "NewsHub.app")
    xcrun simctl install $UDID "$APP_PATH"
    
    # Test launch with deep link
    xcrun simctl launch $UDID com.karthickramasamy.NewsHub -DeepLinkURL "newshub://search"
    
    # Verify tab (would need UI testing here)
```

## Features

### Current Features

- ✅ Tab-based navigation (Home, Search, Bookmarks, Profile)
- ✅ Deep link support via `newshub://` URL scheme
- ✅ Launch argument support for automated testing
- ✅ Runtime URL handling for running app
- ✅ News feed with category filtering
- ✅ Bookmark management
- ✅ Pull-to-refresh
- ✅ Skeleton loading states

### Architecture

- **SwiftUI** - Modern declarative UI
- **Combine** - Reactive state management
- **Swift Package Manager** - Modular feature organization
- **@Published** - Observable state
- **@EnvironmentObject** - Dependency injection

## Development

### Build Requirements

- Xcode 15.0+
- iOS 17.0+ Simulator
- macOS 14.0+ (Sonoma)

### Quick Commands

```bash
# Build
xcodebuild -project NewsHub.xcodeproj -scheme NewsHub build

# Run on simulator
xcodebuild -project NewsHub.xcodeproj -scheme NewsHub \
    -destination "platform=iOS Simulator,name=iPhone 16" run

# Launch with deep link
./launch-with-deeplink.sh newshub://search

# Test deep links
./test-deeplinks.sh
```

## Support

For detailed documentation:

- Launch arguments: See `LAUNCH_DEEPLINK_GUIDE.md`
- Runtime deep links: See `DEEPLINK_GUIDE.md`
- Build issues: See `BUILD_ISSUES_RESOLVED.md`
- Crash fixes: See `CRASH_FIX.md`

## License

MIT License - See LICENSE file for details

---

**Last Updated**: January 2025  
**Status**: ✅ Build Verified | ✅ Deep Links Working | ✅ Launch Args Tested
