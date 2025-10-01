import SwiftUI
import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SafariServices)
import SafariServices
#endif


public struct WebURLItem: Identifiable {
    public let url: URL
    public var id: String { url.absoluteString }
    public init(url: URL) { self.url = url }
}

@MainActor
public struct NewsHomeView: View {
    typealias AccessibilityIds = NewsListAccessibilityIds.NewsHomeView
    
    @StateObject private var viewModel = NewsFeedViewModel()
    @State private var selectedArticleItem: WebURLItem?

    public init() {}

    public var body: some View {
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
                    ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
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
                        .accessibilityIdentifier(AccessibilityIds.articleCard(at: index))
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
                        .accessibilityIdentifier(AccessibilityIds.loadingMoreIndicator)
                    }

                case .failed(let error):
                    NewsErrorView(error: error) {
                        viewModel.loadInitialData()
                    }
                    .accessibilityIdentifier(AccessibilityIds.errorView)
                }

                if viewModel.articles.isEmpty && viewModel.loadingState == .loaded {
                    NewsEmptyView()
                        .accessibilityIdentifier(AccessibilityIds.emptyStateView)
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

    public func openArticle(_ article: Article) {
        // Present article in a sheet using item binding
        if let url = URL(string: article.url) {
            selectedArticleItem = WebURLItem(url: url)
            print("📰 Opening article modal for: \(article.title)")
        }
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
