# Quick Reference: NewsHub Deep Link Launch

## 🚀 Quick Commands

### Launch with Deep Link (New!)

```bash
# Launch on Home tab
./launch-with-deeplink.sh newshub://home

# Launch on Search tab
./launch-with-deeplink.sh newshub://search

# Launch on Bookmarks tab
./launch-with-deeplink.sh newshub://bookmarks

# Launch on Profile tab
./launch-with-deeplink.sh newshub://profile
```

### Test Running App

```bash
# Test all tabs automatically
./test-deeplinks.sh

# Test specific tab
xcrun simctl openurl booted "newshub://search"
```

---

## 📋 Cheat Sheet

| Task | Command |
|------|---------|
| **Launch with deep link** | `./launch-with-deeplink.sh newshub://search` |
| **Test all tabs** | `./test-deeplinks.sh` |
| **List simulators** | `xcrun simctl list devices \| grep iPhone` |
| **Boot simulator** | `xcrun simctl boot <UDID>` |
| **Build app** | `xcodebuild -project NewsHub.xcodeproj -scheme NewsHub build` |
| **Send deep link** | `xcrun simctl openurl booted "newshub://search"` |

---

## 🔗 Deep Link URLs

```
newshub://home          → Home tab
newshub://search        → Search tab
newshub://bookmarks     → Bookmarks tab (alt: newshub://saved)
newshub://profile       → Profile tab (alt: newshub://settings)
```

---

## 🛠️ Setup (One-time)

```bash
# Make scripts executable
chmod +x launch-with-deeplink.sh
chmod +x test-deeplinks.sh
```

---

## 📖 Full Guides

- **Launch Arguments**: `LAUNCH_DEEPLINK_GUIDE.md`
- **Runtime Deep Links**: `DEEPLINK_GUIDE.md`
- **Build Status**: `BUILD_SUCCESS.md`

---

## ⚡ One-Liner Examples

### Build, Install & Launch

```bash
# All-in-one: Build, install, launch with deep link
UDID=$(xcrun simctl list devices | grep "iPhone 16" | grep -v "unavailable" | head -1 | grep -oE '[0-9A-F-]{36}') && \
xcrun simctl boot $UDID 2>/dev/null; \
xcodebuild -project NewsHub.xcodeproj -scheme NewsHub -destination "id=$UDID" -derivedDataPath .build build && \
xcrun simctl install $UDID $(find .build/Build/Products/Debug-iphonesimulator -name "NewsHub.app" -maxdepth 1) && \
xcrun simctl launch $UDID com.karthickramasamy.NewsHub -DeepLinkURL "newshub://search"
```

### Quick Test Loop

```bash
# Test all tabs with 3-second pause
for tab in home search bookmarks profile; do
    xcrun simctl openurl booted "newshub://$tab"
    sleep 3
done
```

---

## 🎯 Use Cases

| Scenario | Method | Command |
|----------|--------|---------|
| **Fresh app launch** | Launch script | `./launch-with-deeplink.sh newshub://search` |
| **App already running** | Runtime URL | `xcrun simctl openurl booted "newshub://search"` |
| **Automated testing** | CI/CD script | See `LAUNCH_DEEPLINK_GUIDE.md` |
| **Xcode debugging** | Scheme args | Edit Scheme → `-DeepLinkURL newshub://search` |

---

## 🏗️ Implementation Files

```
NewsHub/
├── NewsHubApp.swift              # Handles -DeepLinkURL launch arg
├── ContentView.swift             # Tab view UI
├── Navigation/
│   └── NavigationCoordinator.swift  # Deep link routing logic
└── Info.plist                    # URL scheme registration
```

---

## ✅ Verification Steps

1. **Build**: `xcodebuild -project NewsHub.xcodeproj -scheme NewsHub build`
2. **Launch**: `./launch-with-deeplink.sh newshub://search`
3. **Verify**: App should open on Search tab
4. **Test**: `./test-deeplinks.sh` to test all tabs

---

**Status**: ✅ Working  
**Last Tested**: January 2025  
**Supported iOS**: 17.0+
