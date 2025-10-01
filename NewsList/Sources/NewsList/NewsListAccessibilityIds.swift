//
//  NewsListAccessibilityIds.swift
//  NewsList
//
//  Created on 01/10/25.
//
//  This file provides a centralized definition of all accessibility identifiers
//  used throughout the NewsList module. It is designed to be easily parseable
//  by LLMs for generating UI test cases.
//
//  Usage:
//  - Reference these identifiers in your SwiftUI views using .accessibilityIdentifier()
//  - Use these identifiers in XCUITest to locate and interact with UI elements
//  - Pass this file to LLMs along with acceptance criteria to generate test cases
//

import Foundation

/// Central registry of all accessibility identifiers used in the NewsList module.
/// Organized by screen/component for easy navigation and test case generation.
public enum NewsListAccessibilityIds {
    
    // MARK: - NewsHomeView (Main News Feed Screen)
    
    /// Accessibility identifiers for the main news feed screen
    public enum NewsHomeView {
        /// Individual article cards in the scrollable feed
        /// Format: "newsArticleCard_0", "newsArticleCard_1", etc.
        /// Note: Index-based for unique identification in lists
        public static func articleCard(at index: Int) -> String {
            "newsArticleCard_\(index)"
        }
        
        /// Loading indicator shown when fetching more articles (pagination)
        public static let loadingMoreIndicator = "loadingMoreIndicator"
        
        /// Error view displayed when article loading fails
        public static let errorView = "errorView"
        
        /// Empty state view shown when no articles are available
        public static let emptyStateView = "emptyStateView"
        
        /// Retry button within the error view
        public static let errorRetryButton = "errorRetryButton"
    }
    
    // MARK: - NewsListItemView (Article Card Component)
    
    /// Accessibility identifiers for individual article card components
    /// This is the main article card shown in the feed
    public enum ArticleCard {
        /// Article preview image at the top of the card
        public static let image = "articleImage"
        
        /// Article title text (bold, 3 lines max)
        public static let title = "articleTitle"
        
        /// Article description/summary text (5-6 lines)
        public static let description = "articleDescription"
        
        /// News source name (e.g., "BBC News", "CNN")
        public static let source = "articleSource"
        
        /// Time ago string (e.g., "2 hours ago", "1 day ago")
        public static let time = "articleTime"
        
        /// "Read More" button to open full article modal
        public static let readMoreButton = "readMoreButton"
        
        /// Heart icon button to add/remove from favorites
        /// AccessibilityLabel changes: "Add to favorites" / "Remove from favorites"
        public static let favoriteButton = "favoriteButton"
    }
    
    // MARK: - ArticleModalView (Full Article Detail Screen)
    
    /// Accessibility identifiers for the full article modal/detail view
    public enum ArticleModal {
        /// Full-size article image at the top of modal
        public static let image = "modalArticleImage"
        
        /// Article title in the modal
        public static let title = "modalArticleTitle"
        
        /// News source name in the modal
        public static let source = "modalArticleSource"
        
        /// Publication time/date in the modal
        public static let time = "modalArticleTime"
        
        /// Article author name (optional, only shown if available)
        public static let author = "modalArticleAuthor"
        
        /// Article description text in the modal
        public static let description = "modalArticleDescription"
        
        /// Full article content text in the modal
        public static let content = "modalArticleContent"
        
        /// Button to open the full article in Safari browser
        public static let readFullArticleButton = "readFullArticleButton"
        
        /// Button to share the article (opens share sheet)
        public static let shareButton = "shareArticleButton"
        
        /// Close button (X icon) to dismiss the modal
        public static let closeButton = "closeModalButton"
    }
    
    // MARK: - CompactFilterView (Filter Controls)
    
    /// Accessibility identifiers for filter UI components
    public enum Filters {
        /// Button to clear all active filters at once
        public static let clearAllButton = "clearAllFiltersButton"
        
        /// Button to open the full filter sheet with all options
        public static let moreFiltersButton = "moreFiltersButton"
        
        /// Category filter chips in horizontal scroll view
        /// Format: "categoryFilter_0" (Business), "categoryFilter_1" (Sports), etc.
        /// Indices: 0=Business, 1=Sports, 2=Technology, 3=Health, 4=Science, 5=Entertainment, 6=All
        public static func categoryChip(at index: Int) -> String {
            "categoryFilter_\(index)"
        }
        
        /// Date range filter chips in horizontal scroll view
        /// Format: "dateFilter_0" (All), "dateFilter_1" (Today), "dateFilter_2" (Last Week)
        /// Indices: 0=All, 1=Today, 2=Last Week
        public static func dateChip(at index: Int) -> String {
            "dateFilter_\(index)"
        }
        
        /// Selected news source filter chip
        public static let sourceChip = "sourceFilterChip"
        
        /// Loading indicator for news sources
        public static let sourceLoading = "sourceFilterLoading"
    }
    
    // MARK: - CompactFilterSheet (Full Filter Screen)
    
    /// Accessibility identifiers for the full filter selection sheet
    public enum FilterSheet {
        /// Category filter options in the sheet
        /// Format: "filterSheetCategory_0", "filterSheetCategory_1", etc.
        /// Note: Matches all NewsCategory enum cases
        public static func categoryOption(at index: Int) -> String {
            "filterSheetCategory_\(index)"
        }
        
        /// Date range filter options in the sheet
        /// Format: "filterSheetDate_0", "filterSheetDate_1", etc.
        public static func dateOption(at index: Int) -> String {
            "filterSheetDate_\(index)"
        }
        
        /// Button to open custom date range picker
        public static let customDateRangeButton = "customDateRangeButton"
        
        /// News source filter options in the sheet
        /// Format: "filterSheetSource_0", "filterSheetSource_1", etc.
        /// Note: Supports up to 20 sources, index-based
        public static func sourceOption(at index: Int) -> String {
            "filterSheetSource_\(index)"
        }
        
        /// Reset button to clear all filters in the sheet
        public static let resetButton = "filterSheetResetButton"
        
        /// Done button to apply filters and close the sheet
        public static let doneButton = "filterSheetDoneButton"
    }
    
    // MARK: - CustomDateRangeSheet (Custom Date Picker)
    
    /// Accessibility identifiers for custom date range selection
    public enum CustomDateRange {
        /// "From" date picker component
        public static let fromDatePicker = "customDateFromPicker"
        
        /// "To" date picker component
        public static let toDatePicker = "customDateToPicker"
        
        /// Cancel button to dismiss without applying
        public static let cancelButton = "customDateCancelButton"
        
        /// Apply button to confirm and apply the selected date range
        public static let applyButton = "customDateApplyButton"
    }
    
    // MARK: - EnhancedNewsCardView (Alternative Card Layout)
    
    /// Accessibility identifiers for the enhanced news card layout
    /// Note: This is an alternative card design, may not be in current use
    public enum EnhancedCard {
        /// "Read More" button in enhanced card
        public static let readMoreButton = "enhancedReadMoreButton"
        
        /// Favorite button in enhanced card
        /// AccessibilityLabel changes: "Add to favorites" / "Remove from favorites"
        public static let favoriteButton = "enhancedFavoriteButton"
    }
}

// MARK: - Accessibility ID Guidelines for Test Generation

/*
 GUIDELINES FOR LLM TEST CASE GENERATION:
 
 1. LIST ITEMS WITH INDICES:
    - Use the provided functions like articleCard(at:), categoryChip(at:), etc.
    - Example: NewsListAccessibilityIds.NewsHomeView.articleCard(at: 0)
    - Indices start at 0 and increment for each item in the list
 
 2. DYNAMIC ACCESSIBILITY LABELS:
    - Favorite buttons change labels based on state
    - Check accessibility label to verify state: "Add to favorites" vs "Remove from favorites"
 
 3. NAVIGATION FLOW:
    - Home Feed → Tap article card → Article Modal → Tap close button → Back to Feed
    - Home Feed → Tap "More Filters" → Filter Sheet → Select options → Tap "Done" → Back to Feed
 
 4. COMMON TEST SCENARIOS:
 
    a) View Article Details:
       - Tap NewsHomeView.articleCard(at: 0)
       - Verify ArticleModal.title exists
       - Verify ArticleModal.description exists
       - Tap ArticleModal.closeButton
 
    b) Add/Remove Favorite:
       - Find element with ArticleCard.favoriteButton
       - Verify accessibility label is "Add to favorites"
       - Tap the button
       - Verify accessibility label changes to "Remove from favorites"
       - Tap again to toggle back
 
    c) Filter Articles by Category:
       - Tap Filters.categoryChip(at: 1) // Sports
       - Wait for content to reload
       - Verify first article is related to selected category
 
    d) Apply Multiple Filters:
       - Tap Filters.moreFiltersButton
       - Tap FilterSheet.categoryOption(at: 2) // Technology
       - Tap FilterSheet.dateOption(at: 1) // Today
       - Tap FilterSheet.doneButton
       - Verify filtered content loads
 
    e) Clear All Filters:
       - Tap Filters.clearAllButton
       - Verify all filter chips return to default state
       - Verify content reloads with no filters
 
    f) Custom Date Range:
       - Tap Filters.moreFiltersButton
       - Tap FilterSheet.customDateRangeButton
       - Interact with CustomDateRange.fromDatePicker
       - Interact with CustomDateRange.toDatePicker
       - Tap CustomDateRange.applyButton
       - Verify FilterSheet shows selected date range
 
    g) Share Article:
       - Tap NewsHomeView.articleCard(at: 0)
       - Tap ArticleModal.shareButton
       - Verify share sheet appears
       - Dismiss share sheet
 
    h) Open in Safari:
       - Tap NewsHomeView.articleCard(at: 0)
       - Tap ArticleModal.readFullArticleButton
       - Verify Safari opens (note: may require additional permissions)
 
    i) Error State Handling:
       - Simulate network error
       - Verify NewsHomeView.errorView exists
       - Tap NewsHomeView.errorRetryButton
       - Verify error view disappears and content loads
 
    j) Empty State:
       - Apply filters that return no results
       - Verify NewsHomeView.emptyStateView exists
       - Clear filters to restore content
 
    k) Infinite Scroll/Pagination:
       - Scroll to bottom of feed
       - Verify NewsHomeView.loadingMoreIndicator appears
       - Wait for new articles to load
       - Verify new article cards are added
 
 5. WAITING STRATEGIES:
    - Use waitForExistence(timeout:) for asynchronous content loading
    - After filter changes, wait for loadingMoreIndicator or content updates
    - Network requests may take 1-5 seconds, adjust timeouts accordingly
 
 6. ELEMENT QUERIES:
    - Use app.buttons[identifier] for buttons
    - Use app.staticTexts[identifier] for text labels
    - Use app.images[identifier] for images
    - Use app.scrollViews for scrollable content
    - Use app.sheets for modal presentations
 
 7. ASSERTIONS:
    - Verify element.exists for presence checks
    - Verify element.isHittable for interactive elements
    - Check element.label for accessibility label verification
    - Use XCTAssertEqual, XCTAssertTrue, XCTAssertFalse as appropriate
 
 8. BEST PRACTICES:
    - Always start tests from a known state (launch app, navigate to home)
    - Clean up state after tests (clear favorites, reset filters)
    - Use descriptive test method names that explain the scenario
    - Group related tests in test classes by feature/screen
    - Add comments explaining complex test logic
    - Handle potential flakiness with appropriate waits and retries
 
 EXAMPLE TEST CLASS STRUCTURE:
 
 ```swift
 import XCTest
 
 final class NewsHomeViewTests: XCTestCase {
     var app: XCUIApplication!
     
     override func setUp() {
         super.setUp()
         continueAfterFailure = false
         app = XCUIApplication()
         app.launch()
     }
     
     func testViewArticleDetails() {
         // Tap first article
         let firstArticle = app.buttons[NewsListAccessibilityIds.NewsHomeView.articleCard(at: 0)]
         XCTAssertTrue(firstArticle.waitForExistence(timeout: 5))
         firstArticle.tap()
         
         // Verify modal appears
         let modalTitle = app.staticTexts[NewsListAccessibilityIds.ArticleModal.title]
         XCTAssertTrue(modalTitle.waitForExistence(timeout: 2))
         
         // Close modal
         let closeButton = app.buttons[NewsListAccessibilityIds.ArticleModal.closeButton]
         closeButton.tap()
         
         // Verify back at home
         XCTAssertTrue(firstArticle.waitForExistence(timeout: 2))
     }
     
     func testAddToFavorites() {
         let favoriteButton = app.buttons[NewsListAccessibilityIds.ArticleCard.favoriteButton].firstMatch
         XCTAssertTrue(favoriteButton.waitForExistence(timeout: 5))
         
         // Verify initial state
         XCTAssertEqual(favoriteButton.label, "Add to favorites")
         
         // Add to favorites
         favoriteButton.tap()
         
         // Verify state changed
         XCTAssertEqual(favoriteButton.label, "Remove from favorites")
     }
     
     func testFilterByCategory() {
         // Tap Sports category chip
         let sportsChip = app.buttons[NewsListAccessibilityIds.Filters.categoryChip(at: 1)]
         XCTAssertTrue(sportsChip.waitForExistence(timeout: 5))
         sportsChip.tap()
         
         // Wait for content to reload
         let loadingIndicator = app.otherElements[NewsListAccessibilityIds.NewsHomeView.loadingMoreIndicator]
         _ = loadingIndicator.waitForExistence(timeout: 2)
         
         // Verify articles loaded
         let firstArticle = app.buttons[NewsListAccessibilityIds.NewsHomeView.articleCard(at: 0)]
         XCTAssertTrue(firstArticle.waitForExistence(timeout: 5))
     }
 }
 ```
 
 */
