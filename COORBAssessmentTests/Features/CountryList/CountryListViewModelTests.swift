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

    private var loadCountries: MockLoadCountriesUseCase!
    private var addCountry: MockAddCountryUseCase!
    private var removeCountry: MockRemoveCountryUseCase!
    private var getSavedCountries: MockGetSavedCountriesUseCase!
    private var resolveDefault: MockResolveDefaultCountryUseCase!
    private var locationProvider: MockLocationProvider!
    private var sut: CountryListViewModel!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        loadCountries = MockLoadCountriesUseCase()
        addCountry = MockAddCountryUseCase()
        removeCountry = MockRemoveCountryUseCase()
        getSavedCountries = MockGetSavedCountriesUseCase()
        resolveDefault = MockResolveDefaultCountryUseCase()
        locationProvider = MockLocationProvider()
        sut = makeViewModel()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        locationProvider = nil
        resolveDefault = nil
        getSavedCountries = nil
        removeCountry = nil
        addCountry = nil
        loadCountries = nil
        super.tearDown()
    }

    func test_initial_addedCountriesIsEmpty() {
        XCTAssertTrue(sut.addedCountries.isEmpty)
    }

    func test_initial_loadsAddedCountriesFromGetSavedUseCase() {
        getSavedCountries.stubbedCountries = [makeCountry(code: "EG")]
        let fresh = makeViewModel()

        XCTAssertEqual(fresh.addedCountries.count, 1)
    }

    func test_loadCountries_populatesAvailableCountries() async {
        loadCountries.stubbedResponse = [makeCountry(code: "EG"), makeCountry(code: "FR", name: "France")]

        await sut.loadCountries()

        XCTAssertEqual(sut.availableCountries.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadCountries_setsErrorMessage_onFailure() async {
        loadCountries.stubbedError = APIError.server(statusCode: 500)

        await sut.loadCountries()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_addCountry_appendsToAddedCountries_whenAllowed() {
        addCountry.stubbedAdmission = .allowed
        getSavedCountries.stubbedCountries = [makeCountry(code: "EG")]

        sut.addCountry(makeCountry(code: "EG"))

        XCTAssertEqual(addCountry.executedCountries.count, 1)
        XCTAssertEqual(sut.addedCountries.first?.code, "EG")
    }

    func test_addCountry_setsLimitAlert_whenLimitReached() {
        addCountry.stubbedAdmission = .limitReached

        sut.addCountry(makeCountry(code: "JP"))

        XCTAssertTrue(sut.limitReachedAlert)
    }

    func test_addCountry_isNoOp_whenDuplicate() {
        addCountry.stubbedAdmission = .duplicate

        sut.addCountry(makeCountry(code: "EG"))

        XCTAssertFalse(sut.limitReachedAlert)
    }

    func test_removeCountry_callsUseCase_andRefreshesList() {
        getSavedCountries.stubbedCountries = [makeCountry(code: "FR")]

        sut.removeCountry(makeCountry(code: "EG"))

        XCTAssertEqual(removeCountry.removedCountries.first?.code, "EG")
        XCTAssertEqual(sut.addedCountries.first?.code, "FR")
    }

    func test_removeCountryAtOffsets_removesByIndex() {
        getSavedCountries.stubbedCountries = [
            makeCountry(code: "EG"),
            makeCountry(code: "FR", name: "France")
        ]
        let viewModel = makeViewModel()
        getSavedCountries.stubbedCountries = [makeCountry(code: "FR", name: "France")]

        viewModel.removeCountry(at: IndexSet(integer: 0))

        XCTAssertEqual(removeCountry.removedCountries.first?.code, "EG")
    }

    func test_searchSuggestions_emptyForEmptyQuery() async {
        loadCountries.stubbedResponse = [makeCountry(code: "EG")]
        await sut.loadCountries()

        sut.searchQuery = ""

        XCTAssertTrue(sut.searchSuggestions.isEmpty)
    }

    func test_searchSuggestions_emptyForWhitespaceOnlyQuery() async {
        loadCountries.stubbedResponse = [makeCountry(code: "EG", name: "Egypt")]
        await sut.loadCountries()

        sut.searchQuery = "   "

        XCTAssertTrue(sut.searchSuggestions.isEmpty)
    }

    func test_searchSuggestions_trimsWhitespaceAroundQuery() async {
        loadCountries.stubbedResponse = [makeCountry(code: "EG", name: "Egypt")]
        await sut.loadCountries()

        sut.searchQuery = "  egypt  "

        XCTAssertEqual(sut.searchSuggestions.count, 1)
        XCTAssertEqual(sut.searchSuggestions.first?.code, "EG")
    }

    func test_searchSuggestions_filtersAvailableCountries() async {
        loadCountries.stubbedResponse = [
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
        loadCountries.stubbedResponse = [
            makeCountry(code: "EG", name: "Egypt"),
            makeCountry(code: "FR", name: "France")
        ]
        resolveDefault.stubbedResult = makeCountry(code: "FR", name: "France")
        getSavedCountries.stubbedCountries = [makeCountry(code: "FR", name: "France")]
        locationProvider.currentCountrySubject.send("France")

        await waitForSinks()
        await sut.loadCountries()

        XCTAssertEqual(addCountry.executedCountries.first?.code, "FR")
        XCTAssertEqual(sut.addedCountries.first?.code, "FR")
    }

    func test_resolvesDefault_fallsBackToEgypt_whenPermissionDenied() async {
        loadCountries.stubbedResponse = [
            makeCountry(code: "EG", name: "Egypt"),
            makeCountry(code: "FR", name: "France")
        ]
        resolveDefault.stubbedResult = makeCountry(code: "EG", name: "Egypt")
        getSavedCountries.stubbedCountries = [makeCountry(code: "EG", name: "Egypt")]
        locationProvider.permissionDeniedSubject.send(true)

        await waitForSinks()
        await sut.loadCountries()

        XCTAssertEqual(addCountry.executedCountries.first?.code, "EG")
        XCTAssertTrue(sut.permissionDenied)
    }

    func test_resolvesDefault_skipsWhenUserAlreadyHasCountries() async {
        getSavedCountries.stubbedCountries = [makeCountry(code: "JP", name: "Japan")]
        let viewModel = makeViewModel()
        loadCountries.stubbedResponse = [
            makeCountry(code: "EG", name: "Egypt"),
            makeCountry(code: "FR", name: "France")
        ]
        locationProvider.currentCountrySubject.send("France")

        await waitForSinks()
        await viewModel.loadCountries()

        XCTAssertEqual(addCountry.executedCountries.count, 0)
    }

    // MARK: - Helpers

    private func makeViewModel() -> CountryListViewModel {
        CountryListViewModel(
            loadCountries: loadCountries,
            addCountry: addCountry,
            removeCountry: removeCountry,
            getSavedCountries: getSavedCountries,
            resolveDefault: resolveDefault,
            locationProvider: locationProvider
        )
    }

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
