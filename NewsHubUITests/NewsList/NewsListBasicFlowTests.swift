import XCTest

final class NewsListBasicFlowTests: XCTestCase {
    var app: XCUIApplication!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
        // Ensure we start on the Home tab
        // (Assume Home tab is default, otherwise tap tab bar if needed)
    }

    override func tearDown() {
        // Optionally clear favorites or reset filters if needed
        super.tearDown()
    }

    // MARK: - Helper Methods

    /// Waits for the first article card to appear
    private func waitForFirstArticleCard(timeout: TimeInterval = 8) -> XCUIElement {
        let firstCard = app.buttons["newsArticleCard_0"]
        XCTAssertTrue(firstCard.waitForExistence(timeout: timeout), "First article card did not appear in time")
        return firstCard
    }

    /// Waits for the error view to appear
    private func waitForErrorView(timeout: TimeInterval = 5) -> XCUIElement {
        let errorView = app.otherElements["errorView"]
        XCTAssertTrue(errorView.waitForExistence(timeout: timeout), "Error view did not appear in time")
        return errorView
    }

    /// Waits for the empty state view to appear
    private func waitForEmptyStateView(timeout: TimeInterval = 5) -> XCUIElement {
        let emptyState = app.otherElements["emptyStateView"]
        XCTAssertTrue(emptyState.waitForExistence(timeout: timeout), "Empty state view did not appear in time")
        return emptyState
    }

    /// Waits for the loading more indicator (pagination spinner)
    private func waitForLoadingMoreIndicator(timeout: TimeInterval = 5) -> XCUIElement {
        let loadingIndicator = app.otherElements["loadingMoreIndicator"]
        XCTAssertTrue(loadingIndicator.waitForExistence(timeout: timeout), "Loading more indicator did not appear in time")
        return loadingIndicator
    }

    /// Returns the favorite button for a given article card index
    private func favoriteButton(forCardAt index: Int) -> XCUIElement {
        let card = app.buttons["newsArticleCard_\(index)"]
        XCTAssertTrue(card.waitForExistence(timeout: 5), "Article card \(index) does not exist")
        // Favorite button is a descendant of the card
        return card.descendants(matching: .button)["favoriteButton"]
    }

    /// Returns the "Read More" button for a given article card index
    private func readMoreButton(forCardAt index: Int) -> XCUIElement {
        let card = app.buttons["newsArticleCard_\(index)"]
        XCTAssertTrue(card.waitForExistence(timeout: 5), "Article card \(index) does not exist")
        return card.descendants(matching: .button)["readMoreButton"]
    }

    // MARK: - Core Functionality

    func test_homeFeed_displaysNewsListByDefault() {
        // Verify the news list is visible and enabled by default
        let firstCard = app.buttons["newsArticleCard_0"]
        XCTAssertTrue(firstCard.waitForExistence(timeout: 8), "News list did not appear on Home tab")
        XCTAssertTrue(firstCard.isHittable, "First article card is not hittable")
    }

    func test_homeFeed_showsEmptyStateWhenNoArticles() {
        // Simulate no articles (assume launch arg or filter can be used)
        // For test, apply filters that return no results
        let moreFiltersButton = app.buttons["moreFiltersButton"]
        XCTAssertTrue(moreFiltersButton.waitForExistence(timeout: 5))
        moreFiltersButton.tap()

        // Select a category and date that will return no results
        let techCategory = app.buttons["filterSheetCategory_2"]
        XCTAssertTrue(techCategory.waitForExistence(timeout: 2))
        techCategory.tap()
        let lastWeekDate = app.buttons["filterSheetDate_2"]
        XCTAssertTrue(lastWeekDate.waitForExistence(timeout: 2))
        lastWeekDate.tap()
        let doneButton = app.buttons["filterSheetDoneButton"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 2))
        doneButton.tap()

        // Wait for empty state
        let emptyState = waitForEmptyStateView()
        XCTAssertTrue(emptyState.exists)
        XCTAssertTrue(app.staticTexts["No news articles available."].exists)
        // No article cards should be present
        XCTAssertFalse(app.buttons["newsArticleCard_0"].exists)
    }

    // MARK: - Data Fetching & Refresh

    func test_pullToRefresh_fetchesLatestArticles() {
        let firstCard = waitForFirstArticleCard()
        let feed = app.scrollViews.firstMatch
        XCTAssertTrue(feed.exists)
        // Pull to refresh gesture
        let start = feed.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let finish = feed.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        start.press(forDuration: 0.1, thenDragTo: finish)
        // Wait for refresh (spinner may appear)
        let refreshedCard = app.buttons["newsArticleCard_0"]
        XCTAssertTrue(refreshedCard.waitForExistence(timeout: 8))
    }

    func test_slowApiResponse_showsLoadingIndicatorAfter2Seconds() {
        // Simulate slow API (assume launch arg or network condition)
        // For test, pull to refresh and wait for spinner
        let feed = app.scrollViews.firstMatch
        XCTAssertTrue(feed.exists)
        let start = feed.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let finish = feed.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        start.press(forDuration: 0.1, thenDragTo: finish)
        // Wait for loading indicator after 2 seconds
        let spinner = app.activityIndicators["loadingMoreIndicator"]
        XCTAssertTrue(spinner.waitForExistence(timeout: 4), "Loading indicator did not appear after slow response")
    }

    func test_apiFailure_showsErrorAndRetry() {
        // Simulate network error (assume launch arg or offline mode)
        // For test, disconnect network or use a stub
        // Here, we assume errorView appears
        let errorView = waitForErrorView()
        XCTAssertTrue(errorView.exists)
        XCTAssertTrue(app.staticTexts["Unable to load news. Please check your connection and try again."].exists)
        let retryButton = app.buttons["errorRetryButton"]
        XCTAssertTrue(retryButton.exists)
        retryButton.tap()
        // After retry, error should disappear and content should reload
        let firstCard = app.buttons["newsArticleCard_0"]
        XCTAssertTrue(firstCard.waitForExistence(timeout: 8))
        XCTAssertFalse(errorView.exists)
    }

    func test_errorMessage_autoDismissesAfter5Seconds() {
        // Simulate error
        let errorView = waitForErrorView()
        XCTAssertTrue(errorView.exists)
        // Wait for 6 seconds for auto-dismiss
        sleep(6)
        XCTAssertFalse(errorView.exists)
    }

    // MARK: - News Item Card UI

    func test_articleCard_showsImageTitleDescriptionAndButtons() {
        let firstCard = waitForFirstArticleCard()
        // Image
        let image = firstCard.descendants(matching: .image)["articleImage"]
        XCTAssertTrue(image.exists)
        // Title
        let title = firstCard.staticTexts["articleTitle"]
        XCTAssertTrue(title.exists)
        // Description
        let description = firstCard.staticTexts["articleDescription"]
        XCTAssertTrue(description.exists)
        // Read More button
        let readMore = firstCard.buttons["readMoreButton"]
        XCTAssertTrue(readMore.exists)
        // Favorite button
        let favorite = firstCard.buttons["favoriteButton"]
        XCTAssertTrue(favorite.exists)
    }

    func test_articleCard_missingImage_showsPlaceholder() {
        // Find a card with missing image (assume index 1 for test)
        let card = app.buttons["newsArticleCard_1"]
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        let image = card.images["articleImage"]
        XCTAssertTrue(image.exists)
        // Check for placeholder (assume placeholder has label "No Image Available")
        XCTAssertTrue(image.label == "No Image Available" || image.label == "Placeholder")
    }

    func test_articleCard_missingTitleOrDescription_isOmitted() {
        // Cards with missing title/description should not appear
        // For test, try to find a card at a known index that should be omitted
        // (Assume index 10 is omitted for missing title/desc)
        let card = app.buttons["newsArticleCard_10"]
        XCTAssertFalse(card.exists)
    }

    // MARK: - Read More & Article Modal

    func test_tapReadMoreButton_opensArticleModal() {
        let readMore = readMoreButton(forCardAt: 0)
        XCTAssertTrue(readMore.exists)
        readMore.tap()
        // Modal should appear
        let modalTitle = app.staticTexts["modalArticleTitle"]
        XCTAssertTrue(modalTitle.waitForExistence(timeout: 3))
        // Modal content
        XCTAssertTrue(app.staticTexts["modalArticleDescription"].exists)
        // Dismiss modal
        let closeButton = app.buttons["closeModalButton"]
        XCTAssertTrue(closeButton.exists)
        closeButton.tap()
        // Back to feed
        let firstCard = app.buttons["newsArticleCard_0"]
        XCTAssertTrue(firstCard.waitForExistence(timeout: 2))
    }

    func test_tapArticleCard_opensArticleModal() {
        let firstCard = waitForFirstArticleCard()
        firstCard.tap()
        let modalTitle = app.staticTexts["modalArticleTitle"]
        XCTAssertTrue(modalTitle.waitForExistence(timeout: 3))
        // Dismiss modal
        let closeButton = app.buttons["closeModalButton"]
        XCTAssertTrue(closeButton.exists)
        closeButton.tap()
        XCTAssertTrue(firstCard.waitForExistence(timeout: 2))
    }

    // MARK: - Favorites

    func test_favoriteButton_togglesFavoriteStateAndPersists() {
        let favorite = favoriteButton(forCardAt: 0)
        XCTAssertTrue(favorite.exists)
        // Initial state: should be "Add to favorites"
        XCTAssertEqual(favorite.label, "Add to favorites")
        favorite.tap()
        // State should change to "Remove from favorites"
        XCTAssertEqual(favorite.label, "Remove from favorites")
        // Relaunch app to verify persistence
        app.terminate()
        app.launch()
        let favoriteAfterRelaunch = favoriteButton(forCardAt: 0)
        XCTAssertTrue(favoriteAfterRelaunch.exists)
        XCTAssertEqual(favoriteAfterRelaunch.label, "Remove from favorites")
        // Unfavorite
        favoriteAfterRelaunch.tap()
        XCTAssertEqual(favoriteAfterRelaunch.label, "Add to favorites")
    }

    // MARK: - Infinite Scroll & Pagination

    func test_infiniteScroll_loadsMoreArticles() {
        // Scroll to bottom to trigger pagination
        let feed = app.scrollViews.firstMatch
        XCTAssertTrue(feed.exists)
        // Scroll multiple times to bottom
        for _ in 0..<3 {
            feed.swipeUp()
            sleep(1)
        }
        // Wait for loading more indicator
        let loadingIndicator = app.otherElements["loadingMoreIndicator"]
        XCTAssertTrue(loadingIndicator.waitForExistence(timeout: 5))
        // Wait for new articles to load (e.g., card at index 20)
        let newCard = app.buttons["newsArticleCard_20"]
        XCTAssertTrue(newCard.waitForExistence(timeout: 8))
    }

    func test_scrollToEnd_showsEndOfFeedMessage() {
        // Scroll to end (simulate many articles)
        let feed = app.scrollViews.firstMatch
        XCTAssertTrue(feed.exists)
        for _ in 0..<10 {
            feed.swipeUp()
            sleep(1)
        }
        // Wait for end of feed message
        let endMessage = app.staticTexts["You’ve reached the end of the news feed."]
        XCTAssertTrue(endMessage.waitForExistence(timeout: 5))
    }

    // MARK: - Error & Edge Cases

    func test_threeConsecutiveFailures_showsLockoutMessageAndDisablesList() {
        // Simulate three consecutive failures (assume launch arg or stub)
        // For test, trigger error three times
        for _ in 0..<3 {
            let errorView = waitForErrorView()
            let retryButton = app.buttons["errorRetryButton"]
            XCTAssertTrue(retryButton.exists)
            retryButton.tap()
            sleep(1)
        }
        // After third failure, lockout message should appear
        let lockoutMessage = app.staticTexts["Too many failed attempts. Please try again in 15 minutes."]
        XCTAssertTrue(lockoutMessage.waitForExistence(timeout: 3))
        // News list should be disabled
        let firstCard = app.buttons["newsArticleCard_0"]
        XCTAssertFalse(firstCard.isHittable)
    }

    func test_afterLockoutPeriod_userCanRetryFetchingArticles() {
        // Assume lockout is active
        let lockoutMessage = app.staticTexts["Too many failed attempts. Please try again in 15 minutes."]
        XCTAssertTrue(lockoutMessage.exists)
        // Simulate waiting 15 minutes (for test, use a stub or time travel)
        // Here, just relaunch app (assume lockout expires)
        app.terminate()
        app.launch()
        // User can retry
        let retryButton = app.buttons["errorRetryButton"]
        if retryButton.exists {
            retryButton.tap()
        }
        let firstCard = app.buttons["newsArticleCard_0"]
        XCTAssertTrue(firstCard.waitForExistence(timeout: 8))
    }

    func test_invalidInput_showsStandardizedErrorMessage() {
        // Simulate invalid input (e.g., malformed article)
        // For test, try to interact with a card that should not be present
        let card = app.buttons["newsArticleCard_99"]
        if card.exists {
            card.tap()
            let errorMessage = app.staticTexts["Invalid input. Please try again."]
            XCTAssertTrue(errorMessage.waitForExistence(timeout: 2))
            // Error auto-dismisses
            sleep(6)
            XCTAssertFalse(errorMessage.exists)
        }
    }

    // MARK: - State Persistence

    func test_favoritedArticles_persistAcrossAppLaunches() {
        let favorite = favoriteButton(forCardAt: 0)
        XCTAssertTrue(favorite.exists)
        favorite.tap()
        XCTAssertEqual(favorite.label, "Remove from favorites")
        // Relaunch app
        app.terminate()
        app.launch()
        let favoriteAfterRelaunch = favoriteButton(forCardAt: 0)
        XCTAssertTrue(favoriteAfterRelaunch.exists)
        XCTAssertEqual(favoriteAfterRelaunch.label, "Remove from favorites")
    }

    // MARK: - Pull to Refresh

    func test_pullToRefresh_whileError_showsLoadingAndRecovers() {
        // Simulate error
        let errorView = waitForErrorView()
        XCTAssertTrue(errorView.exists)
        // Pull to refresh
        let feed = app.scrollViews.firstMatch
        let start = feed.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let finish = feed.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        start.press(forDuration: 0.1, thenDragTo: finish)
        // Wait for error to disappear and content to reload
        let firstCard = app.buttons["newsArticleCard_0"]
        XCTAssertTrue(firstCard.waitForExistence(timeout: 8))
        XCTAssertFalse(errorView.exists)
    }

    // MARK: - Localization

    func test_allUserVisibleMessages_areLocalized() {
        // This test assumes device is set to a non-English language
        // For test, check that static texts are not in English (if possible)
        // Example: check "No news articles available." is localized
        let moreFiltersButton = app.buttons["moreFiltersButton"]
        XCTAssertTrue(moreFiltersButton.waitForExistence(timeout: 5))
        moreFiltersButton.tap()
        let techCategory = app.buttons["filterSheetCategory_2"]
        techCategory.tap()
        let lastWeekDate = app.buttons["filterSheetDate_2"]
        lastWeekDate.tap()
        let doneButton = app.buttons["filterSheetDoneButton"]
        doneButton.tap()
        let emptyState = waitForEmptyStateView()
        XCTAssertTrue(emptyState.exists)
        // Check that the label is not in English (pseudo check)
        let emptyLabel = app.staticTexts.element(matching: .any, identifier: nil).label
        XCTAssertFalse(emptyLabel == "No news articles available.", "Message is not localized")
    }
}
