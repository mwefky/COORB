//
//  CountryListUITests.swift
//  COORBAssessmentUITests
//
//  Created by Mina Wefky on 02/05/2026.
//

import XCTest

final class CountryListUITests: XCTestCase {

    private let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments = ["--reset"]
        app.launch()
    }

    override func tearDown() {
        app.terminate()
        super.tearDown()
    }

    func test_searchAndAddCountry() {
        let searchField = app.textFields["Search for a country"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 15))

        searchField.tap()
        searchField.typeText("Germany")

        let suggestion = app.buttons["Germany"]
        XCTAssertTrue(suggestion.waitForExistence(timeout: 10))
        suggestion.tap()

        XCTAssertTrue(app.staticTexts["Germany"].waitForExistence(timeout: 5))
    }

    func test_removeCountry_viaSwipe() {
        addCountry(named: "Germany")

        let row = app.staticTexts["Germany"]
        row.swipeLeft()

        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 3))
        deleteButton.tap()

        XCTAssertFalse(app.staticTexts["Germany"].waitForExistence(timeout: 1))
    }

    func test_navigateToDetail_showsCapital() {
        addCountry(named: "Germany")

        app.staticTexts["Germany"].tap()

        XCTAssertTrue(app.staticTexts["Berlin"].waitForExistence(timeout: 5))
    }

    // MARK: - Helpers

    private func addCountry(named name: String) {
        let searchField = app.textFields["Search for a country"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 15))

        searchField.tap()
        searchField.typeText(name)

        let suggestion = app.buttons[name]
        XCTAssertTrue(suggestion.waitForExistence(timeout: 10))
        suggestion.tap()

        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 5))
    }
}
