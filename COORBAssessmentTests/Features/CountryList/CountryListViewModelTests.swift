//
//  CountryListViewModelTests.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import XCTest
import Combine
@testable import COORBAssessment

final class CountryListViewModelTests: XCTestCase {

    private let suiteName = "CountryListViewModelTests"
    private var userDefaults: UserDefaults!
    private var repository: MockCountriesRepository!
    private var store: LocalStore!
    private var locationProvider: MockLocationProvider!
    private var resolver: DefaultCountryResolver!
    private var sut: CountryListViewModel!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
        repository = MockCountriesRepository()
        store = LocalStore(userDefaults: userDefaults, storageKey: "addedCountries")
        locationProvider = MockLocationProvider()
        resolver = DefaultCountryResolver()
        sut = CountryListViewModel(
            repository: repository,
            store: store,
            locationProvider: locationProvider,
            resolver: resolver
        )
        cancellables = []
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        cancellables = nil
        sut = nil
        resolver = nil
        locationProvider = nil
        store = nil
        repository = nil
        userDefaults = nil
        super.tearDown()
    }

    func test_initial_addedCountriesIsEmpty() {
        XCTAssertTrue(sut.addedCountries.isEmpty)
    }

    func test_initial_loadsAddedCountriesFromStore() {
        store.save(makeCountry(code: "EG"))

        let fresh = CountryListViewModel(
            repository: repository, store: store,
            locationProvider: locationProvider, resolver: resolver
        )

        XCTAssertEqual(fresh.addedCountries.count, 1)
    }

    func test_loadCountries_populatesAvailableCountries() async {
        repository.stubbedResponse = [makeCountry(code: "EG"), makeCountry(code: "FR", name: "France")]

        await sut.loadCountries()

        XCTAssertEqual(sut.availableCountries.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadCountries_setsErrorMessage_onFailure() async {
        repository.stubbedError = APIError.server(statusCode: 500)

        await sut.loadCountries()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_addCountry_appendsToAddedCountries() {
        sut.addCountry(makeCountry(code: "EG"))

        XCTAssertEqual(sut.addedCountries.count, 1)
        XCTAssertEqual(sut.addedCountries.first?.code, "EG")
    }

    func test_addCountry_setsLimitAlert_andDoesNotEvict_whenAtLimit() {
        for code in ["EG", "FR", "DE", "ES", "IT"] {
            sut.addCountry(makeCountry(code: code))
        }

        sut.addCountry(makeCountry(code: "JP"))

        XCTAssertTrue(sut.limitReachedAlert)
        XCTAssertEqual(sut.addedCountries.count, 5)
        XCTAssertEqual(sut.addedCountries.first?.code, "EG")
        XCTAssertFalse(sut.addedCountries.contains(where: { $0.code == "JP" }))
    }

    func test_removeCountry_removesFromAddedCountries() {
        sut.addCountry(makeCountry(code: "EG"))
        sut.addCountry(makeCountry(code: "FR", name: "France"))

        sut.removeCountry(makeCountry(code: "EG"))

        XCTAssertEqual(sut.addedCountries.count, 1)
        XCTAssertEqual(sut.addedCountries.first?.code, "FR")
    }

    func test_removeCountryAtOffsets_removesByIndex() {
        sut.addCountry(makeCountry(code: "EG"))
        sut.addCountry(makeCountry(code: "FR", name: "France"))

        sut.removeCountry(at: IndexSet(integer: 0))

        XCTAssertEqual(sut.addedCountries.count, 1)
        XCTAssertEqual(sut.addedCountries.first?.code, "FR")
    }

    func test_searchSuggestions_emptyForEmptyQuery() async {
        repository.stubbedResponse = [makeCountry(code: "EG")]
        await sut.loadCountries()

        sut.searchQuery = ""

        XCTAssertTrue(sut.searchSuggestions.isEmpty)
    }

    func test_searchSuggestions_emptyForWhitespaceOnlyQuery() async {
        repository.stubbedResponse = [makeCountry(code: "EG", name: "Egypt")]
        await sut.loadCountries()

        sut.searchQuery = "   "

        XCTAssertTrue(sut.searchSuggestions.isEmpty)
    }

    func test_searchSuggestions_trimsWhitespaceAroundQuery() async {
        repository.stubbedResponse = [makeCountry(code: "EG", name: "Egypt")]
        await sut.loadCountries()

        sut.searchQuery = "  egypt  "

        XCTAssertEqual(sut.searchSuggestions.count, 1)
        XCTAssertEqual(sut.searchSuggestions.first?.code, "EG")
    }

    func test_searchSuggestions_filtersAvailableCountries() async {
        repository.stubbedResponse = [
            makeCountry(code: "EG", name: "Egypt"),
            makeCountry(code: "FR", name: "France"),
            makeCountry(code: "DE", name: "Germany")
        ]
        await sut.loadCountries()

        sut.searchQuery = "fra"

        XCTAssertEqual(sut.searchSuggestions.count, 1)
        XCTAssertEqual(sut.searchSuggestions.first?.name, "France")
    }

    func test_resolvesDefault_addsLocationMatch_whenLocationKnown() async {
        repository.stubbedResponse = [
            makeCountry(code: "EG", name: "Egypt"),
            makeCountry(code: "FR", name: "France")
        ]
        locationProvider.currentCountrySubject.send("France")

        await waitForSinks()
        await sut.loadCountries()

        XCTAssertEqual(sut.addedCountries.first?.code, "FR")
    }

    func test_resolvesDefault_fallsBackToEgypt_whenPermissionDenied() async {
        repository.stubbedResponse = [
            makeCountry(code: "EG", name: "Egypt"),
            makeCountry(code: "FR", name: "France")
        ]
        locationProvider.permissionDeniedSubject.send(true)

        await waitForSinks()
        await sut.loadCountries()

        XCTAssertEqual(sut.addedCountries.first?.code, "EG")
        XCTAssertTrue(sut.permissionDenied)
    }

    func test_resolvesDefault_skipsWhenUserAlreadyHasCountries() async {
        store.save(makeCountry(code: "JP", name: "Japan"))
        let viewModel = CountryListViewModel(
            repository: repository, store: store,
            locationProvider: locationProvider, resolver: resolver
        )
        repository.stubbedResponse = [
            makeCountry(code: "EG", name: "Egypt"),
            makeCountry(code: "FR", name: "France")
        ]
        locationProvider.currentCountrySubject.send("France")

        await waitForSinks()
        await viewModel.loadCountries()

        XCTAssertEqual(viewModel.addedCountries.count, 1)
        XCTAssertEqual(viewModel.addedCountries.first?.code, "JP")
    }

    // MARK: - Helpers

    private func makeCountry(
        code: String,
        name: String = "Egypt",
        capital: String = "Cairo",
        currency: String = "EGP"
    ) -> Country {
        Country(code: code, name: name, capital: capital,
                currency: currency, flagURL: "")
    }

    private func waitForSinks() async {
        let exp = expectation(description: "main queue drained")
        DispatchQueue.main.async { exp.fulfill() }
        await fulfillment(of: [exp], timeout: 1.0)
    }
}
