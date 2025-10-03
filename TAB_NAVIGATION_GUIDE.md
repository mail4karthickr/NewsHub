# Navigation Quick Reference - Tab Selection Only

## 🎯 What It Does
**Tab switching only** - No article navigation, no modals, no error toasts.

---

## 📋 NavigationCoordinator API

```swift
// Create coordinator
@StateObject private var coordinator = NavigationCoordinator()

// Inject into view hierarchy
.environmentObject(coordinator)

// Access in child views
@EnvironmentObject var coordinator: NavigationCoordinator

// Switch tabs
coordinator.switchTab(to: .home)
coordinator.switchTab(to: .search)
coordinator.switchTab(to: .bookmarks)
coordinator.switchTab(to: .profile)

// Handle deep links
coordinator.handleDeepLink(url)
```

---

## 🔗 Deep Link URLs

| URL | Tab |
|-----|-----|
| `newshub://home` | Home |
| `newshub://search` | Search |
| `newshub://bookmarks` | Bookmarks |
| `newshub://saved` | Bookmarks |
| `newshub://profile` | Profile |
| `newshub://settings` | Profile |

---

## 📱 Tab Structure

```
TabView (bound to coordinator.selectedTab)
├─ 🏠 Home      → NewsHomeView (from NewsList)
├─ 🔍 Search    → NewsSearchView (placeholder)
├─ 🔖 Bookmarks → BookmarksView (placeholder)
└─ 👤 Profile   → ProfileView (settings)
```

---

## 💻 Code Examples

### Setup in ContentView
```swift
struct ContentView: View {
    @StateObject private var coordinator = NavigationCoordinator()
    
    var body: some View {
        NewsHubMainView()
            .environmentObject(coordinator)
            .onOpenURL { url in
                coordinator.handleDeepLink(url)
            }
    }
}
```

### Switch Tabs Programmatically
```swift
struct BookmarksView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        Button("Browse News") {
            coordinator.switchTab(to: .home)
        }
    }
}
```

### Access Selected Tab
```swift
// Read current tab
let currentTab = coordinator.selectedTab

// Bind to picker/segmented control
Picker("Tab", selection: $coordinator.selectedTab) {
    Text("Home").tag(AppTab.home)
    Text("Search").tag(AppTab.search)
}
```

---

## 📊 What's Included vs Removed

### ✅ Included
- Tab selection (`AppTab` enum)
- Tab switching (`switchTab(to:)`)
- Deep linking for tabs (`handleDeepLink(_:)`)

### ❌ Removed
- Article navigation
- Modal presentation
- Error toasts
- Article detail views
- Navigation paths/stacks
- Generic navigation destinations

---

## 🎨 AppTab Enum

```swift
enum AppTab: Int, Hashable {
    case home = 0       // Tag: 0
    case search = 1     // Tag: 1
    case bookmarks = 2  // Tag: 2
    case profile = 3    // Tag: 3
}
```

---

## 🚀 That's It!

Super simple. Super clean. Just tab switching. 🎉
