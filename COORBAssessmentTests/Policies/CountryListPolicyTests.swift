//
//  CountryListPolicyTests.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import XCTest
@testable import COORBAssessment

final class CountryListPolicyTests: XCTestCase {

    private var sut: DefaultCountryListPolicy!

    override func setUp() {
        super.setUp()
        sut = DefaultCountryListPolicy()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_evaluate_allowsCountry_whenListEmpty() {
        let result = sut.evaluate(makeCountry(code: "EG"), against: [])

        XCTAssertEqual(result, .allowed)
    }

    func test_evaluate_returnsDuplicate_whenCountryAlreadyPresent() {
        let existing = [makeCountry(code: "EG"), makeCountry(code: "FR")]

        let result = sut.evaluate(makeCountry(code: "EG"), against: existing)

        XCTAssertEqual(result, .duplicate)
    }

    func test_evaluate_returnsLimitReached_whenAtMax() {
        let existing = ["EG", "FR", "DE", "ES", "IT"].map { makeCountry(code: $0) }

        let result = sut.evaluate(makeCountry(code: "JP"), against: existing)

        XCTAssertEqual(result, .limitReached)
    }

    func test_evaluate_respectsCustomMax() {
        let policy = DefaultCountryListPolicy(maxCountries: 2)
        let existing = [makeCountry(code: "EG"), makeCountry(code: "FR")]

        let result = policy.evaluate(makeCountry(code: "JP"), against: existing)

        XCTAssertEqual(result, .limitReached)
    }

    func test_evaluate_returnsDuplicate_evenWhenAtLimit() {
        let existing = ["EG", "FR", "DE", "ES", "IT"].map { makeCountry(code: $0) }

        let result = sut.evaluate(makeCountry(code: "EG"), against: existing)

        XCTAssertEqual(result, .duplicate)
    }

    // MARK: - Helpers

    private func makeCountry(code: String) -> Country {
        Country(code: code, name: "Country \(code)", capital: "Capital",
                currency: "Currency", flagURL: "")
    }
}
