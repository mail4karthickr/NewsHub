//
//  NewsService.swift
//  NewsHub
//
//  Created by Karthick Ramasamy on 01/10/25.
//

import Foundation
import Combine

class NewsService: ObservableObject {
    static let shared = NewsService()
    
    private let apiKey = "36abe08b45174f0fa75b3d03bfac2c4f"
    private let baseURL = "https://newsapi.org/v2"
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Cache for articles
    private var articlesCache: [String: [Article]] = [:]
    private var lastFetchTime: [String: Date] = [:]
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes
    
    private init() {}
    
    // MARK: - Public API
    
    /// Fetch top headlines for a specific category
    func fetchTopHeadlines(
        category: NewsCategory = .general,
        country: String = "us",
        page: Int = 1,
        pageSize: Int = 20
    ) -> AnyPublisher<NewsResponse, Error> {
        
        let cacheKey = "\(category.rawValue)_\(country)_\(page)"
        
        // Check cache first
        if let cachedArticles = getCachedArticles(for: cacheKey),
           let lastFetch = lastFetchTime[cacheKey],
           Date().timeIntervalSince(lastFetch) < cacheValidityDuration {
            
            let cachedResponse = NewsResponse(
                status: "ok",
                totalResults: cachedArticles.count,
                articles: cachedArticles
            )
            return Just(cachedResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        var components = URLComponents(string: "\(baseURL)/top-headlines")!
        components.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "category", value: category.rawValue),
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)")
        ]
        
        guard let url = components.url else {
            return Fail(error: NewsAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: NewsResponse.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { [weak self] response in
                // Cache the results
                self?.cacheArticles(response.articles, for: cacheKey)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Search articles
    func searchArticles(
        query: String,
        sortBy: String = "publishedAt",
        page: Int = 1,
        pageSize: Int = 20
    ) -> AnyPublisher<NewsResponse, Error> {
        
        var components = URLComponents(string: "\(baseURL)/everything")!
        components.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "sortBy", value: sortBy),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "language", value: "en")
        ]
        
        guard let url = components.url else {
            return Fail(error: NewsAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: NewsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Fetch available news sources
    func fetchSources(
        category: String? = nil,
        language: String = "en",
        country: String? = nil
    ) -> AnyPublisher<SourcesResponse, Error> {
        
        var components = URLComponents(string: "\(baseURL)/sources")!
        var queryItems = [URLQueryItem(name: "apiKey", value: apiKey)]
        
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        queryItems.append(URLQueryItem(name: "language", value: language))
        if let country = country {
            queryItems.append(URLQueryItem(name: "country", value: country))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            return Fail(error: NewsAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: SourcesResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Cache Management
    
    private func cacheArticles(_ articles: [Article], for key: String) {
        articlesCache[key] = articles
        lastFetchTime[key] = Date()
    }
    
    private func getCachedArticles(for key: String) -> [Article]? {
        return articlesCache[key]
    }
    
    func clearCache() {
        articlesCache.removeAll()
        lastFetchTime.removeAll()
    }
}

// MARK: - Error Types

enum NewsAPIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case rateLimitExceeded
    case apiKeyInvalid
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        case .apiKeyInvalid:
            return "Invalid API key"
        }
    }
}

// MARK: - Image Cache Service

class ImageCacheService: ObservableObject {
    static let shared = ImageCacheService()
    
    private let cache = NSCache<NSString, NSData>()
    private let session = URLSession.shared
    
    private init() {
        // Configure cache
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func loadImage(from urlString: String) -> AnyPublisher<Data?, Never> {
        // Check cache first
        if let cachedData = cache.object(forKey: urlString as NSString) {
            return Just(cachedData as Data)
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: urlString) else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map { data, response -> Data? in
                // Cache the image data
                self.cache.setObject(data as NSData, forKey: urlString as NSString)
                return data
            }
            .catch { _ in Just(nil) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
