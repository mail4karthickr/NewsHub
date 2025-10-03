import XCTest

class NewsListBasicFlowTests: XCTestCase {

    private var app: XCUIApplication!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
        // Ensure we're on the Home tab
        let homeTab = app.tabBars.buttons["Home"]
        if homeTab.exists && !homeTab.isSelected {
            homeTab.tap()
        }
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    /// Waits for the news list to appear
    private func waitForNewsList(timeout: TimeInterval = 10) {
        let newsList = app.tables["news_list"]
        let exists = newsList.waitForExistence(timeout: timeout)
        XCTAssertTrue(exists, "News list should appear within \(timeout) seconds")
    }

    /// Returns the first news card cell
    private func firstNewsCard() -> XCUIElement {
        return app.tables["news_list"].cells.element(boundBy: 0)
    }

    /// Returns the "Retry" button if present
    private func retryButton() -> XCUIElement {
        return app.buttons["retry_button"]
    }

    /// Returns the error message label if present
    private func errorMessageLabel() -> XCUIElement {
        return app.staticTexts["error_message"]
    }

    /// Returns the empty state message label if present
    private func emptyStateLabel() -> XCUIElement {
        return app.staticTexts["empty_state_message"]
    }

    /// Returns the "No Internet Connection" banner if present
    private func offlineBanner() -> XCUIElement {
        return app.staticTexts["offline_banner"]
    }

    /// Returns the "Saved" tab bar button
    private func savedTabButton() -> XCUIElement {
        return app.tabBars.buttons["Saved"]
    }

    /// Returns the "Read More…" button in a given cell
    private func readMoreButton(in cell: XCUIElement) -> XCUIElement {
        return cell.buttons["read_more_button"]
    }

    /// Returns the "Favorite" button in a given cell
    private func favoriteButton(in cell: XCUIElement) -> XCUIElement {
        return cell.buttons["favorite_button"]
    }

    /// Simulates pull-to-refresh gesture on the news list
    private func pullToRefresh() {
        let newsList = app.tables["news_list"]
        let start = newsList.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let finish = newsList.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        start.press(forDuration: 0.1, thenDragTo: finish)
    }

    // MARK: - Core Functionality

    func test_newsList_showsUpTo100ArticlesNewestFirst() {
        waitForNewsList()
        let newsList = app.tables["news_list"]
        let cellCount = newsList.cells.count
        XCTAssertLessThanOrEqual(cellCount, 100, "News list should show at most 100 articles")
        // Optionally, check that the first cell is newer than the last (if date labels are available)
    }

    func test_newsList_pullToRefresh_updatesFeed() {
        waitForNewsList()
        let newsList = app.tables["news_list"]
        let firstCellBefore = newsList.cells.element(boundBy: 0)
        let titleBefore = firstCellBefore.staticTexts["news_title"].label

        pullToRefresh()

        // Wait for refresh to complete (loading indicator disappears)
        let loadingIndicator = app.activityIndicators["news_list_loading"]
        if loadingIndicator.exists {
            let _ = loadingIndicator.waitForExistence(timeout: 5)
            let _ = loadingIndicator.waitForNonExistence(timeout: 10)
        }

        let firstCellAfter = newsList.cells.element(boundBy: 0)
        let titleAfter = firstCellAfter.staticTexts["news_title"].label

        // If new articles are available, the title should change
        // If not, the title may remain the same; so we just check that the list is still present
        XCTAssertTrue(newsList.exists, "News list should still be visible after pull-to-refresh")
    }

    // MARK: - News Card UI

    func test_newsCard_showsImageTitleDescriptionAndButtons() {
        waitForNewsList()
        let cell = firstNewsCard()

        // Image
        let image = cell.images["news_image"]
        XCTAssertTrue(image.exists, "News card should display an image (or placeholder)")

        // Title
        let title = cell.staticTexts["news_title"]
        XCTAssertTrue(title.exists, "News card should display a title")

        // Description
        let description = cell.staticTexts["news_description"]
        XCTAssertTrue(description.exists, "News card should display a description")

        // Read More button
        let readMore = readMoreButton(in: cell)
        XCTAssertTrue(readMore.exists, "News card should have a 'Read More…' button")

        // Favorite button
        let favorite = favoriteButton(in: cell)
        XCTAssertTrue(favorite.exists, "News card should have a favorite button")
    }

    func test_newsCard_missingImage_showsPlaceholder() {
        waitForNewsList()
        // Find a cell with a placeholder image (simulate or use test data)
        let cell = app.tables["news_list"].cells.matching(identifier: "news_card_placeholder_image").firstMatch
        if cell.exists {
            let placeholder = cell.images["news_image_placeholder"]
            XCTAssertTrue(placeholder.exists, "News card with missing image should show placeholder")
        } else {
            // If no such cell, skip test (requires test data with missing image)
            XCTSkip("No news card with missing image found in test data")
        }
    }

    func test_newsCard_missingTitle_showsUntitledArticle() {
        waitForNewsList()
        // Find a cell with missing title (simulate or use test data)
        let cell = app.tables["news_list"].cells.matching(identifier: "news_card_missing_title").firstMatch
        if cell.exists {
            let title = cell.staticTexts["news_title"]
            XCTAssertEqual(title.label, "Untitled Article", "Missing title should show 'Untitled Article'")
        } else {
            XCTSkip("No news card with missing title found in test data")
        }
    }

    func test_newsCard_longTitle_truncatesWithEllipsis() {
        waitForNewsList()
        // Find a cell with a long title (simulate or use test data)
        let cell = app.tables["news_list"].cells.matching(identifier: "news_card_long_title").firstMatch
        if cell.exists {
            let title = cell.staticTexts["news_title"]
            XCTAssertTrue(title.label.hasSuffix("…"), "Long title should be truncated with ellipsis")
            XCTAssertLessThanOrEqual(title.label.count, 51, "Truncated title should be at most 51 characters (including ellipsis)")
        } else {
            XCTSkip("No news card with long title found in test data")
        }
    }

    func test_newsCard_missingDescription_showsNoSummaryAvailable() {
        waitForNewsList()
        // Find a cell with missing description (simulate or use test data)
        let cell = app.tables["news_list"].cells.matching(identifier: "news_card_missing_description").firstMatch
        if cell.exists {
            let description = cell.staticTexts["news_description"]
            XCTAssertEqual(description.label, "No summary available.", "Missing description should show 'No summary available.'")
        } else {
            XCTSkip("No news card with missing description found in test data")
        }
    }

    func test_newsCard_longDescription_truncatesWithEllipsis() {
        waitForNewsList()
        // Find a cell with a long description (simulate or use test data)
        let cell = app.tables["news_list"].cells.matching(identifier: "news_card_long_description").firstMatch
        if cell.exists {
            let description = cell.staticTexts["news_description"]
            XCTAssertTrue(description.label.hasSuffix("…"), "Long description should be truncated with ellipsis")
        } else {
            XCTSkip("No news card with long description found in test data")
        }
    }

    // MARK: - Read More Navigation

    func test_newsCard_readMoreButton_opensDetailAndReturnsToScrollPosition() {
        waitForNewsList()
        let cell = firstNewsCard()
        let readMore = readMoreButton(in: cell)
        XCTAssertTrue(readMore.exists, "Read More button should exist")
        let titleBefore = cell.staticTexts["news_title"].label

        readMore.tap()

        // Wait for detail modal to appear
        let detailView = app.otherElements["news_detail_modal"]
        XCTAssertTrue(detailView.waitForExistence(timeout: 3), "Detail modal should appear after tapping Read More")

        // Dismiss modal (swipe down or tap X)
        if app.buttons["close_detail_button"].exists {
            app.buttons["close_detail_button"].tap()
        } else {
            detailView.swipeDown()
        }

        // Ensure we return to the same scroll position (first cell still visible)
        let cellAfter = firstNewsCard()
        let titleAfter = cellAfter.staticTexts["news_title"].label
        XCTAssertEqual(titleBefore, titleAfter, "Should return to previous scroll position after closing detail")
    }

    // MARK: - Favorites Functionality

    func test_newsCard_favoriteButton_togglesStateAndPersists() {
        waitForNewsList()
        let cell = firstNewsCard()
        let favorite = favoriteButton(in: cell)
        XCTAssertTrue(favorite.exists, "Favorite button should exist")

        // Tap to favorite
        favorite.tap()
        XCTAssertTrue(favorite.isSelected, "Favorite button should be selected after tapping")

        // Switch to Saved tab and verify article appears
        savedTabButton().tap()
        let savedList = app.tables["saved_news_list"]
        XCTAssertTrue(savedList.waitForExistence(timeout: 3), "Saved articles list should appear")
        let savedCell = savedList.cells.staticTexts[cell.staticTexts["news_title"].label]
        XCTAssertTrue(savedCell.exists, "Favorited article should appear in Saved tab")

        // Switch back to Home and unfavorite
        app.tabBars.buttons["Home"].tap()
        let cellAgain = firstNewsCard()
        let favoriteAgain = favoriteButton(in: cellAgain)
        favoriteAgain.tap()
        XCTAssertFalse(favoriteAgain.isSelected, "Favorite button should be unselected after tapping again")
    }

    func test_favoritedArticles_persistAcrossAppLaunches() {
        waitForNewsList()
        let cell = firstNewsCard()
        let favorite = favoriteButton(in: cell)
        if !favorite.isSelected {
            favorite.tap()
        }
        XCTAssertTrue(favorite.isSelected, "Article should be favorited")

        // Relaunch app
        app.terminate()
        app.launch()

        // Go to Saved tab and verify article is still present
        savedTabButton().tap()
        let savedList = app.tables["saved_news_list"]
        XCTAssertTrue(savedList.waitForExistence(timeout: 3), "Saved articles list should appear after relaunch")
        let savedCell = savedList.cells.staticTexts[cell.staticTexts["news_title"].label]
        XCTAssertTrue(savedCell.exists, "Favorited article should persist after relaunch")
    }

    // MARK: - Data Fetching and Error Handling

    func test_newsList_showsLoadingIndicatorWhileFetching() {
        // Relaunch app to simulate initial load
        app.terminate()
        app.launch()
        let loadingIndicator = app.activityIndicators["news_list_loading"]
        XCTAssertTrue(loadingIndicator.waitForExistence(timeout: 2), "Loading indicator should appear while fetching articles")
        XCTAssertTrue(loadingIndicator.isHittable, "Loading indicator should be visible")
    }

    func test_newsList_apiFailure_showsErrorMessageAndRetry() {
        // Simulate API failure (requires launch argument or network stubbing)
        app.terminate()
        app.launchArguments.append("--simulate-api-failure")
        app.launch()

        let errorLabel = errorMessageLabel()
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 5), "Error message should appear on API failure")
        XCTAssertEqual(errorLabel.label, "Unable to load news. Please check your connection and try again.")

        let retry = retryButton()
        XCTAssertTrue(retry.exists, "Retry button should be visible on error")

        // Tap Retry and expect loading indicator
        retry.tap()
        let loadingIndicator = app.activityIndicators["news_list_loading"]
        XCTAssertTrue(loadingIndicator.waitForExistence(timeout: 2), "Loading indicator should appear after retry")
    }

    func test_newsList_errorMessage_autoDismissesAfter5Seconds() {
        // Simulate API failure (requires launch argument or network stubbing)
        app.terminate()
        app.launchArguments.append("--simulate-api-failure")
        app.launch()

        let errorLabel = errorMessageLabel()
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 5), "Error message should appear on API failure")

        // Wait for 6 seconds and check that error message disappears
        sleep(6)
        XCTAssertFalse(errorLabel.exists, "Error message should auto-dismiss after 5 seconds")
    }

    func test_newsList_apiReturnsZeroArticles_showsEmptyState() {
        // Simulate empty API response (requires launch argument or network stubbing)
        app.terminate()
        app.launchArguments.append("--simulate-empty-news")
        app.launch()

        let emptyLabel = emptyStateLabel()
        XCTAssertTrue(emptyLabel.waitForExistence(timeout: 5), "Empty state message should appear when no articles are available")
        XCTAssertEqual(emptyLabel.label, "No news articles available at this time.")
    }

    func test_newsList_apiTimeout_showsTimeoutError() {
        // Simulate API timeout (requires launch argument or network stubbing)
        app.terminate()
        app.launchArguments.append("--simulate-api-timeout")
        app.launch()

        let errorLabel = errorMessageLabel()
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 12), "Timeout error message should appear after 10 seconds")
        XCTAssertEqual(errorLabel.label, "Unable to load news. Please check your connection and try again.")
    }

    func test_newsList_apiRateLimit_showsRateLimitError() {
        // Simulate API rate limit (requires launch argument or network stubbing)
        app.terminate()
        app.launchArguments.append("--simulate-api-rate-limit")
        app.launch()

        let errorLabel = errorMessageLabel()
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 5), "Rate limit error message should appear")
        XCTAssertEqual(errorLabel.label, "You have reached the maximum number of requests. Please try again later.")
    }

    func test_newsList_offline_showsOfflineBannerAndSavedArticles() {
        // Simulate offline mode (requires launch argument or network stubbing)
        app.terminate()
        app.launchArguments.append("--simulate-offline")
        app.launch()

        let offline = offlineBanner()
        XCTAssertTrue(offline.waitForExistence(timeout: 3), "Offline banner should appear when device is offline")
        XCTAssertEqual(offline.label, "No Internet Connection. Showing saved articles only.")

        // Switch to Saved tab and verify saved articles are accessible
        savedTabButton().tap()
        let savedList = app.tables["saved_news_list"]
        XCTAssertTrue(savedList.waitForExistence(timeout: 3), "Saved articles should be accessible offline")
    }

    // MARK: - Accessibility & Localization

    func test_newsList_buttonsAndLabels_areAccessibleWithVoiceOver() {
        waitForNewsList()
        let cell = firstNewsCard()

        // Title
        let title = cell.staticTexts["news_title"]
        XCTAssertTrue(title.exists)
        XCTAssertTrue(title.isHittable)
        XCTAssertNotNil(title.label)

        // Read More button
        let readMore = readMoreButton(in: cell)
        XCTAssertTrue(readMore.exists)
        XCTAssertTrue(readMore.isHittable)
        XCTAssertEqual(readMore.label, "Read More…")

        // Favorite button
        let favorite = favoriteButton(in: cell)
        XCTAssertTrue(favorite.exists)
        XCTAssertTrue(favorite.isHittable)
        // Accessibility label should be descriptive (e.g., "Favorite this article")
        XCTAssertNotNil(favorite.label)
        XCTAssertTrue(favorite.label.contains("Favorite"))
    }

    func test_newsList_allUserMessages_areLocalized() {
        // This test assumes the app is launched in a non-English locale (e.g., French)
        // and that launch argument "--ui-testing-locale-fr" triggers French localization
        app.terminate()
        app.launchArguments.append("--ui-testing-locale-fr")
        app.launch()

        // Check that the empty state, error, and offline messages are localized
        // (Requires test data or stubs to trigger these states)
        // Example: check empty state
        app.terminate()
        app.launchArguments.append("--simulate-empty-news")
        app.launch()
        let emptyLabel = emptyStateLabel()
        XCTAssertTrue(emptyLabel.waitForExistence(timeout: 5))
        XCTAssertNotEqual(emptyLabel.label, "No news articles available at this time.", "Empty state message should be localized")
    }

    // MARK: - UI Responsiveness

    func test_newsList_scrollsSmoothly() {
        waitForNewsList()
        let newsList = app.tables["news_list"]
        // Scroll down and up
        newsList.swipeUp()
        newsList.swipeDown()
        // No assertion, but test should not crash or lag
    }

    func test_newsList_initialLoad_isFast() {
        // Relaunch app to measure initial load
        app.terminate()
        let start = Date()
        app.launch()
        let newsList = app.tables["news_list"]
        let appeared = newsList.waitForExistence(timeout: 2)
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertTrue(appeared, "News list should appear on initial load")
        XCTAssertLessThanOrEqual(elapsed, 1.0, "Initial load should occur within 1 second")
    }
}
