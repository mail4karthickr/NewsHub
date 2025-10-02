//
//  NewsListManifest.swift
//  NewsListUITests
//
//  This manifest file serves as a central registry and documentation for NewsList feature UI test files.
//  It helps LLMs and developers understand the test structure, locate test files, and understand 
//  what each test file contains for the NewsList feature.
//
//  PURPOSE:
//  - Provide a single source of truth for all NewsList UI test files and their contents
//  - Help LLMs understand the NewsList test organization and generate new test cases
//  - Document NewsList feature test coverage and test scenarios
//  - Enable easy navigation and maintenance of NewsList test suite
//
//  USAGE FOR LLMs:
//  When generating new test files for NewsList:
//  1. Read this manifest to understand existing NewsList test coverage
//  2. Use the structure and patterns defined here
//  3. Add new entries to this manifest when creating new NewsList test files
//  4. Follow the naming conventions: NewsList<TestScenario>Tests.swift
//  5. Place test files in the NewsList folder alongside this manifest
//

import Foundation

/// Central manifest for all NewsList UI test files
/// This structure provides metadata about each test file for easy discovery and understanding
struct NewsListManifest {
    
    // MARK: - Manifest Entry Structure
    
    /// Represents a single UI test file with its metadata
    struct TestFileEntry {
        /// Name of the test file (e.g., "NewsListBasicFlowTests.swift")
        let fileName: String
        
        /// Relative path from NewsListUITests/NewsList directory
        let filePath: String
        
        /// Brief description of what this test file covers
        let description: String
        
        /// List of test scenarios/cases contained in this file
        let testScenarios: [String]
        
        /// Category of tests (e.g., "Happy Path", "Error Handling", "Edge Cases", "Performance")
        let category: String
    }
    
    // MARK: - NewsList Test File Registry
    // LLMs should add new entries here when creating test files for NewsList
    // Each entry represents a test file focusing on specific scenarios or flows
    static let allTestFiles: [TestFileEntry] = [
        TestFileEntry(
            fileName: "NewsListBasicFlowTests.swift",
            filePath: "NewsList/NewsListBasicFlowTests.swift",
            description: "Comprehensive UI tests for the NewsList Home Feed, covering initial load, empty and error states, data fetching, pull-to-refresh, loading indicators, article card UI, favorites, infinite scroll, pagination, modal presentation, localization, state persistence, and edge/error cases including lockout and invalid input.",
            testScenarios: [
                // Home Feed & Display
                "Home feed displays news list by default",
                "Home feed shows empty state when no articles",
                // Data Fetching & Refresh
                "Pull to refresh fetches latest articles",
                "Slow API response shows loading indicator after 2 seconds",
                // Error Handling
                "API failure shows error and retry",
                "Error message auto-dismisses after 5 seconds",
                // Article Card UI
                "Article card shows image, title, description, and buttons",
                "Article card with missing image shows placeholder",
                "Article card with missing title or description is omitted",
                // Read More & Modal
                "Tapping Read More button opens article modal",
                "Tapping article card opens article modal",
                // Favorites
                "Favorite button toggles favorite state and persists",
                "Favorited articles persist across app launches",
                // Infinite Scroll & Pagination
                "Infinite scroll loads more articles",
                "Scrolling to end shows end of feed message",
                // Error & Edge Cases
                "Three consecutive failures show lockout message and disable list",
                "After lockout period, user can retry fetching articles",
                "Invalid input shows standardized error message",
                // Pull to Refresh (Error Recovery)
                "Pull to refresh while error shows loading and recovers",
                // Localization
                "All user-visible messages are localized"
            ],
            category: "Happy Path, Error Handling, Edge Cases, State Persistence, Localization"
        )
    ]
}
