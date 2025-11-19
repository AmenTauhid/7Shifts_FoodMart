import XCTest

/// UI tests for FoodMart app.
/// Demonstrates: XCUIApplication, element queries, async waiting.
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

    /// Verifies app launches with main navigation elements.
    @MainActor
    func testAppLaunchShowsMainScreen() throws {
        XCTAssertTrue(app.navigationBars["Food"].exists)
        XCTAssertTrue(app.buttons["Filter"].waitForExistence(timeout: 5))
    }

    /// Verifies filter button opens the filter sheet.
    @MainActor
    func testFilterButtonOpensSheet() throws {
        let filterButton = app.buttons["Filter"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 5))

        filterButton.tap()

        let filterTitle = app.staticTexts["Filter"]
        XCTAssertTrue(filterTitle.waitForExistence(timeout: 2))
    }

    /// Verifies category toggle interaction works.
    @MainActor
    func testCategoryToggleWorks() throws {
        // Open filter sheet
        app.buttons["Filter"].tap()

        // Toggle a category
        let toggle = app.switches.firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        toggle.tap()

        // Verify toggle state changed
        XCTAssertEqual(toggle.value as? String, "1")
    }

    /// Verifies Clear button appears when filters are selected.
    @MainActor
    func testClearButtonAppearsWhenFiltersSelected() throws {
        // Open filter sheet
        app.buttons["Filter"].tap()

        // Initially no Clear button
        XCTAssertFalse(app.buttons["Clear"].exists)

        // Select a category
        let toggle = app.switches.firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        toggle.tap()

        // Clear button should appear
        XCTAssertTrue(app.buttons["Clear"].waitForExistence(timeout: 2))
    }

    /// Verifies pull-to-refresh gesture works.
    @MainActor
    func testPullToRefreshWorks() throws {
        // Wait for content to load
        let filterButton = app.buttons["Filter"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 5))

        // Perform pull-to-refresh
        let firstCell = app.scrollViews.firstMatch
        firstCell.swipeDown()

        // Content should still be visible after refresh
        XCTAssertTrue(filterButton.exists)
    }
}
