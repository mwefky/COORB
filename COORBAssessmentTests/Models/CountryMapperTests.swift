//
//  CountryMapperTests.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 30/04/2026.
//

import XCTest
@testable import COORBAssessment

final class CountryMapperTests: XCTestCase {

    func test_map_happyPath() {
        let dto = CountryDTO(
            name: "Egypt",
            alpha2Code: "EG",
            capital: "Cairo",
            currencies: [.init(code: "EGP", name: "Egyptian pound", symbol: "£")],
            flags: .init(png: "https://flagcdn.com/w320/eg.png", svg: nil)
        )

        let country = CountryMapper.map(dto)

        XCTAssertEqual(country.code, "EG")
        XCTAssertEqual(country.name, "Egypt")
        XCTAssertEqual(country.capital, "Cairo")
        XCTAssertEqual(country.currency, "Egyptian pound")
        XCTAssertEqual(country.flagURL, "https://flagcdn.com/w320/eg.png")
        XCTAssertEqual(country.id, "EG")
    }

    func test_map_fallsBackWhenCapitalMissing() {
        let dto = CountryDTO(
            name: "Anywhere", alpha2Code: "AW",
            capital: nil, currencies: nil,
            flags: .init(png: nil, svg: nil)
        )

        XCTAssertEqual(CountryMapper.map(dto).capital, "Unknown Capital")
    }

    func test_map_fallsBackWhenCurrenciesMissing() {
        let dto = CountryDTO(
            name: "Anywhere", alpha2Code: "AW",
            capital: "Somewhere", currencies: nil,
            flags: .init(png: nil, svg: nil)
        )

        XCTAssertEqual(CountryMapper.map(dto).currency, "Unknown Currency")
    }

    func test_map_fallsBackWhenCurrencyNameNil() {
        let dto = CountryDTO(
            name: "Anywhere", alpha2Code: "AW",
            capital: "Somewhere",
            currencies: [.init(code: "AWG", name: nil, symbol: nil)],
            flags: .init(png: nil, svg: nil)
        )

        XCTAssertEqual(CountryMapper.map(dto).currency, "Unknown Currency")
    }

    func test_map_returnsEmptyFlagURL_whenPNGMissing() {
        let dto = CountryDTO(
            name: "Anywhere", alpha2Code: "AW",
            capital: "Somewhere", currencies: nil,
            flags: .init(png: nil, svg: nil)
        )

        XCTAssertEqual(CountryMapper.map(dto).flagURL, "")
    }

    func test_map_array_mapsEachElement() {
        let dtos = [
            CountryDTO(name: "Egypt", alpha2Code: "EG", capital: "Cairo",
                       currencies: nil, flags: .init(png: nil, svg: nil)),
            CountryDTO(name: "France", alpha2Code: "FR", capital: "Paris",
                       currencies: nil, flags: .init(png: nil, svg: nil))
        ]

        let countries = CountryMapper.map(dtos)

        XCTAssertEqual(countries.count, 2)
        XCTAssertEqual(countries[0].code, "EG")
        XCTAssertEqual(countries[1].name, "France")
    }
}
