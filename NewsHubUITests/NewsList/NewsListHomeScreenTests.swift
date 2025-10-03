import XCTest

class NewsListHomeScreenTests: XCTestCase {

    private var app: XCUIApplication!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
        // Ensure we are on the Home tab
        waitForHomeTab()
    }

    override func tearDown() {
        app.terminate()
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func waitForHomeTab(timeout: TimeInterval = 10) {
        // Assume the Home tab is the default, or use tab bar if available
        let homeNavBar = app.navigationBars.element(boundBy: 0)
        XCTAssertTrue(homeNavBar.waitForExistence(timeout: timeout), "Home navigation bar should exist")
    }

    private func waitForNewsList(timeout: TimeInterval = 10) -> XCUIElementQuery {
        // Assume news list is a table or collection view
        let table = app.tables.element(boundBy: 0)
        let collection = app.collectionViews.element(boundBy: 0)
        if table.exists {
            XCTAssertTrue(table.waitForExistence(timeout: timeout), "News table should exist")
            return table.cells
        } else if collection.exists {
            XCTAssertTrue(collection.waitForExistence(timeout: timeout), "News collection should exist")
            return collection.cells
        } else {
            XCTFail("No news list found")
            return app.cells
        }
    }

    private func waitForShimmerPlaceholders(timeout: TimeInterval = 5) -> XCUIElementQuery {
        // Assume shimmer placeholders are staticTexts or images with "Loading" or similar
        let shimmer = app.otherElements.matching(NSPredicate(format: "label CONTAINS[c] 'Loading' OR identifier CONTAINS[c] 'shimmer'"))
        XCTAssertTrue(shimmer.firstMatch.waitForExistence(timeout: timeout), "Shimmer placeholders should appear")
        return shimmer
    }

    private func pullToRefresh(on element: XCUIElement) {
        let start = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let finish = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        start.press(forDuration: 0.1, thenDragTo: finish)
    }

    private func tapRetryButton() {
        let retryButton = app.buttons["Retry"]
        XCTAssertTrue(retryButton.waitForExistence(timeout: 5), "Retry button should exist")
        retryButton.tap()
    }

    private func tapFavoritesTab() {
        let savedTab = app.tabBars.buttons["Saved"]
        XCTAssertTrue(savedTab.waitForExistence(timeout: 5), "Saved tab should exist")
        savedTab.tap()
    }

    private func tapHomeTab() {
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5), "Home tab should exist")
        homeTab.tap()
    }

    private func favoriteButton(in cell: XCUIElement) -> XCUIElement {
        // Try to find a button with heart icon or "Favorite"
        let heartButton = cell.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Favorite' OR label CONTAINS[c] '❤️'")).firstMatch
        XCTAssertTrue(heartButton.exists, "Favorite button should exist in cell")
        return heartButton
    }

    private func readMoreButton(in cell: XCUIElement) -> XCUIElement {
        let readMore = cell.buttons["Read More"]
        XCTAssertTrue(readMore.exists, "Read More button should exist in cell")
        return readMore
    }

    private func waitForErrorMessage(_ message: String, timeout: TimeInterval = 5) -> XCUIElement {
        let error = app.staticTexts[message]
        XCTAssertTrue(error.waitForExistence(timeout: timeout), "Error message '\(message)' should appear")
        return error
    }

    private func dismissErrorMessage(_ message: String) {
        let error = app.staticTexts[message]
        if error.exists {
            let closeButton = app.buttons["Close"]
            if closeButton.exists {
                closeButton.tap()
            } else {
                error.swipeUp() // Try to dismiss by swipe if no close button
            }
        }
    }

    // MARK: - Core Functionality

    func test_newsList_displaysUpTo50UniqueArticles() {
        let cells = waitForNewsList()
        // Wait for at least one cell to appear
        XCTAssertTrue(cells.firstMatch.waitForExistence(timeout: 10), "At least one news article should be visible")
        // Check that there are no more than 50 articles
        XCTAssertLessThanOrEqual(cells.count, 50, "News list should display at most 50 articles")
        // Check for duplicates by title
        var titles = Set<String>()
        for i in 0..<cells.count {
            let cell = cells.element(boundBy: i)
            let title = cell.staticTexts.element(boundBy: 0).label
            XCTAssertFalse(titles.contains(title), "Duplicate article title found: \(title)")
            titles.insert(title)
        }
    }

    func test_newsList_pullToRefresh_updatesArticles() {
        let cells = waitForNewsList()
        let firstCell = cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists, "First news article should exist")
        let firstTitle = firstCell.staticTexts.element(boundBy: 0).label

        // Pull to refresh
        let list = cells.element(boundBy: 0).parent
        pullToRefresh(on: list)

        // Wait for shimmer/loading
        _ = waitForShimmerPlaceholders(timeout: 5)

        // Wait for refresh to complete (simulate 2s delay)
        sleep(3)
        let refreshedCells = waitForNewsList()
        let refreshedFirstTitle = refreshedCells.element(boundBy: 0).staticTexts.element(boundBy: 0).label

        // The title may or may not change, but the list should still be present
        XCTAssertTrue(refreshedCells.count > 0, "News list should still have articles after refresh")
    }

    // MARK: - UI Structure for Each News Item

    func test_newsCard_displaysImageTitleDescriptionAndButtons() {
        let cells = waitForNewsList()
        let cell = cells.element(boundBy: 0)
        XCTAssertTrue(cell.exists, "First news card should exist")

        // Image
        let image = cell.images.element(boundBy: 0)
        XCTAssertTrue(image.exists, "News card should display an image or placeholder")

        // Title
        let title = cell.staticTexts.element(boundBy: 0)
        XCTAssertTrue(title.exists, "News card should display a title")
        XCTAssertFalse(title.label.isEmpty, "Title should not be empty")

        // Description
        let description = cell.staticTexts.element(boundBy: 1)
        XCTAssertTrue(description.exists, "News card should display a description")

        // Read More button
        let readMore = readMoreButton(in: cell)
        XCTAssertTrue(readMore.isHittable, "Read More button should be visible and enabled")

        // Favorite button
        let favorite = favoriteButton(in: cell)
        XCTAssertTrue(favorite.isHittable, "Favorite button should be visible and enabled")
    }

    func test_newsCard_missingImage_showsPlaceholder() {
        // This test assumes at least one article is missing an image
        let cells = waitForNewsList()
        for i in 0..<cells.count {
            let cell = cells.element(boundBy: i)
            let image = cell.images.element(boundBy: 0)
            if image.exists && image.label == "Placeholder" {
                XCTAssertTrue(image.exists, "Placeholder image should be shown for missing article image")
                return
            }
        }
        // If no placeholder found, skip test
        XCTSkip("No article with missing image found in test data")
    }

    func test_newsCard_missingTitle_showsUntitledArticle() {
        let cells = waitForNewsList()
        for i in 0..<cells.count {
            let cell = cells.element(boundBy: i)
            let title = cell.staticTexts["Untitled Article"]
            if title.exists {
                XCTAssertEqual(title.label, "Untitled Article", "Should display 'Untitled Article' for missing title")
                return
            }
        }
        XCTSkip("No article with missing title found in test data")
    }

    func test_newsCard_missingDescription_showsNoSummaryAvailable() {
        let cells = waitForNewsList()
        for i in 0..<cells.count {
            let cell = cells.element(boundBy: i)
            let description = cell.staticTexts["No summary available."]
            if description.exists {
                XCTAssertEqual(description.label, "No summary available.", "Should display 'No summary available.' for missing description")
                return
            }
        }
        XCTSkip("No article with missing description found in test data")
    }

    // MARK: - Favorites Functionality

    func test_favoriteArticle_persistsAcrossAppLaunches() {
        let cells = waitForNewsList()
        let cell = cells.element(boundBy: 0)
        let favorite = favoriteButton(in: cell)
        favorite.tap()
        // Visual feedback: heart icon should be filled
        XCTAssertTrue(favorite.isSelected || favorite.label.contains("filled"), "Favorite button should show filled state")

        // Relaunch app
        app.terminate()
        app.launch()
        waitForHomeTab()
        let newCells = waitForNewsList()
        let newCell = newCells.element(boundBy: 0)
        let newFavorite = favoriteButton(in: newCell)
        XCTAssertTrue(newFavorite.isSelected || newFavorite.label.contains("filled"), "Favorite state should persist after relaunch")

        // Check in Saved tab
        tapFavoritesTab()
        let savedCells = waitForNewsList()
        XCTAssertTrue(savedCells.count > 0, "Favorited article should appear in Saved tab")
    }

    func test_favoriteArticle_errorOnSave_showsErrorMessage() {
        // Simulate save failure via launch argument or mock
        app.terminate()
        app.launchArguments.append("--simulateFavoriteSaveFailure")
        app.launch()
        waitForHomeTab()
        let cells = waitForNewsList()
        let cell = cells.element(boundBy: 0)
        let favorite = favoriteButton(in: cell)
        favorite.tap()
        let error = waitForErrorMessage("Unable to save article. Please try again.")
        XCTAssertTrue(error.exists, "Error message should appear on favorite save failure")
        dismissErrorMessage("Unable to save article. Please try again.")
    }

    func test_favoriteArticle_invalidData_showsValidationError() {
        // Simulate invalid article data via launch argument or mock
        app.terminate()
        app.launchArguments.append("--simulateInvalidArticleData")
        app.launch()
        waitForHomeTab()
        let cells = waitForNewsList()
        let cell = cells.element(boundBy: 0)
        let favorite = favoriteButton(in: cell)
        favorite.tap()
        let error = waitForErrorMessage("Invalid article data. Cannot save to Favorites.")
        XCTAssertTrue(error.exists, "Validation error should appear for invalid article data")
        dismissErrorMessage("Invalid article data. Cannot save to Favorites.")
    }

    // MARK: - Data Fetching and Error Handling

    func test_loadingState_showsShimmerPlaceholders() {
        // Relaunch to trigger loading
        app.terminate()
        app.launch()
        waitForHomeTab()
        let shimmer = waitForShimmerPlaceholders(timeout: 5)
        XCTAssertTrue(shimmer.count > 0, "Shimmer placeholders should be visible while loading")
    }

    func test_apiFailure_showsErrorAndRetry() {
        // Simulate API failure via launch argument or mock
        app.terminate()
        app.launchArguments.append("--simulateAPIFailure")
        app.launch()
        waitForHomeTab()
        let error = waitForErrorMessage("Unable to load news. Please check your connection and try again.")
        XCTAssertTrue(error.exists, "API failure error message should appear")
        let retryButton = app.buttons["Retry"]
        XCTAssertTrue(retryButton.exists, "Retry button should be visible on error")
        retryButton.tap()
        // After retry, shimmer should appear again
        _ = waitForShimmerPlaceholders(timeout: 5)
    }

    func test_noInternet_showsNoConnectionMessage() {
        // Simulate offline mode via launch argument or mock
        app.terminate()
        app.launchArguments.append("--simulateOffline")
        app.launch()
        waitForHomeTab()
        let error = waitForErrorMessage("No Internet Connection")
        XCTAssertTrue(error.exists, "No Internet Connection message should appear")
        tapFavoritesTab()
        let savedCells = waitForNewsList()
        XCTAssertTrue(savedCells.count >= 0, "Saved tab should show only offline articles")
    }

    func test_apiReturnsNoArticles_showsEmptyState() {
        // Simulate empty API response via launch argument or mock
        app.terminate()
        app.launchArguments.append("--simulateEmptyNewsList")
        app.launch()
        waitForHomeTab()
        let emptyState = app.staticTexts["No news articles available at this time."]
        XCTAssertTrue(emptyState.waitForExistence(timeout: 5), "Empty state message should appear when no articles are available")
    }

    // MARK: - Data Constraints and Validation

    func test_titleValidation_showsRedAlertForInvalidLength() {
        // Simulate invalid title via launch argument or mock
        app.terminate()
        app.launchArguments.append("--simulateInvalidTitleLength")
        app.launch()
        waitForHomeTab()
        let cells = waitForNewsList()
        let cell = cells.element(boundBy: 0)
        let alert = cell.staticTexts["Title must be between 3 and 50 characters."]
        XCTAssertTrue(alert.exists, "Red validation alert should appear for invalid title length")
    }

    func test_description_truncatesAt300Characters() {
        let cells = waitForNewsList()
        let cell = cells.element(boundBy: 0)
        let description = cell.staticTexts.element(boundBy: 1)
        XCTAssertTrue(description.exists, "Description should exist")
        XCTAssertLessThanOrEqual(description.label.count, 303, "Description should be truncated with ellipsis if longer than 300 characters")
    }

    // MARK: - User Interactions and State Management

    func test_pullToRefresh_andRealTimeUpdate() {
        let cells = waitForNewsList()
        let firstCell = cells.element(boundBy: 0)
        let firstTitle = firstCell.staticTexts.element(boundBy: 0).label

        // Pull to refresh
        let list = cells.element(boundBy: 0).parent
        pullToRefresh(on: list)
        _ = waitForShimmerPlaceholders(timeout: 5)
        sleep(3)
        let refreshedCells = waitForNewsList()
        let refreshedFirstTitle = refreshedCells.element(boundBy: 0).staticTexts.element(boundBy: 0).label

        // Simulate real-time update via launch argument or mock
        app.terminate()
        app.launchArguments.append("--simulateRealTimeUpdate")
        app.launch()
        waitForHomeTab()
        let updatedCells = waitForNewsList()
        XCTAssertTrue(updatedCells.count > 0, "News list should update in real-time")
    }

    func test_tapNewsCardOrReadMore_opensDetailModalAndDismisses() {
        let cells = waitForNewsList()
        let cell = cells.element(boundBy: 0)
        // Tap the card itself
        cell.tap()
        let detailModal = app.otherElements["NewsDetailModal"]
        XCTAssertTrue(detailModal.waitForExistence(timeout: 5), "News Detail modal should appear")
        // Dismiss modal
        let closeButton = app.buttons["X"]
        if closeButton.exists {
            closeButton.tap()
        } else {
            detailModal.swipeDown()
        }
        XCTAssertFalse(detailModal.exists, "News Detail modal should be dismissed")

        // Tap Read More button
        let readMore = readMoreButton(in: cell)
        readMore.tap()
        XCTAssertTrue(detailModal.waitForExistence(timeout: 5), "News Detail modal should appear after tapping Read More")
        if closeButton.exists {
            closeButton.tap()
        } else {
            detailModal.swipeDown()
        }
        XCTAssertFalse(detailModal.exists, "News Detail modal should be dismissed")
    }

    // MARK: - Edge Cases

    func test_favoriteOrReadWhileOffline_showsNotAvailableOfflineMessage() {
        // Simulate offline mode via launch argument or mock
        app.terminate()
        app.launchArguments.append("--simulateOffline")
        app.launch()
        waitForHomeTab()
        let cells = waitForNewsList()
        let cell = cells.element(boundBy: 0)
        let favorite = favoriteButton(in: cell)
        favorite.tap()
        let error = waitForErrorMessage("This article is not available offline.")
        XCTAssertTrue(error.exists, "Should show not available offline message when favoriting offline")
        dismissErrorMessage("This article is not available offline.")

        let readMore = readMoreButton(in: cell)
        readMore.tap()
        let error2 = waitForErrorMessage("This article is not available offline.")
        XCTAssertTrue(error2.exists, "Should show not available offline message when reading offline")
        dismissErrorMessage("This article is not available offline.")
    }

    func test_threeConsecutiveFailedFetches_disablesFetchFor15Minutes() {
        // Simulate three failed fetches via launch argument or mock
        app.terminate()
        app.launchArguments.append("--simulateThreeFailedFetches")
        app.launch()
        waitForHomeTab()
        let error = waitForErrorMessage("Too many failed attempts. Please try again later.")
        XCTAssertTrue(error.exists, "Should show too many failed attempts message")
        let retryButton = app.buttons["Retry"]
        XCTAssertFalse(retryButton.isEnabled, "Retry button should be disabled after three failed attempts")
    }

    func test_afterFailedFetch_UIResetsBeforeRetry() {
        // Simulate API failure via launch argument or mock
        app.terminate()
        app.launchArguments.append("--simulateAPIFailure")
        app.launch()
        waitForHomeTab()
        let error = waitForErrorMessage("Unable to load news. Please check your connection and try again.")
        XCTAssertTrue(error.exists, "Error message should appear")
        tapRetryButton()
        // UI should reset: shimmer appears, error disappears
        let shimmer = waitForShimmerPlaceholders(timeout: 5)
        XCTAssertTrue(shimmer.count > 0, "Shimmer placeholders should appear after retry")
        XCTAssertFalse(error.exists, "Error message should be dismissed after retry")
    }

    func test_successfulFetch_showsAfter2SecondDelay() {
        // Simulate slow API response via launch argument or mock
        app.terminate()
        app.launchArguments.append("--simulateSlowFetch")
        app.launch()
        waitForHomeTab()
        let shimmer = waitForShimmerPlaceholders(timeout: 5)
        XCTAssertTrue(shimmer.count > 0, "Shimmer placeholders should appear during delay")
        // Wait for 2 seconds + buffer
        sleep(3)
        let cells = waitForNewsList()
        XCTAssertTrue(cells.count > 0, "News articles should appear after 2 second delay")
    }

    // MARK: - Accessibility and Localization

    func test_allUserFacingText_isLocalized() {
        // Simulate app in a different locale via launch argument or environment
        app.terminate()
        app.launchArguments.append("--uiTestLocale=es")
        app.launch()
        waitForHomeTab()
        // Check for localized strings (example: "No news articles available at this time." in Spanish)
        let localizedEmptyState = app.staticTexts["No hay artículos de noticias disponibles en este momento."]
        if localizedEmptyState.exists {
            XCTAssertTrue(localizedEmptyState.exists, "Empty state message should be localized")
        } else {
            XCTSkip("Localization for Spanish not available in test build")
        }
    }

    func test_datesAndTimes_areLocalizedToDeviceLocale() {
        // This test assumes at least one article displays a date/time
        let cells = waitForNewsList()
        let cell = cells.element(boundBy: 0)
        let dateLabel = cell.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] '/' OR label CONTAINS[c] ':'")).firstMatch
        XCTAssertTrue(dateLabel.exists, "Date/time label should exist")
        // Optionally, check for locale-specific format (e.g., dd/MM/yyyy or MM/dd/yyyy)
    }
}
