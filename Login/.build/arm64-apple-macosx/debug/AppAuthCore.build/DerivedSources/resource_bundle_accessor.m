#import <Foundation/Foundation.h>

NSBundle* AppAuthCore_SWIFTPM_MODULE_BUNDLE() {
    NSURL *bundleURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"AppAuth_AppAuthCore.bundle"];

    NSBundle *preferredBundle = [NSBundle bundleWithURL:bundleURL];
    if (preferredBundle == nil) {
      return [NSBundle bundleWithPath:@"/Users/karthickramasamy/Desktop/NewsHub/Login/.build/arm64-apple-macosx/debug/AppAuth_AppAuthCore.bundle"];
    }

    return preferredBundle;
}