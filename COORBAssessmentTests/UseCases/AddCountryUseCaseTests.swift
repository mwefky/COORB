//
//  AddCountryUseCaseTests.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import XCTest
@testable import COORBAssessment

final class AddCountryUseCaseTests: XCTestCase {

    private let suiteName = "AddCountryUseCaseTests"
    private var userDefaults: UserDefaults!
    private var store: LocalStore!
    private var policy: DefaultCountryListPolicy!
    private var sut: DefaultAddCountryUseCase!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
        store = LocalStore(userDefaults: userDefaults, storageKey: "addedCountries")
        policy = DefaultCountryListPolicy()
        sut = DefaultAddCountryUseCase(store: store, policy: policy)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        sut = nil
        policy = nil
        store = nil
        userDefaults = nil
        super.tearDown()
    }

    func test_execute_savesAndReturnsAllowed_whenPolicyAllows() {
        let result = sut.execute(makeCountry(code: "EG"))

        XCTAssertEqual(result, .allowed)
        XCTAssertEqual(store.addedCountries.count, 1)
    }

    func test_execute_doesNotSaveAndReturnsDuplicate_whenAlreadyPresent() {
        sut.execute(makeCountry(code: "EG"))

        let result = sut.execute(makeCountry(code: "EG"))

        XCTAssertEqual(result, .duplicate)
        XCTAssertEqual(store.addedCountries.count, 1)
    }

    func test_execute_doesNotSaveAndReturnsLimitReached_whenAtMax() {
        for code in ["EG", "FR", "DE", "ES", "IT"] {
            sut.execute(makeCountry(code: code))
        }

        let result = sut.execute(makeCountry(code: "JP"))

        XCTAssertEqual(result, .limitReached)
        XCTAssertEqual(store.addedCountries.count, 5)
        XCTAssertFalse(store.addedCountries.contains(where: { $0.code == "JP" }))
    }

    // MARK: - Helpers

    private func makeCountry(code: String) -> Country {
        Country(code: code, name: "Country \(code)", capital: "Capital",
                currency: "Currency", flagURL: "")
    }
}
