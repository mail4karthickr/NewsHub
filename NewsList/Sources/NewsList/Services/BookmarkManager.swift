//
//  BookmarkManager.swift
//  NewsHub
//
//  Created by Karthick Ramasamy on 01/10/25.
//

import Foundation
import Combine

@MainActor
final class BookmarkManager: ObservableObject {
    static let shared = BookmarkManager()
    
    @Published private(set) var favoriteArticles: Set<String> = []
    @Published private(set) var readLaterArticles: Set<String> = []
    
    private let favoritesKey = "FavoriteArticles"
    private let readLaterKey = "ReadLaterArticles"
    
    private init() {
        loadBookmarks()
    }
    
    // MARK: - Public Methods
    
    func isFavorite(_ articleId: String) -> Bool {
        favoriteArticles.contains(articleId)
    }
    
    func isReadLater(_ articleId: String) -> Bool {
        readLaterArticles.contains(articleId)
    }
    
    func toggleFavorite(articleId: String) {
        if favoriteArticles.contains(articleId) {
            favoriteArticles.remove(articleId)
        } else {
            favoriteArticles.insert(articleId)
        }
        saveFavorites()
    }
    
    func toggleReadLater(articleId: String) {
        if readLaterArticles.contains(articleId) {
            readLaterArticles.remove(articleId)
        } else {
            readLaterArticles.insert(articleId)
        }
        saveReadLater()
    }
    
    func addToFavorites(articleId: String) {
        favoriteArticles.insert(articleId)
        saveFavorites()
    }
    
    func removeFromFavorites(articleId: String) {
        favoriteArticles.remove(articleId)
        saveFavorites()
    }
    
    func addToReadLater(articleId: String) {
        readLaterArticles.insert(articleId)
        saveReadLater()
    }
    
    func removeFromReadLater(articleId: String) {
        readLaterArticles.remove(articleId)
        saveReadLater()
    }
    
    // MARK: - Private Methods
    
    private func loadBookmarks() {
        if let favoritesData = UserDefaults.standard.data(forKey: favoritesKey),
           let favorites = try? JSONDecoder().decode(Set<String>.self, from: favoritesData) {
            favoriteArticles = favorites
        }
        
        if let readLaterData = UserDefaults.standard.data(forKey: readLaterKey),
           let readLater = try? JSONDecoder().decode(Set<String>.self, from: readLaterData) {
            readLaterArticles = readLater
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteArticles) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    private func saveReadLater() {
        if let data = try? JSONEncoder().encode(readLaterArticles) {
            UserDefaults.standard.set(data, forKey: readLaterKey)
        }
    }
}

