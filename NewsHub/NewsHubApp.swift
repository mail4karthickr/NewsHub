//
//  NewsHubApp.swift
//  NewsHub
//
//  Created by Karthick Ramasamy on 30/09/25.
//

import SwiftUI

@main
struct NewsHubApp: App {
    @StateObject private var coordinator = NavigationCoordinator()
    private let initialDeepLink: URL?
    
    init() {
        self.initialDeepLink = NewsHubApp.parseInitialDeepLink(from: ProcessInfo.processInfo.arguments)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
                .onAppear {
                    if let url = initialDeepLink {
                        coordinator.handleDeepLink(url)
                    }
                }
                .onOpenURL { url in
                    coordinator.handleDeepLink(url)
                }
        }
    }
    
    private static func parseInitialDeepLink(from arguments: [String]) -> URL? {
        // Prefer the pattern: -deeplink <url>
        if let flagIndex = arguments.firstIndex(of: "-deeplink"), flagIndex + 1 < arguments.count {
            let candidate = arguments[flagIndex + 1]
            if let url = URL(string: candidate) { return url }
        }
        // Fallback: any standalone argument that looks like a newshub scheme
        if let candidate = arguments.first(where: { $0.hasPrefix("newshub://") }), let url = URL(string: candidate) {
            return url
        }
        return nil
    }
}
