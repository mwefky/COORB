//
//  LocalStoreTests.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import XCTest
@testable import COORBAssessment

final class LocalStoreTests: XCTestCase {

    private let suiteName = "LocalStoreTests"
    private var userDefaults: UserDefaults!
    private var sut: LocalStore!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
        sut = LocalStore(userDefaults: userDefaults, storageKey: "addedCountries")
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        sut = nil
        userDefaults = nil
        super.tearDown()
    }

    func test_addedCountries_isEmpty_initially() {
        XCTAssertTrue(sut.addedCountries.isEmpty)
    }

    func test_add_appendsCountry() {
        sut.add(makeCountry(code: "EG"))

        XCTAssertEqual(sut.addedCountries.count, 1)
        XCTAssertEqual(sut.addedCountries.first?.code, "EG")
    }

    func test_add_doesNotAddDuplicates() {
        sut.add(makeCountry(code: "EG"))
        sut.add(makeCountry(code: "EG"))

        XCTAssertEqual(sut.addedCountries.count, 1)
    }

    func test_add_keepsLastFive_whenLimitReached() {
        for code in ["EG", "FR", "DE", "ES", "IT"] {
            sut.add(makeCountry(code: code))
        }
        sut.add(makeCountry(code: "JP"))

        XCTAssertEqual(sut.addedCountries.count, 5)
        XCTAssertEqual(sut.addedCountries.first?.code, "FR")
        XCTAssertEqual(sut.addedCountries.last?.code, "JP")
    }

    func test_remove_removesByCode() {
        sut.add(makeCountry(code: "EG"))
        sut.add(makeCountry(code: "FR"))

        sut.remove(makeCountry(code: "EG"))

        XCTAssertEqual(sut.addedCountries.count, 1)
        XCTAssertEqual(sut.addedCountries.first?.code, "FR")
    }

    func test_remove_isNoOp_whenCountryNotPresent() {
        sut.add(makeCountry(code: "EG"))
        sut.remove(makeCountry(code: "FR"))

        XCTAssertEqual(sut.addedCountries.count, 1)
    }

    func test_persistsAcrossInstances() {
        sut.add(makeCountry(code: "EG"))
        sut.add(makeCountry(code: "FR"))

        let fresh = LocalStore(userDefaults: userDefaults, storageKey: "addedCountries")

        XCTAssertEqual(fresh.addedCountries.count, 2)
        XCTAssertEqual(fresh.addedCountries.last?.code, "FR")
    }

    // MARK: - Helpers

    private func makeCountry(code: String) -> Country {
        Country(code: code, name: "Country \(code)", capital: "Capital",
                currency: "Currency", flagURL: "")
    }
}
