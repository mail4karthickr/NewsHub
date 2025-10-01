//
//  NewsListItemView.swift
//  NewsHub
//
//  Created by Karthick Ramasamy on 01/10/25.
//

import SwiftUI
import NewsList
import Foundation

struct NewsListItemView: View {
    let article: Article
    let onReadMore: () -> Void
    let onFavorite: () -> Void
    @StateObject private var bookmarkManager = BookmarkManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image at the top of the news card
            AsyncImage(url: URL(string: article.urlToImage ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
            
            // Content section
            VStack(alignment: .leading, spacing: 8) {
                // Title directly below the image in bold
                Text(article.title)
                    .font(.headline)
                    .fontWeight(.bold)  // Explicitly bold as required
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                // Description below the title - 5-6 lines as specified
                if let description = article.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(6)  // 5-6 lines as per story requirement
                }
                
                // Source and time info
                HStack {
                    Text(article.source.name)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(article.timeAgoString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
                
                // Action buttons row - Read More button and heart icon at trailing edge
                HStack(spacing: 16) {
                    // Read More Button
                    Button(action: onReadMore) {
                        HStack(spacing: 4) {
                            Text("Read More")
                                .font(.callout)
                                .fontWeight(.medium)
                            Image(systemName: "arrow.right")
                                .font(.callout)
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    // Favorites Button with heart icon at trailing edge
                    Button(action: onFavorite) {
                        Image(systemName: bookmarkManager.isFavorite(article.id) ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(bookmarkManager.isFavorite(article.id) ? .red : .gray)
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

// MARK: - Preview
#if DEBUG
struct NewsListItemView_Previews: PreviewProvider {
    static var previews: some View {
        if let previewArticle = createSampleArticle() {
            NewsListItemView(
                article: previewArticle,
                onReadMore: {
                    print("Read More tapped")
                },
                onFavorite: {
                    print("Favorite tapped")
                }
            )
            .padding()
        } else {
            Text("Preview not available")
        }
    }
    
    private static func createSampleArticle() -> Article? {
        // Create sample article for preview
        return Article(
            source: Source(id: "bbc-news", name: "BBC News"),
            author: "Test Author", 
            title: "Sample News Article Title That Can Be Long",
            description: "This is a sample news article description that shows how the layout will look with real content. It should display multiple lines to give users a good overview of the article content.",
            url: "https://example.com/article",
            urlToImage: "https://example.com/image.jpg",
            publishedAt: "2025-10-01T12:00:00Z",
            content: "Full article content here..."
        )
    }
}
#endif
