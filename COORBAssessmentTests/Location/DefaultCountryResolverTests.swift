//
//  DefaultCountryResolverTests.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import XCTest
@testable import COORBAssessment

final class DefaultCountryResolverTests: XCTestCase {

    private var sut: DefaultCountryResolver!

    override func setUp() {
        super.setUp()
        sut = DefaultCountryResolver()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_returnsLocationMatch_whenNamePresentInCountries() {
        let egypt = makeCountry(code: "EG", name: "Egypt")
        let france = makeCountry(code: "FR", name: "France")

        let result = sut.resolveDefault(among: [egypt, france], locationCountry: "France")

        XCTAssertEqual(result, france)
    }

    func test_fallsBackToEgypt_whenLocationCountryNil() {
        let egypt = makeCountry(code: "EG", name: "Egypt")
        let france = makeCountry(code: "FR", name: "France")

        let result = sut.resolveDefault(among: [egypt, france], locationCountry: nil)

        XCTAssertEqual(result, egypt)
    }

    func test_fallsBackToEgypt_whenLocationCountryNotInList() {
        let egypt = makeCountry(code: "EG", name: "Egypt")
        let france = makeCountry(code: "FR", name: "France")

        let result = sut.resolveDefault(among: [egypt, france], locationCountry: "Atlantis")

        XCTAssertEqual(result, egypt)
    }

    func test_returnsNil_whenEgyptMissingAndLocationDoesNotMatch() {
        let france = makeCountry(code: "FR", name: "France")

        let result = sut.resolveDefault(among: [france], locationCountry: "Atlantis")

        XCTAssertNil(result)
    }

    func test_returnsNil_whenAvailableCountriesEmpty() {
        let result = sut.resolveDefault(among: [], locationCountry: "Egypt")

        XCTAssertNil(result)
    }

    // MARK: - Helpers

    private func makeCountry(code: String, name: String) -> Country {
        Country(code: code, name: name, capital: "Capital",
                currency: "Currency", flagURL: "")
    }
}
