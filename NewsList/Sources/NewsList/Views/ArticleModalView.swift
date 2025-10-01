//
//  ArticleModalView.swift  
//  NewsHub
//
//  Created by Karthick Ramasamy on 01/10/25.
//

import SwiftUI
import Foundation
import WebKit

struct ArticleModalView: View {
    typealias AccessibilityIds = NewsListAccessibilityIds.ArticleModal
    let article: Article
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Article Image
                    AsyncImage(url: URL(string: article.urlToImage ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: 250)
                            .clipped()
                            .cornerRadius(12)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxWidth: .infinity, maxHeight: 250)
                            .cornerRadius(12)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                            )
                    }
                    .accessibilityIdentifier(AccessibilityIds.image)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Article Title
                        Text(article.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .accessibilityIdentifier(AccessibilityIds.title)
                        
                        // Source and Time
                        HStack {
                            Text(article.source.name)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                                .accessibilityIdentifier(AccessibilityIds.source)
                            
                            Spacer()
                            
                            Text(article.timeAgoString)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .accessibilityIdentifier(AccessibilityIds.time)
                        }
                        
                        // Author if available
                        if let author = article.author, !author.isEmpty {
                            Text("By \(author)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .accessibilityIdentifier(AccessibilityIds.author)
                        }
                        
                        Divider()
                        
                        // Article Description/Content
                        if let description = article.description, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .lineSpacing(4)
                                .accessibilityIdentifier(AccessibilityIds.description)
                        }
                        
                        if let content = article.content, !content.isEmpty {
                            Text(content)
                                .font(.body)
                                .lineSpacing(4)
                                .foregroundColor(.secondary)
                                .accessibilityIdentifier(AccessibilityIds.content)
                        }
                        
                        Spacer(minLength: 40)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            // Read Full Article Button
                            Button(action: openInSafari) {
                                HStack {
                                    Image(systemName: "safari")
                                    Text("Read Full Article")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            .accessibilityIdentifier(AccessibilityIds.readFullArticleButton)
                            
                            // Share Button
                            Button(action: shareArticle) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Article")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .accessibilityIdentifier(AccessibilityIds.shareButton)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Article Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .accessibilityLabel("Close article")
                    .accessibilityIdentifier(AccessibilityIds.closeButton)
                }
            }
        }
    }
    
    private func openInSafari() {
        if let url = URL(string: article.url) {
            #if canImport(UIKit)
            UIApplication.shared.open(url)
            #endif
        }
    }
    
    private func shareArticle() {
        #if canImport(UIKit)
        let items = [article.title, article.url].compactMap { $0 }
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityController, animated: true)
        }
        #endif
    }
}

// MARK: - Preview

#if DEBUG
struct ArticleModalView_Previews: PreviewProvider {
    static var previews: some View {
        if let previewArticle = createSampleArticle() {
            ArticleModalView(article: previewArticle)
        } else {
            Text("Preview not available")
        }
    }
    
    private static func createSampleArticle() -> Article? {
        return Article(
            source: Source(id: "bbc-news", name: "BBC News"),
            author: "Test Author", 
            title: "Sample News Article Title",
            description: "This is a sample description",
            url: "https://www.bbc.com/news/sample-article",
            urlToImage: "https://example.com/image.jpg",
            publishedAt: "2025-10-01T12:00:00Z",
            content: "Sample content"
        )
    }
}
#endif