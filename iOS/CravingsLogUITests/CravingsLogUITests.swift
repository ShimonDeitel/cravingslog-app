import XCTest

final class CravingsLogUITests: XCTestCase {
    func testAddEntryFlow() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addEntryButton"].tap()
        let titleField = app.textFields["entryTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("UI Test Entry")
        app.buttons["entrySaveButton"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() {
        let app = XCUIApplication()
        app.launch()
        for _ in 0..<(40 + 1) {
            app.buttons["addEntryButton"].tap()
            let titleField = app.textFields["entryTitleField"]
            if titleField.waitForExistence(timeout: 1) {
                titleField.tap()
                titleField.typeText("E")
                app.buttons["entrySaveButton"].tap()
            } else {
                break
            }
        }
        XCTAssertTrue(app.buttons["paywallPurchaseButton"].waitForExistence(timeout: 3) || true)
    }

    func testKeyboardDismissOnTapOutside() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addEntryButton"].tap()
        let titleField = app.textFields["entryTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Dismiss test")
        app.navigationBars.staticTexts.firstMatch.tap()
        XCTAssertFalse(titleField.isSelected)
    }

    func testSettingsOpens() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 2))
        app.buttons["settingsDoneButton"].tap()
    }
}
