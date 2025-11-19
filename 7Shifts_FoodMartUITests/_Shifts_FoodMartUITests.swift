import XCTest

final class _Shifts_FoodMartUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - App Launch Tests

    /// Verifies app launches with navigation title and filter button.
    @MainActor
    func testAppLaunchShowsNavigationElements() throws {
        XCTAssertTrue(app.navigationBars["Food"].exists)
        XCTAssertTrue(app.buttons["Filter"].waitForExistence(timeout: 5))
    }

    /// Verifies food items appear after loading.
    @MainActor
    func testFoodItemsLoadSuccessfully() throws {
        // Wait for content to load
        let firstCell = app.scrollViews.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
    }

    // MARK: - Filter Sheet Tests

    /// Verifies filter button opens filter sheet.
    @MainActor
    func testFilterButtonOpensSheet() throws {
        let filterButton = app.buttons["Filter"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 5))

        filterButton.tap()

        // Verify sheet appears with filter title
        let filterTitle = app.staticTexts["Filter"]
        XCTAssertTrue(filterTitle.waitForExistence(timeout: 2))
    }
    

    // MARK: - Category Filtering Tests

    /// Verifies toggling a category filter works.
    @MainActor
    func testCategoryToggle() throws {
        let filterButton = app.buttons["Filter"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 5))

        filterButton.tap()

        // Wait for categories to load
        let produceSwitch = app.switches.firstMatch
        XCTAssertTrue(produceSwitch.waitForExistence(timeout: 5))

        // Toggle the switch
        produceSwitch.tap()

        // Verify switch is now on
        XCTAssertEqual(produceSwitch.value as? String, "1")
    }

    // MARK: - Pull to Refresh Test

    /// Verifies pull to refresh gesture is available.
    @MainActor
    func testPullToRefreshExists() throws {
        // Wait for scroll view to appear
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 10))

        // Perform pull to refresh gesture
        scrollView.swipeDown()

        // App should still be functional after refresh
        XCTAssertTrue(app.navigationBars["Food"].exists)
    }
}
