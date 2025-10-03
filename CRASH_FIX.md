# ✅ Crash Fixed - Actor Isolation Error Resolved

**Date**: 3 October 2025  
**Status**: ✅ **FIXED**  
**App Status**: Running successfully on iPhone 16 Simulator

---

## 🐛 Crash Details

### Error Type
```
Exception Type: EXC_BREAKPOINT (SIGTRAP)
Termination Reason: Trace/BPT trap: 5
Error: _dispatch_assert_queue_fail
```

### Crash Location
```
NewsService.swift
closure #1 in NewsService.fetchTopHeadlines(category:country:page:pageSize:)
```

### Root Cause
**Swift Concurrency Actor Isolation Violation**

The `NewsService` class is marked with `@MainActor`, but the `.handleEvents()` closure was being executed on a background thread when the network response arrived. This violated Swift's actor isolation rules, causing the runtime to trap.

### Thread Information
- **Crashed Thread**: Thread 6 (background dispatch queue)
- **Expected Thread**: Main thread (due to @MainActor)
- **Violation**: Accessing `@MainActor` isolated code from background thread

---

## 🔧 The Fix

### Problem Code (BEFORE)
```swift
return session.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: NewsResponse.self, decoder: JSONDecoder())
    .handleEvents(receiveOutput: { [weak self] response in
        // ❌ This runs on background thread!
        // But self is @MainActor, causing crash
        self?.cacheArticles(response.articles, for: cacheKey)
    })
    .receive(on: DispatchQueue.main)  // Too late!
    .eraseToAnyPublisher()
```

### Fixed Code (AFTER)
```swift
return session.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: NewsResponse.self, decoder: JSONDecoder())
    .receive(on: DispatchQueue.main)  // ✅ Switch to main thread FIRST
    .handleEvents(receiveOutput: { [weak self] response in
        // ✅ Now runs on main thread, safe to call @MainActor methods
        self?.cacheArticles(response.articles, for: cacheKey)
    })
    .eraseToAnyPublisher()
```

### Key Change
**Moved `.receive(on: DispatchQueue.main)` BEFORE `.handleEvents()`**

This ensures that the `handleEvents` closure executes on the main thread, which is required because:
1. `NewsService` is marked with `@MainActor`
2. `self?.cacheArticles()` is a `@MainActor` method
3. Calling `@MainActor` methods from background threads causes runtime traps

---

## 📊 Technical Explanation

### Swift Concurrency Actor Isolation
```swift
@MainActor
final class NewsService: ObservableObject {
    // All methods here must run on main thread
    private func cacheArticles(_ articles: [Article], for key: String) {
        // This is implicitly @MainActor
        articlesCache[key] = articles
        lastFetchTime[key] = Date()
    }
}
```

### Combine Publisher Pipeline
```
1. dataTaskPublisher       → Background thread
2. .map(\.data)           → Background thread  
3. .decode()              → Background thread
4. .receive(on: .main)    → Switches to MAIN thread ✅
5. .handleEvents()        → Now on MAIN thread ✅
```

### Why It Crashed
The old code had `.receive(on: .main)` AFTER `.handleEvents()`, so:
- Network response came in on background thread
- `.handleEvents()` closure executed on background thread
- Tried to call `@MainActor` method from background thread
- Runtime detected violation → CRASH

---

## ✅ Verification

### Build Status
```
✅ Clean succeeded
✅ Build succeeded  
✅ App launched successfully
✅ No crashes
```

### App Running On
- **Device**: iPhone 16 Simulator (iOS 26.0)
- **Bundle ID**: com.karthick.NewsHub
- **Status**: ✅ Running without crashes

---

## 📝 File Modified

**File**: `/Users/karthickramasamy/Desktop/NewsHub/NewsList/Sources/NewsList/Services/NewsService.swift`

**Method**: `fetchTopHeadlines(category:country:page:pageSize:)`

**Change**: Moved `.receive(on: DispatchQueue.main)` before `.handleEvents()`

---

## 🎯 Best Practices Applied

### 1. **Combine Publisher Thread Safety**
Always ensure you're on the correct thread before accessing actor-isolated code:
```swift
.receive(on: DispatchQueue.main)  // Switch thread first
.handleEvents(...)                 // Then handle events safely
```

### 2. **@MainActor Isolation**
When a class is marked `@MainActor`:
- All methods run on main thread
- All closures accessing `self` must be on main thread
- Use `.receive(on: .main)` before calling class methods

### 3. **Network Response Handling**
```swift
// ✅ Correct pattern for @MainActor classes
URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: T.self, decoder: JSONDecoder())
    .receive(on: DispatchQueue.main)     // Switch to main
    .handleEvents(receiveOutput: { ... }) // Safe to use
    .eraseToAnyPublisher()
```

---

## 🚀 Impact

### Before Fix
- ❌ App crashed immediately when fetching news
- ❌ Actor isolation violation
- ❌ Background thread accessing main actor code

### After Fix
- ✅ App runs smoothly
- ✅ News fetching works correctly
- ✅ Proper thread safety
- ✅ Swift Concurrency compliance

---

## 📚 Related Concepts

### Swift Concurrency
- `@MainActor` - Ensures code runs on main thread
- Actor isolation - Prevents data races
- Runtime checks - Enforces thread safety

### Combine Framework
- `.receive(on:)` - Thread switching operator
- `.handleEvents()` - Side effect operator
- Pipeline ordering matters!

---

## 🎉 Summary

**The crash has been successfully fixed!**

The issue was a Swift Concurrency actor isolation violation where code marked with `@MainActor` was being called from a background thread. By reordering the Combine operators to switch to the main thread BEFORE handling events, the crash is resolved.

**Status**: ✅ App is now running successfully without crashes!
