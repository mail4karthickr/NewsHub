//
//  NewsFeedViewModel.swift
//  NewsHub
//
//  Created by Karthick Ramasamy on 01/10/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor public class NewsFeedViewModel: ObservableObject {
    @Published public private(set) var articles: [Article] = []
    @Published public private(set) var loadingState: LoadingState = .idle
    @Published public private(set) var isRefreshing = false
    @Published public private(set) var isLoadingMore = false
    @Published public private(set) var hasMorePages = true
    
    private let newsService = NewsService.shared
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private let pageSize = 20
    
    public init() {
        loadInitialData()
    }
    
    // MARK: - Public Methods
    
    public func loadInitialData() {
        guard loadingState != .loading else { return }
        
        loadingState = .loading
        currentPage = 1
        
        fetchArticles(page: currentPage, isRefresh: false)
    }
    
    public func refresh() {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        currentPage = 1
        hasMorePages = true
        
        fetchArticles(page: currentPage, isRefresh: true)
    }
    
    public func loadMore() {
        guard !isLoadingMore && hasMorePages && loadingState != .loading else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        fetchArticles(page: currentPage, isRefresh: false)
    }
    
    // Simplified - no filtering, just fetch top headlines
    
    // MARK: - Private Methods
    
    private func fetchArticles(page: Int, isRefresh: Bool) {
        newsService.fetchTopHeadlines(
            category: .general,
            page: page,
            pageSize: pageSize
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                DispatchQueue.main.async {
                    self?.handleCompletion(completion, isRefresh: isRefresh)
                }
            },
            receiveValue: { [weak self] response in
                DispatchQueue.main.async {
                    self?.handleResponse(response, page: page, isRefresh: isRefresh)
                }
            }
        )
        .store(in: &cancellables)
    }
    
    private func handleCompletion(_ completion: Subscribers.Completion<Error>, isRefresh: Bool) {
        isRefreshing = false
        isLoadingMore = false
        
        switch completion {
        case .finished:
            loadingState = .loaded
        case .failure(let error):
            loadingState = .failed(error)
            print("❌ Failed to fetch articles: \(error.localizedDescription)")
        }
    }
    
    private func handleResponse(_ response: NewsResponse, page: Int, isRefresh: Bool) {
        let newArticles = response.articles.filter { article in
            !article.title.lowercased().contains("[removed]") &&
            article.description != nil &&
            !article.description!.isEmpty
        }
        
        if isRefresh || page == 1 {
            articles = newArticles
        } else {
            // Append new articles, avoiding duplicates
            let uniqueArticles = newArticles.filter { newArticle in
                !articles.contains { existingArticle in
                    existingArticle.url == newArticle.url
                }
            }
            articles.append(contentsOf: uniqueArticles)
        }
        
        // Check if there are more pages
        hasMorePages = newArticles.count == pageSize
        loadingState = .loaded
        isRefreshing = false
        isLoadingMore = false
    }
    
    // MARK: - Utility Methods
    
    public func shouldLoadMore(for article: Article) -> Bool {
        guard let lastArticle = articles.last else { return false }
        return article.id == lastArticle.id
    }
    
    // Sources loading removed - simplified for top headlines only
}
