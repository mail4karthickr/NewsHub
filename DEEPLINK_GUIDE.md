# Deep Linking Setup for NewsHub

## 🔗 Supported Deep Links

Your app currently supports these deep links:
- `newshub://home` - Navigate to Home tab
- `newshub://search` - Navigate to Search tab
- `newshub://bookmarks` or `newshub://saved` - Navigate to Bookmarks tab
- `newshub://profile` or `newshub://settings` - Navigate to Profile tab

---

## 📱 Command Line Deep Link Testing

### Method 1: Using xcrun simctl (Recommended)

#### Launch app with deep link:
```bash
# Home tab
xcrun simctl openurl booted "newshub://home"

# Search tab
xcrun simctl openurl booted "newshub://search"

# Bookmarks tab
xcrun simctl openurl booted "newshub://bookmarks"

# Profile tab
xcrun simctl openurl booted "newshub://profile"
```

### Method 2: Launch with Arguments (iOS Simulator)

#### Option A: Using xcodebuild MCP
```bash
# This will launch the app with deep link arguments
# The app will automatically handle the URL on launch
```

#### Option B: Using Xcode Run Arguments
1. In Xcode: Product → Scheme → Edit Scheme
2. Go to "Run" → "Arguments" tab
3. Under "Arguments Passed On Launch", add:
   ```
   -url newshub://home
   ```
4. Run the app

---

## 🚀 Testing Deep Links

### Step 1: Make sure the app is installed and running
```bash
# Check if app is installed
xcrun simctl listapps booted | grep NewsHub
```

### Step 2: Send deep link to the app
```bash
# Open home tab
xcrun simctl openurl booted "newshub://home"
```

### Step 3: Verify navigation
- The app should automatically switch to the Home tab
- You'll see the tab selection change in the UI

---

## 🔧 How It Works

### 1. URL Scheme Registration
Your app is already configured with the `newshub://` URL scheme (in Info.plist or project settings).

### 2. Deep Link Handling in ContentView
```swift
.onOpenURL { url in
    coordinator.handleDeepLink(url)
}
```

### 3. Navigation Coordinator Parsing
```swift
func handleDeepLink(_ url: URL) {
    guard url.scheme == "newshub" else { return }
    
    let path = url.host ?? ""
    
    switch path {
    case "home":
        switchTab(to: .home)
    case "search":
        switchTab(to: .search)
    case "bookmarks", "saved":
        switchTab(to: .bookmarks)
    case "profile", "settings":
        switchTab(to: .profile)
    default:
        switchTab(to: .home)
    }
}
```

---

## 📝 Complete Command Line Workflow

### 1. Build and Launch App
```bash
# Clean build
cd /Users/karthickramasamy/Desktop/NewsHub
xcodebuild -project NewsHub.xcodeproj -scheme NewsHub clean build \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Install on simulator
xcrun simctl install booted \
  ~/Library/Developer/Xcode/DerivedData/NewsHub-*/Build/Products/Debug-iphonesimulator/NewsHub.app

# Launch app
xcrun simctl launch booted com.karthick.NewsHub
```

### 2. Send Deep Link
```bash
# Navigate to home tab
xcrun simctl openurl booted "newshub://home"

# Navigate to search tab
xcrun simctl openurl booted "newshub://search"

# Navigate to bookmarks
xcrun simctl openurl booted "newshub://bookmarks"
```

---

## 🎯 Quick Test Script

Create a test script to automate deep link testing:

```bash
#!/bin/bash
# save as: test-deeplinks.sh

echo "🚀 Testing NewsHub Deep Links..."

# Check if app is running
if xcrun simctl spawn booted launchctl list | grep -q "com.karthick.NewsHub"; then
    echo "✅ App is running"
else
    echo "⚠️  Launching app..."
    xcrun simctl launch booted com.karthick.NewsHub
    sleep 2
fi

# Test home deep link
echo "📱 Testing: newshub://home"
xcrun simctl openurl booted "newshub://home"
sleep 2

# Test search deep link
echo "🔍 Testing: newshub://search"
xcrun simctl openurl booted "newshub://search"
sleep 2

# Test bookmarks deep link
echo "🔖 Testing: newshub://bookmarks"
xcrun simctl openurl booted "newshub://bookmarks"
sleep 2

# Test profile deep link
echo "👤 Testing: newshub://profile"
xcrun simctl openurl booted "newshub://profile"

echo "✅ Deep link tests complete!"
```

Make it executable:
```bash
chmod +x test-deeplinks.sh
./test-deeplinks.sh
```

---

## 🛠️ Troubleshooting

### Issue: "No devices available" error
**Solution**: Boot a simulator first
```bash
xcrun simctl boot "iPhone 16"
open -a Simulator
```

### Issue: Deep link doesn't work
**Solution**: Check URL scheme registration
```bash
# Verify app's URL schemes
/usr/libexec/PlistBuddy -c "Print CFBundleURLTypes" \
  ~/Library/Developer/Xcode/DerivedData/NewsHub-*/Build/Products/Debug-iphonesimulator/NewsHub.app/Info.plist
```

### Issue: App not installed
**Solution**: Install the app first
```bash
xcrun simctl install booted \
  ~/Library/Developer/Xcode/DerivedData/NewsHub-*/Build/Products/Debug-iphonesimulator/NewsHub.app
```

---

## 📊 Advanced: Launch with Arguments

### Using xcodebuild with launch arguments:
```bash
# Set environment variable for deep link
xcodebuild test \
  -project NewsHub.xcodeproj \
  -scheme NewsHub \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing NewsHubUITests/DeepLinkTests
```

### Using simctl with environment:
```bash
# Launch with custom URL
xcrun simctl launch booted com.karthick.NewsHub \
  --console-pty \
  --url "newshub://home"
```

---

## 🎬 Example Usage Session

```bash
# 1. Build the app
cd /Users/karthickramasamy/Desktop/NewsHub
xcodebuild -project NewsHub.xcodeproj -scheme NewsHub \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16'

# 2. Launch simulator
open -a Simulator

# 3. Install app
xcrun simctl install booted \
  ~/Library/Developer/Xcode/DerivedData/NewsHub-*/Build/Products/Debug-iphonesimulator/NewsHub.app

# 4. Launch app
xcrun simctl launch booted com.karthick.NewsHub

# 5. Test deep link - Navigate to home
xcrun simctl openurl booted "newshub://home"

# 6. Test deep link - Navigate to search  
xcrun simctl openurl booted "newshub://search"
```

---

## ✅ Verification

After running a deep link command:
1. **Visual Check**: The app should switch to the corresponding tab
2. **Logs**: Check console output for deep link handling
3. **State**: The `coordinator.selectedTab` should update

---

## 🔐 URL Scheme Configuration

Your app needs to register the URL scheme. Verify in **Info.plist**:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>newshub</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.karthick.NewsHub</string>
    </dict>
</array>
```

If not present, add it to your project settings or Info.plist.

---

## 📚 Summary

**Command to test deep linking:**
```bash
# Simple one-liner
xcrun simctl openurl booted "newshub://home"
```

**Expected behavior:**
- App receives the URL
- `handleDeepLink()` is called
- Tab switches to Home
- UI updates immediately

**Current supported URLs:**
- `newshub://home` → Home tab ✅
- `newshub://search` → Search tab ✅
- `newshub://bookmarks` → Bookmarks tab ✅
- `newshub://profile` → Profile tab ✅
