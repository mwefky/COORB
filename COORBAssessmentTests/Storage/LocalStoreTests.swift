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

    func test_save_appendsCountry() {
        sut.save(makeCountry(code: "EG"))

        XCTAssertEqual(sut.addedCountries.count, 1)
        XCTAssertEqual(sut.addedCountries.first?.code, "EG")
    }

    func test_save_doesNotEnforceLimitOrDeduplication() {
        for code in ["EG", "FR", "DE", "ES", "IT", "JP", "EG"] {
            sut.save(makeCountry(code: code))
        }

        XCTAssertEqual(sut.addedCountries.count, 7)
    }

    func test_remove_removesByCode() {
        sut.save(makeCountry(code: "EG"))
        sut.save(makeCountry(code: "FR"))

        sut.remove(makeCountry(code: "EG"))

        XCTAssertEqual(sut.addedCountries.count, 1)
        XCTAssertEqual(sut.addedCountries.first?.code, "FR")
    }

    func test_remove_isNoOp_whenCountryNotPresent() {
        sut.save(makeCountry(code: "EG"))
        sut.remove(makeCountry(code: "FR"))

        XCTAssertEqual(sut.addedCountries.count, 1)
    }

    func test_persistsAcrossInstances() {
        sut.save(makeCountry(code: "EG"))
        sut.save(makeCountry(code: "FR"))

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
