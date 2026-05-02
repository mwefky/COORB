//
//  CountryDTODecodingTests.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 30/04/2026.
//

import XCTest
@testable import COORBAssessment

final class CountryDTODecodingTests: XCTestCase {

    func test_decoding_parsesAllFields() throws {
        let json = """
        {
          "name": "Egypt",
          "alpha2Code": "EG",
          "capital": "Cairo",
          "currencies": [
            { "code": "EGP", "name": "Egyptian pound", "symbol": "£" }
          ],
          "flags": {
            "svg": "https://flagcdn.com/eg.svg",
            "png": "https://flagcdn.com/w320/eg.png"
          }
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(CountryDTO.self, from: json)

        XCTAssertEqual(dto.name, "Egypt")
        XCTAssertEqual(dto.alpha2Code, "EG")
        XCTAssertEqual(dto.capital, "Cairo")
        XCTAssertEqual(dto.currencies?.first?.name, "Egyptian pound")
        XCTAssertEqual(dto.currencies?.first?.code, "EGP")
        XCTAssertEqual(dto.flags.png, "https://flagcdn.com/w320/eg.png")
        XCTAssertEqual(dto.flags.svg, "https://flagcdn.com/eg.svg")
    }

    func test_decoding_handlesMissingOptionals() throws {
        let json = """
        {
          "name": "Antarctica",
          "alpha2Code": "AQ",
          "flags": {}
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(CountryDTO.self, from: json)

        XCTAssertEqual(dto.name, "Antarctica")
        XCTAssertEqual(dto.alpha2Code, "AQ")
        XCTAssertNil(dto.capital)
        XCTAssertNil(dto.currencies)
        XCTAssertNil(dto.flags.png)
        XCTAssertNil(dto.flags.svg)
    }

    func test_decoding_array() throws {
        let json = """
        [
          { "name": "Egypt", "alpha2Code": "EG", "capital": "Cairo", "flags": {} },
          { "name": "France", "alpha2Code": "FR", "capital": "Paris", "flags": {} }
        ]
        """.data(using: .utf8)!

        let dtos = try JSONDecoder().decode([CountryDTO].self, from: json)

        XCTAssertEqual(dtos.count, 2)
        XCTAssertEqual(dtos[0].alpha2Code, "EG")
        XCTAssertEqual(dtos[1].name, "France")
    }

    func test_decoding_failsWhenRequiredFieldMissing() {
        let json = """
        {
          "name": "Egypt",
          "flags": {}
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(CountryDTO.self, from: json))
    }
}
