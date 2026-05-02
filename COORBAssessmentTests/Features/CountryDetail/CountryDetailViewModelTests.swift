//
//  CountryDetailViewModelTests.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import XCTest
@testable import COORBAssessment

final class CountryDetailViewModelTests: XCTestCase {

    func test_exposesCountryProperties() {
        let country = Country(code: "EG", name: "Egypt", capital: "Cairo",
                              currency: "Egyptian pound",
                              flagURL: "https://flagcdn.com/w320/eg.png")
        let sut = CountryDetailViewModel(country: country)

        XCTAssertEqual(sut.country, country)
        XCTAssertEqual(sut.name, "Egypt")
        XCTAssertEqual(sut.capital, "Cairo")
        XCTAssertEqual(sut.currency, "Egyptian pound")
    }

    func test_flagURL_returnsParsedURL_whenAvailable() {
        let country = Country(code: "EG", name: "Egypt", capital: "Cairo",
                              currency: "Egyptian pound",
                              flagURL: "https://flagcdn.com/w320/eg.png")
        let sut = CountryDetailViewModel(country: country)

        XCTAssertEqual(sut.flagURL?.absoluteString, "https://flagcdn.com/w320/eg.png")
    }

    func test_flagURL_returnsNil_whenCountryHasNoFlag() {
        let country = Country(code: "XX", name: "Nowhere", capital: "Capital",
                              currency: "Currency", flagURL: "")
        let sut = CountryDetailViewModel(country: country)

        XCTAssertNil(sut.flagURL)
    }
}
