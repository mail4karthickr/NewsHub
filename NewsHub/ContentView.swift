//
//  ContentView.swift
//  NewsHub
//
//  Created by Karthick Ramasamy on 30/09/25.
//

import SwiftUI
import Foundation
import Combine
import NewsList
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SafariServices)
import SafariServices
#endif

struct ContentView: View {
    @State private var showErrorToast = false
    @State private var errorMessage = ""
    
    var body: some View {
        // Main news hub interface - no authentication required
        NewsHubMainView()
        .overlay(
            // Error toast overlay
            VStack {
                if showErrorToast {
                    ToastView(message: errorMessage, isError: true)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showErrorToast = false
                                }
                            }
                        }
                }
                Spacer()
            }
            .animation(.easeInOut, value: showErrorToast)
        )
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        withAnimation {
            showErrorToast = true
        }
    }
}

// MARK: - Main Tab View
struct NewsHubMainView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @State private var selectedTab = AppTab.home
    
    var body: some View {
        TabView(selection: Binding(get: { coordinator.selectedTab }, set: { coordinator.selectedTab = $0 })) {
            NavigationStack { NewsHomeView() }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(AppTab.home)
            
            NavigationStack { NewsSearchView() }
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(AppTab.search)
            
            NavigationStack { BookmarksView() }
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Saved")
                }
                .tag(AppTab.bookmarks)
            
            NavigationStack { ProfileView() }
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag(AppTab.profile)
        }
    }
}

// MARK: - Tab Content Views

fileprivate struct WebURLItem: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

struct NewsHomeView: View {
    @StateObject private var viewModel = NewsFeedViewModel()
    @State private var selectedArticleItem: WebURLItem?
    
    var body: some View {
        ScrollView {
            RefreshControl(
                coordinateSpaceName: "pullToRefresh",
                onRefresh: {
                    viewModel.refresh()
                }
            )
            
            LazyVStack(spacing: 16) {
                
                // Content based on loading state
                switch viewModel.loadingState {
                case .idle, .loading:
                    if viewModel.articles.isEmpty {
                        // Show skeleton loading
                        ForEach(0..<5, id: \.self) { _ in
                            NewsSkeletonView()
                        }
                    }
                    
                case .loaded:
                    // Show articles using the horizontal layout as specified in the story
                    ForEach(viewModel.articles) { article in
                        NewsListItemView(
                            article: article,
                            onReadMore: {
                                if let url = URL(string: article.url) {
                                    selectedArticleItem = WebURLItem(url: url)
                                }
                            },
                            onFavorite: {
                                BookmarkManager.shared.toggleFavorite(articleId: article.id)
                            }
                        )
                        .accessibilityIdentifier("newsListHomeView")
                        .onAppear {
                            // Load more when reaching the last item
                            if viewModel.shouldLoadMore(for: article) {
                                viewModel.loadMore()
                            }
                        }
                    }
                    
                    // Loading more indicator
                    if viewModel.isLoadingMore {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading more...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                case .failed(let error):
                    NewsErrorView(error: error) {
                        viewModel.loadInitialData()
                    }
                }
                
                if viewModel.articles.isEmpty && viewModel.loadingState == .loaded {
                    NewsEmptyView()
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal)
        }
        .coordinateSpace(name: "pullToRefresh")
        .navigationTitle("News")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .sheet(item: $selectedArticleItem) { item in
            SafariWebView(url: item.url)
        }
    }
    
    private func openArticle(_ article: Any) {
        // Present article in a sheet using item binding
        if let urlString = (article as AnyObject).value(forKey: "url") as? String,
           let url = URL(string: urlString) {
            selectedArticleItem = WebURLItem(url: url)
            if let title = (article as AnyObject).value(forKey: "title") as? String {
                print("📰 Opening article modal for: \(title)")
            }
        }
    }
}

struct NewsSearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search news...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            if searchText.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("Search News")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Search for topics, sources, or articles")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                // Search results would go here
                ScrollView {
                    LazyVStack {
                        ForEach(0..<3, id: \.self) { index in
                            NewsCardView(
                                title: "Search Result \(index + 1)",
                                summary: "This article matches your search for '\(searchText)'",
                                onTap: {
                                    // Navigate to search result detail
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .accessibilityIdentifier("searchHomeView")
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct BookmarksView: View {
    @State private var savedArticles: [String] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if savedArticles.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "bookmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Saved Articles")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Articles you bookmark will appear here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Browse News") {
                            // This would switch to Home tab
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 100)
                } else {
                    // Saved articles list
                    ForEach(savedArticles, id: \.self) { article in
                        NewsCardView(
                            title: article,
                            summary: "You saved this article for later reading.",
                            onTap: {
                                // Navigate to saved article detail
                            }
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
        .accessibilityIdentifier("savedHomeView")
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Categories") {
                    // Navigate to bookmark categories
                }
            }
        }
    }
}

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App branding section
                VStack(spacing: 16) {
                    // App icon
                    Image(systemName: "newspaper.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 4) {
                        Text("NewsHub")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Stay updated with the latest news")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 20)
                
                // App options
                VStack(spacing: 12) {
                    ProfileOptionRow(
                        icon: "gear",
                        title: "Settings",
                        action: {
                            // Navigate to settings
                        }
                    )
                    
                    ProfileOptionRow(
                        icon: "bell",
                        title: "Notifications",
                        action: {
                            // Navigate to notifications settings
                        }
                    )
                    
                    ProfileOptionRow(
                        icon: "questionmark.circle",
                        title: "Help & Support",
                        action: {
                            // Navigate to help
                        }
                    )
                    
                    ProfileOptionRow(
                        icon: "info.circle",
                        title: "About",
                        action: {
                            // Navigate to about
                        }
                    )
                }
                .padding(.horizontal)
                
                Spacer(minLength: 50)
                
                // App info section
                VStack(spacing: 8) {
                    Text("NewsHub v1.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Built with SwiftUI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 32)
            }
        }
        .accessibilityIdentifier("profileHomeView")
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

// MARK: - Toast View Component
struct ToastView: View {
    let message: String
    let isError: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundColor(isError ? .red : .green)
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - Reusable Components

/// Reusable news card component
struct NewsCardView: View {
    let title: String
    let summary: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(summary)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Profile option row component
struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.regularMaterial)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Navigation Destination Views

/// Article detail view (placeholder)
struct ArticleDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Article Title")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("By Author Name • 2 hours ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .cornerRadius(8)
                
                Text("Article content would go here. This is a placeholder for the full article text that users would read.")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Bookmark article
                } label: {
                    Image(systemName: "bookmark")
                }
            }
        }
    }
}

/// Category view (placeholder)
struct CategoryView: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<10, id: \.self) { index in
                    NewsCardView(
                        title: "Category Article \(index + 1)",
                        summary: "This article belongs to the selected category.",
                        onTap: {
                            // Navigate to article detail
                        }
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Category")
        .navigationBarTitleDisplayMode(.large)
    }
}

/// Search results view (placeholder)
struct SearchResultsView: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<5, id: \.self) { index in
                    NewsCardView(
                        title: "Search Result \(index + 1)",
                        summary: "This article matches your search query.",
                        onTap: {
                            // Navigate to article detail
                        }
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Search Results")
        .navigationBarTitleDisplayMode(.large)
    }
}

/// Bookmark categories view (placeholder)
struct BookmarkCategoriesView: View {
    private let categories = ["Technology", "Sports", "Politics", "Entertainment", "Science"]
    
    var body: some View {
        List(categories, id: \.self) { category in
            NavigationLink(category) {
                CategoryBookmarksView(category: category)
            }
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.large)
    }
}

/// Category bookmarks view (placeholder)
struct CategoryBookmarksView: View {
    let category: String
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<3, id: \.self) { index in
                    NewsCardView(
                        title: "\(category) Article \(index + 1)",
                        summary: "This saved article is in the \(category) category.",
                        onTap: {
                            // Navigate to article detail
                        }
                    )
                }
            }
            .padding()
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.large)
    }
}

/// Settings view (placeholder)
struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    
    var body: some View {
        Form {
            Section("Preferences") {
                Toggle("Push Notifications", isOn: $notificationsEnabled)
                Toggle("Dark Mode", isOn: $darkModeEnabled)
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("1")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

// Simple About view for the app
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "newspaper.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("NewsHub")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Stay updated with the latest news from around the world")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Features:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Latest news from multiple sources")
                        Text("• Save articles to favorites")
                        Text("• Search for specific topics")
                        Text("• Clean and modern interface")
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
                .padding()
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

#if canImport(SafariServices)
struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No dynamic updates needed
    }
}
#else
struct SafariWebView: View {
    let url: URL
    var body: some View {
        VStack(spacing: 12) {
            Text("Web view is unavailable on this platform.")
                .font(.headline)
            Link("Open in Browser", destination: url)
        }
        .padding()
    }
}
#endif

#Preview {
    ContentView()
}
