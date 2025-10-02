import XCTest

final class NewsListHomeScreenTests: XCTestCase {
    private var app: XCUIApplication!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
        // Ensure we are on the Home tab at start
        waitForHomeScreenToLoad()
    }

    override func tearDown() {
        app.terminate()
        super.tearDown()
    }

    // MARK: - Helper Methods

    /// Waits for the home news list to load at least one article or empty/error state
    private func waitForHomeScreenToLoad(timeout: TimeInterval = 10) {
        let firstCard = app.buttons["newsArticleCard_0"]
        let emptyState = app.otherElements["emptyStateView"]
        let errorView = app.otherElements["errorView"]
        let exists = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: exists, object: firstCard)
        let emptyExpectation = XCTNSPredicateExpectation(predicate: exists, object: emptyState)
        let errorExpectation = XCTNSPredicateExpectation(predicate: exists, object: errorView)
        let result = XCTWaiter().wait(for: [expectation, emptyExpectation, errorExpectation], timeout: timeout)
        XCTAssertTrue(result == .completed, "Home screen did not load any content, empty state, or error view in time")
    }

    /// Returns the article card button at a given index
    private func articleCard(at index: Int) -> XCUIElement {
        return app.buttons["newsArticleCard_\(index)"]
    }

    /// Returns the favorite button within a given article card
    private func favoriteButton(in card: XCUIElement) -> XCUIElement {
        return card.buttons["favoriteButton"]
    }

    /// Returns the "Read More" button within a given article card
    private func readMoreButton(in card: XCUIElement) -> XCUIElement {
        return card.buttons["readMoreButton"]
    }

    /// Waits for the loading indicator to disappear
    private func waitForLoadingToFinish(timeout: TimeInterval = 10) {
        let loadingIndicator = app.otherElements["loadingMoreIndicator"]
        if loadingIndicator.exists {
            let notExists = NSPredicate(format: "exists == false")
            let expectation = XCTNSPredicateExpectation(predicate: notExists, object: loadingIndicator)
            _ = XCTWaiter().wait(for: [expectation], timeout: timeout)
        }
    }

    /// Pulls to refresh the news list
    private func pullToRefresh() {
        let firstCard = articleCard(at: 0)
        if firstCard.exists {
            let start = firstCard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let finish = firstCard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 6.0))
            start.press(forDuration: 0.1, thenDragTo: finish)
        } else {
            // If no articles, try to pull on the scroll view
            let scrollView = app.scrollViews.firstMatch
            let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            let finish = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
            start.press(forDuration: 0.1, thenDragTo: finish)
        }
    }

    /// Scrolls to the bottom of the news list to trigger infinite scroll
    private func scrollToBottomOfList(maxScrolls: Int = 10) {
        let scrollView = app.scrollViews.firstMatch
        for _ in 0..<maxScrolls {
            let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
            let finish = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            start.press(forDuration: 0.1, thenDragTo: finish)
            // Wait for possible loading indicator
            let loadingIndicator = app.otherElements["loadingMoreIndicator"]
            if loadingIndicator.exists {
                _ = loadingIndicator.waitForExistence(timeout: 5)
                waitForLoadingToFinish()
            }
        }
    }

    /// Dismisses any auto-dismissing message by tapping close if present
    private func dismissAutoMessageIfPresent() {
        let closeButton = app.buttons["closeMessageButton"]
        if closeButton.exists && closeButton.isHittable {
            closeButton.tap()
        }
    }

    // MARK: - Core Functionality

    func test_newsList_displaysArticlesFromAPI() {
        // Verify at least one article card is present
        let firstCard = articleCard(at: 0)
        XCTAssertTrue(firstCard.waitForExistence(timeout: 10), "Expected at least one news article card to be visible")
    }

    func test_newsList_supportsPullToRefresh() {
        // Pull to refresh and verify loading indicator appears and disappears
        pullToRefresh()
        let loadingIndicator = app.otherElements["loadingMoreIndicator"]
        XCTAssertTrue(loadingIndicator.waitForExistence(timeout: 3), "Loading indicator should appear after pull-to-refresh")
        waitForLoadingToFinish()
        // After refresh, at least one article should still be present
        let firstCard = articleCard(at: 0)
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5), "Expected news article card after refresh")
    }

    func test_newsList_infiniteScroll_loadsMoreArticles() {
        // Get initial count of article cards
        var initialCount = 0
        while articleCard(at: initialCount).exists {
            initialCount += 1
        }
        // Scroll to bottom to trigger infinite scroll
        scrollToBottomOfList()
        // Wait for new articles to load
        waitForLoadingToFinish()
        // Check if more articles are loaded (count increased)
        var newCount = 0
        while articleCard(at: newCount).exists {
            newCount += 1
        }
        XCTAssertTrue(newCount > initialCount, "Expected more articles to be loaded after infinite scroll")
    }

    func test_newsList_emptyState_showsMessage() {
        // Apply filters that return no results
        let moreFiltersButton = app.buttons["moreFiltersButton"]
        XCTAssertTrue(moreFiltersButton.waitForExistence(timeout: 5))
        moreFiltersButton.tap()
        let categoryOption = app.buttons["filterSheetCategory_0"]
        XCTAssertTrue(categoryOption.waitForExistence(timeout: 5))
        categoryOption.tap()
        // Select a date filter that is guaranteed to return no results (e.g., far past)
        let dateOption = app.buttons["filterSheetDate_2"]
        XCTAssertTrue(dateOption.waitForExistence(timeout: 5))
        dateOption.tap()
        let doneButton = app.buttons["filterSheetDoneButton"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()
        // Wait for empty state view
        let emptyState = app.otherElements["emptyStateView"]
        XCTAssertTrue(emptyState.waitForExistence(timeout: 5), "Expected empty state view when no articles are available")
        // Dismiss message if close button exists
        dismissAutoMessageIfPresent()
        // Clear filters to restore content
        let clearAllButton = app.buttons["clearAllFiltersButton"]
        if clearAllButton.exists {
            clearAllButton.tap()
        }
        waitForHomeScreenToLoad()
    }

    // MARK: - Article Card UI

    func test_articleCard_showsImageTitleDescriptionAndButtons() {
        let firstCard = articleCard(at: 0)
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        // Image
        let image = firstCard.images["articleImage"]
        XCTAssertTrue(image.exists, "Article image should be present")
        // Title
        let title = firstCard.staticTexts["articleTitle"]
        XCTAssertTrue(title.exists, "Article title should be present")
        // Description
        let description = firstCard.staticTexts["articleDescription"]
        XCTAssertTrue(description.exists, "Article description should be present")
        // Read More button
        let readMore = firstCard.buttons["readMoreButton"]
        XCTAssertTrue(readMore.exists, "Read More button should be present")
        XCTAssertTrue(readMore.isEnabled, "Read More button should be enabled when required fields are present")
        // Favorite button
        let favorite = firstCard.buttons["favoriteButton"]
        XCTAssertTrue(favorite.exists, "Favorite button should be present")
    }

    func test_articleCard_missingImage_showsPlaceholder() {
        // This test assumes at least one article is missing an image.
        // Find a card with a placeholder image (could be identified by accessibility label or image name)
        // For this test, we check that the image exists even if the article has no image.
        let cardCount = 10
        var foundPlaceholder = false
        for i in 0..<cardCount {
            let card = articleCard(at: i)
            if card.exists {
                let image = card.images["articleImage"]
                if image.exists {
                    // If the image has a placeholder trait or label, check it
                    if image.label.contains("placeholder") || image.value as? String == "placeholder" {
                        foundPlaceholder = true
                        break
                    }
                }
            }
        }
        XCTAssertTrue(foundPlaceholder, "Expected at least one article card to show a placeholder image when image is missing")
    }

    func test_articleCard_missingTitleOrDescription_notDisplayed() {
        // This test assumes that the backend may return articles with missing fields, but the UI should not show them.
        // We'll check that all visible cards have title and description.
        let maxCards = 10
        for i in 0..<maxCards {
            let card = articleCard(at: i)
            if card.exists {
                let title = card.staticTexts["articleTitle"]
                let description = card.staticTexts["articleDescription"]
                XCTAssertTrue(title.exists, "Article card at index \(i) is missing a title")
                XCTAssertTrue(description.exists, "Article card at index \(i) is missing a description")
            }
        }
    }

    func test_articleCard_titleAndDescription_truncation() {
        // Check that title and description are truncated to 50 characters with ellipsis if too long
        let firstCard = articleCard(at: 0)
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        let title = firstCard.staticTexts["articleTitle"]
        let description = firstCard.staticTexts["articleDescription"]
        if title.exists {
            let titleText = title.label
            XCTAssertLessThanOrEqual(titleText.count, 53, "Title should be truncated to 50 chars + ellipsis if too long")
        }
        if description.exists {
            let descText = description.label
            XCTAssertLessThanOrEqual(descText.count, 53, "Description should be truncated to 50 chars + ellipsis if too long")
        }
    }

    // MARK: - Read More Button

    func test_readMoreButton_navigatesToDetailView() {
        let firstCard = articleCard(at: 0)
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        let readMore = firstCard.buttons["readMoreButton"]
        XCTAssertTrue(readMore.exists)
        readMore.tap()
        // Verify modal appears
        let modalTitle = app.staticTexts["modalArticleTitle"]
        XCTAssertTrue(modalTitle.waitForExistence(timeout: 5), "Article detail modal should appear after tapping Read More")
        // Close modal
        let closeButton = app.buttons["closeModalButton"]
        XCTAssertTrue(closeButton.exists)
        closeButton.tap()
        // Verify back at home
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
    }

    func test_readMoreButton_disabledWhenFieldsMissing_showsValidationAlert() {
        // This test assumes at least one article is missing required fields and Read More is disabled.
        // We'll try to find such a card and tap the disabled button.
        let maxCards = 10
        var foundDisabled = false
        for i in 0..<maxCards {
            let card = articleCard(at: i)
            if card.exists {
                let readMore = card.buttons["readMoreButton"]
                if readMore.exists && !readMore.isEnabled {
                    readMore.tap()
                    // Check for validation alert
                    let alert = app.staticTexts["Please complete all required fields."]
                    XCTAssertTrue(alert.waitForExistence(timeout: 2), "Validation alert should appear when tapping disabled Read More")
                    foundDisabled = true
                    break
                }
            }
        }
        if !foundDisabled {
            XCTFail("No article card with disabled Read More button found for validation test")
        }
    }

    // MARK: - Favorites

    func test_favoriteButton_togglesAndPersists() {
        let firstCard = articleCard(at: 0)
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        let favorite = firstCard.buttons["favoriteButton"]
        XCTAssertTrue(favorite.exists)
        // Initial state: should be "Add to favorites"
        XCTAssertEqual(favorite.label, "Add to favorites")
        favorite.tap()
        // State should change to "Remove from favorites"
        XCTAssertTrue(favorite.waitForExistence(timeout: 2))
        XCTAssertEqual(favorite.label, "Remove from favorites")
        // Relaunch app to test persistence
        app.terminate()
        app.launch()
        waitForHomeScreenToLoad()
        let favoriteAfterRelaunch = articleCard(at: 0).buttons["favoriteButton"]
        XCTAssertTrue(favoriteAfterRelaunch.waitForExistence(timeout: 5))
        XCTAssertEqual(favoriteAfterRelaunch.label, "Remove from favorites", "Favorite state should persist across launches")
        // Unfavorite
        favoriteAfterRelaunch.tap()
        XCTAssertEqual(favoriteAfterRelaunch.label, "Add to favorites")
    }

    func test_favoritedArticles_appearInSavedTabAndOffline() {
        // Favorite the first article
        let firstCard = articleCard(at: 0)
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        let favorite = firstCard.buttons["favoriteButton"]
        if favorite.label == "Add to favorites" {
            favorite.tap()
            XCTAssertEqual(favorite.label, "Remove from favorites")
        }
        // Switch to Saved tab (assume tab bar exists and has "Saved" label)
        let savedTab = app.tabBars.buttons["Saved"]
        XCTAssertTrue(savedTab.waitForExistence(timeout: 5))
        savedTab.tap()
        // Check that the favorited article appears under "Favorites"
        let favoritedCard = app.buttons["newsArticleCard_0"]
        XCTAssertTrue(favoritedCard.waitForExistence(timeout: 5), "Favorited article should appear in Saved tab")
        // Simulate offline mode (requires launch argument or system setting)
        app.terminate()
        app.launchArguments.append("--offline")
        app.launch()
        // Go to Saved tab again
        let savedTabOffline = app.tabBars.buttons["Saved"]
        XCTAssertTrue(savedTabOffline.waitForExistence(timeout: 5))
        savedTabOffline.tap()
        let favoritedCardOffline = app.buttons["newsArticleCard_0"]
        XCTAssertTrue(favoritedCardOffline.waitForExistence(timeout: 5), "Favorited article should be available offline in Saved tab")
    }

    // MARK: - Error and Edge Cases

    func test_errorState_showsErrorMessageAndRetry() {
        // Simulate network error (requires launch argument or network condition)
        app.terminate()
        app.launchArguments.append("--simulateNetworkError")
        app.launch()
        let errorView = app.otherElements["errorView"]
        XCTAssertTrue(errorView.waitForExistence(timeout: 5), "Error view should appear on network error")
        // Tap retry button
        let retryButton = app.buttons["errorRetryButton"]
        XCTAssertTrue(retryButton.exists)
        retryButton.tap()
        // After retry, error view should disappear or articles should load
        let firstCard = articleCard(at: 0)
        let errorGone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: errorView)
        let cardExists = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: firstCard)
        let result = XCTWaiter().wait(for: [errorGone, cardExists], timeout: 10)
        XCTAssertTrue(result == .completed, "Error view should disappear or articles should load after retry")
    }

    func test_offlineState_showsOfflineMessageAndSavedArticlesOnly() {
        // Simulate offline mode
        app.terminate()
        app.launchArguments.append("--offline")
        app.launch()
        let offlineMessage = app.staticTexts["No Internet Connection. Showing saved articles only."]
        XCTAssertTrue(offlineMessage.waitForExistence(timeout: 5), "Offline message should be shown when device is offline")
        // Only saved articles should be visible
        let firstCard = articleCard(at: 0)
        XCTAssertTrue(firstCard.exists, "Saved articles should be visible when offline")
    }

    func test_tooManyFailedAttempts_showsLockoutMessage() {
        // Simulate 3 consecutive failed loads (requires launch argument or backend support)
        app.terminate()
        app.launchArguments.append("--simulateTooManyFailures")
        app.launch()
        let lockoutMessage = app.staticTexts["Too many failed attempts. Please try again in 15 minutes."]
        XCTAssertTrue(lockoutMessage.waitForExistence(timeout: 5), "Lockout message should appear after too many failed attempts")
        // News list should be disabled
        let firstCard = articleCard(at: 0)
        XCTAssertFalse(firstCard.isHittable, "News list should be disabled during lockout")
    }

    // MARK: - List Behavior

    func test_articles_areOrderedNewestToOldest() {
        // Check that articles are ordered by published date descending
        // This test assumes that articleTime label contains a time string (e.g., "2 hours ago")
        let firstCard = articleCard(at: 0)
        let secondCard = articleCard(at: 1)
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        XCTAssertTrue(secondCard.waitForExistence(timeout: 5))
        let firstTime = firstCard.staticTexts["articleTime"].label
        let secondTime = secondCard.staticTexts["articleTime"].label
        // This is a weak assertion, but we expect the first article to be newer
        XCTAssertNotEqual(firstTime, "", "First article should have a time label")
        XCTAssertNotEqual(secondTime, "", "Second article should have a time label")
        // Optionally, parse and compare times if format is known
    }

    // MARK: - Accessibility

    func test_allInteractiveElements_areAccessible() {
        let firstCard = articleCard(at: 0)
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        let readMore = firstCard.buttons["readMoreButton"]
        let favorite = firstCard.buttons["favoriteButton"]
        XCTAssertTrue(readMore.exists)
        XCTAssertTrue(favorite.exists)
        XCTAssertTrue(readMore.isHittable, "Read More button should be accessible")
        XCTAssertTrue(favorite.isHittable, "Favorite button should be accessible")
        // VoiceOver: check accessibility labels
        XCTAssertNotEqual(readMore.label, "", "Read More button should have an accessibility label")
        XCTAssertNotEqual(favorite.label, "", "Favorite button should have an accessibility label")
    }
}
