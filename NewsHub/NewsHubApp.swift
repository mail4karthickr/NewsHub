//
//  NewsHubApp.swift
//  NewsHub
//
//  Created by Karthick Ramasamy on 30/09/25.
//

import SwiftUI
import Login

@main
struct NewsHubApp: App {
    @StateObject private var authManager = GoogleAuthManager.shared
    
    init() {
        configureGoogleSignIn()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .onOpenURL { url in
                    // Handle Google Sign-In URL schemes
                    if url.scheme?.hasPrefix("com.googleusercontent.apps") == true {
                        // This will be handled by Google Sign-In SDK
                    }
                }
        }
    }
    
    private func configureGoogleSignIn() {
        // Try to read client ID from GoogleService-Info.plist
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let clientID = plist["CLIENT_ID"] as? String,
           !clientID.contains("YOUR_") {
            GoogleAuthManager.shared.configure(clientID: clientID)
            
            // Try to restore previous sign-in
            GoogleAuthManager.shared.restorePreviousSignIn { success in
                if success {
                    print("✅ Previous sign-in restored")
                } else {
                    print("ℹ️ No previous sign-in to restore")
                }
            }
        } else {
            print("⚠️ Google Sign-In not configured. Please add a valid GoogleService-Info.plist file")
            print("📝 To set up Google Sign-In:")
            print("   1. Go to https://console.developers.google.com")
            print("   2. Create a new project or select existing one")
            print("   3. Enable Google Sign-In API")
            print("   4. Create iOS OAuth client ID")
            print("   5. Download GoogleService-Info.plist")
            print("   6. Replace the placeholder file in your project")
        }
    }
}
