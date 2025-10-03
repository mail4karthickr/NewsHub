//
//  NavigationCoordinator.swift
//  NewsHub
//
//  Created on 03/10/25.
//

import SwiftUI
import Combine

// MARK: - Tab Selection

enum AppTab: Int, Hashable {
    case home = 0
    case search = 1
    case bookmarks = 2
    case profile = 3
}

// MARK: - Navigation Coordinator

@MainActor
class NavigationCoordinator: ObservableObject {
    // Tab selection
    @Published var selectedTab: AppTab = .home
    
    // MARK: - Tab Switching
    
    /// Switch to a specific tab
    func switchTab(to tab: AppTab) {
        selectedTab = tab
    }
    
    // MARK: - Deep Linking
    
    /// Handle deep link URL for tab switching
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
}

