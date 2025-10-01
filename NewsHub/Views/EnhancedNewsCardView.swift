//
//  EnhancedNewsCardView.swift
//  NewsHub
//
//  Created by Karthick Ramasamy on 01/10/25.
//

import SwiftUI
import Combine
import Foundation

struct EnhancedNewsCardView: View {
    let article: Article
    let onTap: () -> Void
    @StateObject private var bookmarkManager = BookmarkManager.shared
    
    var body: some View {
        Button(action: onTap) {
            // NHUB-3: Vertical card layout with image at TOP as specified in the updated story
            VStack(alignment: .leading, spacing: 12) {
                // Image at the TOP of the card (NHUB-3 requirement)
                if article.hasImage {
                    CachedAsyncImage(url: article.urlToImage) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.gray)
                        )
                }
                
                // Content section below the image
                VStack(alignment: .leading, spacing: 8) {
                    // Source and time info at the top
                    HStack {
                        Text(article.source.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text(article.timeAgoString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Title in BOLD directly below image (NHUB-3 requirement)
                    Text(article.title)
                        .font(.headline)
                        .fontWeight(.bold)  // Bold as per NHUB-3
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    
                    // Description - 5-6 lines below title (NHUB-3 requirement)
                    if let description = article.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(6)  // 5-6 lines as per NHUB-3
                    }
                    
                    // Action buttons row below description (NHUB-3 requirement)
                    HStack(spacing: 16) {
                        // Read More Button (NHUB-3 requirement)
                        Button(action: {
                            // This will be handled by the parent onTap
                        }) {
                            HStack(spacing: 4) {
                                Text("Read More")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Image(systemName: "arrow.right")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        // Favorites Button with heart icon (NHUB-3 requirement)
                        Button(action: {
                            bookmarkManager.toggleFavorite(articleId: article.id)
                        }) {
                            Image(systemName: bookmarkManager.isFavorite(article.id) ? "heart.fill" : "heart")
                                .font(.system(size: 18))
                                .foregroundColor(bookmarkManager.isFavorite(article.id) ? .red : .gray)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

// Custom cached async image component
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: String?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var imageData: Data?
    @State private var isLoading = false
    
    private let imageCache = ImageCacheService.shared
    @State private var cancellables = Set<AnyCancellable>()
    
    init(
        url: String?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let imageData = imageData {
                #if canImport(UIKit)
                if let uiImage = UIKit.UIImage(data: imageData) {
                    content(Image(uiImage: uiImage))
                } else {
                    placeholder()
                }
                #else
                placeholder()
                #endif
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        
        isLoading = true
        
        imageCache.loadImage(from: url)
            .sink { data in
                DispatchQueue.main.async {
                    self.imageData = data
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
    }
}

// Error state view
struct NewsErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Failed to load news")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 50)
    }
}

// Empty state view
struct NewsEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No articles found")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Check back later for the latest news")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 50)
    }
}

#Preview {
    VStack {
        EnhancedNewsCardView(
            article: Article(
                source: Source(id: "bbc", name: "BBC News"),
                author: "John Doe",
                title: "Sample News Article Title That Can Be Very Long",
                description: "This is a sample description of the news article that provides more context about the story and what readers can expect to learn.",
                url: "https://example.com/article",
                urlToImage: "https://via.placeholder.com/400x200",
                publishedAt: "2024-01-01T12:00:00Z",
                content: "Full article content..."
            ),
            onTap: {
                print("Article tapped")
            }
        )
        .padding()
        
        Spacer()
    }
}
