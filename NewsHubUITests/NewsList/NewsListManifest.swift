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
            description: "Comprehensive UI and flow tests for the NewsList Home screen, covering article display, data loading, pull-to-refresh, favoriting, error handling, offline mode, validation, edge cases, accessibility, and localization.",
            testScenarios: [
                // Core News List Display
                "News list displays up to 50 unique articles without duplicates",
                "Pull-to-refresh updates articles and maintains list integrity",
                // News Card UI
                "News card displays image, title, description, Read More and Favorite buttons",
                "News card with missing image shows placeholder",
                "News card with missing title shows 'Untitled Article'",
                "News card with missing description shows 'No summary available.'",
                // Favorites Functionality
                "Favoriting an article persists across app launches and appears in Saved tab",
                "Error message shown when favorite save fails",
                "Validation error shown for invalid article data when favoriting",
                // Data Loading and Error Handling
                "Loading state shows shimmer placeholders",
                "API failure shows error message and Retry button",
                "No internet shows 'No Internet Connection' message and offline Saved tab",
                "Empty API response shows empty state message",
                // Data Constraints and Validation
                "Title validation shows red alert for invalid length",
                "Description is truncated at 300 characters with ellipsis",
                // User Interactions and State Management
                "Pull-to-refresh and real-time update of news list",
                "Tapping news card or Read More opens and dismisses detail modal",
                // Edge Cases
                "Favoriting or reading while offline shows 'Not available offline' message",
                "Three consecutive failed fetches disables fetch for 15 minutes",
                "UI resets before retry after failed fetch",
                "Successful fetch shows articles after 2 second delay",
                // Accessibility and Localization
                "All user-facing text is localized",
                "Dates and times are localized to device locale"
            ],
            category: "Comprehensive Home Screen UI & Flow"
        )
    ]
}
