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
            description: "Comprehensive UI tests for the NewsList Home screen, covering news list display, pull-to-refresh, news card UI (including image/title/description handling and truncation), Read More navigation, favorites functionality and persistence, data fetching, error and empty states, offline support, accessibility, localization, and UI responsiveness/performance.",
            testScenarios: [
                // News List Display & Refresh
                "News list shows up to 100 articles, newest first",
                "News list pull-to-refresh updates feed",
                // News Card UI
                "News card shows image, title, description, Read More, and Favorite buttons",
                "News card with missing image shows placeholder",
                "News card with missing title shows 'Untitled Article'",
                "News card with long title truncates with ellipsis",
                "News card with missing description shows 'No summary available.'",
                "News card with long description truncates with ellipsis",
                // Read More Navigation
                "Read More button opens detail and returns to previous scroll position",
                // Favorites Functionality
                "Favorite button toggles state and persists",
                "Favorited articles persist across app launches",
                // Data Fetching & Error Handling
                "Loading indicator appears while fetching articles",
                "API failure shows error message and Retry button",
                "Error message auto-dismisses after 5 seconds",
                "API returns zero articles shows empty state",
                "API timeout shows timeout error",
                "API rate limit shows rate limit error",
                "Offline mode shows offline banner and saved articles",
                // Accessibility & Localization
                "Buttons and labels are accessible with VoiceOver",
                "All user messages are localized",
                // UI Responsiveness & Performance
                "News list scrolls smoothly",
                "Initial load is fast (≤ 1 second)"
            ],
            category: "Comprehensive Core Functionality & UI"
        )
    ]
}
