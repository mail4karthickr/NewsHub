#import <Foundation/Foundation.h>

NSBundle* GTMSessionFetcherFull_SWIFTPM_MODULE_BUNDLE() {
    NSURL *bundleURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"GTMSessionFetcher_GTMSessionFetcherFull.bundle"];

    NSBundle *preferredBundle = [NSBundle bundleWithURL:bundleURL];
    if (preferredBundle == nil) {
      return [NSBundle bundleWithPath:@"/Users/karthickramasamy/Desktop/NewsHub/Login/.build/arm64-apple-macosx/debug/GTMSessionFetcher_GTMSessionFetcherFull.bundle"];
    }

    return preferredBundle;
}