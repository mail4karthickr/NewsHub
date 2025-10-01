//
//  NewsModels.swift
//  NewsHub
//
//  Created by Karthick Ramasamy on 01/10/25.
//

import Foundation

// MARK: - NewsAPI Response Models

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable, Identifiable, Equatable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
    
    // Generate ID based on URL for uniqueness
    var id: String {
        return url
    }
    
    // Computed properties for UI
    var publishedDate: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: publishedAt) ?? Date()
    }
    
    var timeAgoString: String {
        let now = Date()
        let interval = now.timeIntervalSince(publishedDate)
        
        if interval < 3600 { // Less than 1 hour
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 { // Less than 1 day
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else { // More than 1 day
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
    
    var hasImage: Bool {
        urlToImage != nil && !urlToImage!.isEmpty
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.url == rhs.url
    }
}

struct Source: Codable {
    let id: String?
    let name: String
}

// MARK: - Loading States

enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case failed(Error)
    
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.loaded, .loaded):
            return true
        case (.failed, .failed):
            return true // Consider all errors equal for UI purposes
        default:
            return false
        }
    }
}

// MARK: - News Categories

enum NewsCategory: String, CaseIterable {
    case all = "all"
    case general = "general"  
    case business = "business"
    case entertainment = "entertainment"
    case health = "health"
    case science = "science"
    case sports = "sports"
    case technology = "technology"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .general: return "Top Headlines"
        case .business: return "Business"
        case .entertainment: return "Entertainment"
        case .health: return "Health"
        case .science: return "Science"
        case .sports: return "Sports"
        case .technology: return "Technology"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .general: return "newspaper"
        case .business: return "briefcase"
        case .entertainment: return "tv"
        case .health: return "cross.case"
        case .science: return "atom"
        case .sports: return "sportscourt"
        case .technology: return "laptopcomputer"
        }
    }
}

// MARK: - Date Filter Models

enum DateFilter: CaseIterable, Identifiable {
    case all
    case today
    case lastWeek
    case lastMonth
    case custom(from: Date, to: Date)
    
    var id: String {
        switch self {
        case .all: return "all"
        case .today: return "today"
        case .lastWeek: return "lastWeek"
        case .lastMonth: return "lastMonth"
        case .custom(let from, let to): return "custom_\(from.timeIntervalSince1970)_\(to.timeIntervalSince1970)"
        }
    }
    
    static var allCases: [DateFilter] {
        return [.all, .today, .lastWeek, .lastMonth]
    }
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .today: return "Today"
        case .lastWeek: return "Last 7 Days"
        case .lastMonth: return "Last 30 Days"
        case .custom(let from, let to):
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return "\(formatter.string(from: from)) - \(formatter.string(from: to))"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "calendar"
        case .today: return "calendar.badge.clock"
        case .lastWeek: return "calendar.badge.minus"
        case .lastMonth: return "calendar.circle"
        case .custom: return "calendar.badge.exclamationmark"
        }
    }
    
    var dateRange: (from: Date?, to: Date?) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .all:
            return (nil, nil)
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            return (startOfDay, now)
        case .lastWeek:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return (weekAgo, now)
        case .lastMonth:
            let monthAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            return (monthAgo, now)
        case .custom(let from, let to):
            return (from, to)
        }
    }
    
    func isEqual(to other: DateFilter) -> Bool {
        switch (self, other) {
        case (.all, .all), (.today, .today), (.lastWeek, .lastWeek), (.lastMonth, .lastMonth):
            return true
        case (.custom(let from1, let to1), .custom(let from2, let to2)):
            return from1 == from2 && to1 == to2
        default:
            return false
        }
    }
}

// MARK: - Source Filter Models

struct NewsSource: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let description: String?
    let url: String?
    let category: String?
    let language: String?
    let country: String?
    
    static let all = NewsSource(
        id: "all",
        name: "All Sources",
        description: "All available news sources",
        url: nil,
        category: nil,
        language: nil,
        country: nil
    )
}

struct SourcesResponse: Codable {
    let status: String
    let sources: [NewsSource]
}
