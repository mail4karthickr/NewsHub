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
            fileName: "NewsListHomeScreenTests.swift",
            filePath: "NewsList/NewsListHomeScreenTests.swift",
            description: "Comprehensive UI tests for the NewsList Home screen, covering article list display, pull-to-refresh, infinite scroll, empty and error states, article card UI (including missing fields and truncation), read more navigation and validation, favorites functionality and persistence, offline and lockout scenarios, ordering, localization, and accessibility.",
            testScenarios: [
                // Core List Functionality
                "News list displays articles from API",
                "News list supports pull-to-refresh",
                "News list infinite scroll loads more articles",
                // Empty and Error States
                "News list empty state shows message",
                "Error state shows error message and retry",
                "Offline state shows offline message and saved articles only",
                "Too many failed attempts shows lockout message",
                // Article Card UI
                "Article card shows image, title, description, and buttons",
                "Article card missing image shows placeholder",
                "Article card missing title or description not displayed",
                "Article card title and description truncation",
                // Read More Button
                "Read More button navigates to detail view",
                "Read More button disabled when fields missing shows validation alert",
                // Favorites
                "Favorite button toggles and persists",
                "Favorited articles appear in Saved tab and offline",
                // List Behavior
                "Articles are ordered newest to oldest",
                // Accessibility
                "All interactive elements are accessible"
            ],
            category: "Comprehensive Home Screen"
        )
    ]
}
