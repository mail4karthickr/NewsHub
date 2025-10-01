#import <Foundation/Foundation.h>

NSBundle* GTMSessionFetcherLogView_SWIFTPM_MODULE_BUNDLE() {
    NSURL *bundleURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"GTMSessionFetcher_GTMSessionFetcherLogView.bundle"];

    NSBundle *preferredBundle = [NSBundle bundleWithURL:bundleURL];
    if (preferredBundle == nil) {
      return [NSBundle bundleWithPath:@"/Users/karthickramasamy/Desktop/NewsHub/Login/.build/index-build/arm64-apple-macosx/debug/GTMSessionFetcher_GTMSessionFetcherLogView.bundle"];
    }

    return preferredBundle;
}