# AppConfig Documentation

## Overview

The `AppConfig` system provides centralized configuration management for the NewsHub app through a JSON file and Swift struct.

## Files Created

### 1. AppConfig.json
**Location**: `/NewsHub/AppConfig.json`

JSON configuration file containing:
- **packages**: List of available Swift packages (currently: `["NewsList"]`)
- **app**: App metadata (name, version, bundle identifier)
- **features**: Feature flags (accessibility, analytics, notifications)
- **api**: API configuration (base URL, timeout)

```json
{
  "packages": [
    "NewsList"
  ],
  "app": {
    "name": "NewsHub",
    "version": "1.0.0",
    "bundleIdentifier": "com.newshub.app"
  },
  "features": {
    "enableAccessibilityIdentifiers": true,
    "enableAnalytics": false,
    "enablePushNotifications": false
  },
  "api": {
    "baseURL": "https://newsapi.org/v2",
    "timeout": 30
  }
}
```

### 2. AppConfig.swift
**Location**: `/NewsHub/AppConfig.swift`

Swift struct that:
- Loads and parses the JSON configuration
- Provides a singleton instance (`AppConfig.shared`)
- Includes convenience accessors for common operations
- Has fallback default configuration

## Usage

### Access Packages List

```swift
let packages = AppConfig.shared.packages
print("Available packages: \(packages)") // ["NewsList"]
```

### Check if Package Exists

```swift
if AppConfig.shared.hasPackage("NewsList") {
    print("NewsList package is configured")
}
```

### Access App Info

```swift
let appName = AppConfig.shared.appName        // "NewsHub"
let version = AppConfig.shared.appVersion      // "1.0.0"
```

### Check Feature Flags

```swift
if AppConfig.shared.isAccessibilityEnabled {
    // Enable accessibility identifiers
    print("Accessibility identifiers are enabled")
}
```

### Access API Configuration

```swift
let apiURL = AppConfig.shared.api.baseURL    // "https://newsapi.org/v2"
let timeout = AppConfig.shared.api.timeout   // 30
```

## Structure

### AppConfig (Root)
- `packages: [String]` - List of Swift packages used in the app
- `app: AppInfo` - Application metadata
- `features: FeatureFlags` - Feature toggles
- `api: APIConfig` - API settings

### AppInfo
- `name: String` - Application name
- `version: String` - Version number
- `bundleIdentifier: String` - Bundle identifier

### FeatureFlags
- `enableAccessibilityIdentifiers: Bool` - Toggle accessibility IDs
- `enableAnalytics: Bool` - Toggle analytics tracking
- `enablePushNotifications: Bool` - Toggle push notifications

### APIConfig
- `baseURL: String` - Base API URL
- `timeout: Int` - Request timeout in seconds

## Adding New Packages

To add a new package to the configuration:

1. **Update AppConfig.json**:
```json
{
  "packages": [
    "NewsList",
    "YourNewPackage"
  ]
}
```

2. **Use in Code**:
```swift
if AppConfig.shared.hasPackage("YourNewPackage") {
    // Initialize your package
}
```

## Benefits

1. **Centralized Configuration**: All app settings in one place
2. **Easy Updates**: Modify JSON without recompiling Swift code
3. **Type Safety**: Swift struct provides type-safe access
4. **Fallback Support**: Default configuration if file is missing
5. **Singleton Pattern**: Single source of truth across the app
6. **Convenience Methods**: Helper methods for common operations

## Error Handling

The configuration system includes automatic fallback to default values if:
- The JSON file is not found
- The JSON is malformed
- Decoding fails

This ensures the app always has valid configuration data.

## Example Integration

```swift
import SwiftUI

@main
struct NewsHubApp: App {
    init() {
        // Load configuration on app startup
        let config = AppConfig.shared
        print("Loaded \(config.packages.count) packages")
        
        // Configure based on feature flags
        if config.isAccessibilityEnabled {
            setupAccessibility()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func setupAccessibility() {
        // Configure accessibility features
        print("Accessibility identifiers enabled")
    }
}
```

## Notes

- The JSON file should be included in the Xcode project target
- Changes to the JSON file require rebuilding the app
- The singleton is loaded lazily on first access
- All configuration values are immutable once loaded

---

**Created**: October 1, 2025  
**Status**: ✅ AppConfig system implemented and documented
