//
//  MockUseCases.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation
@testable import COORBAssessment

final class MockLoadCountriesUseCase: LoadCountriesUseCase {

    var stubbedResponse: [Country] = []
    var stubbedError: Error?
    private(set) var executeCallCount = 0

    func execute() async throws -> [Country] {
        executeCallCount += 1
        if let stubbedError {
            throw stubbedError
        }
        return stubbedResponse
    }
}

final class MockAddCountryUseCase: AddCountryUseCase {

    var stubbedAdmission: CountryListAdmission = .allowed
    private(set) var executedCountries: [Country] = []

    func execute(_ country: Country) -> CountryListAdmission {
        executedCountries.append(country)
        return stubbedAdmission
    }
}

final class MockRemoveCountryUseCase: RemoveCountryUseCase {

    private(set) var removedCountries: [Country] = []

    func execute(_ country: Country) {
        removedCountries.append(country)
    }
}

final class MockGetSavedCountriesUseCase: GetSavedCountriesUseCase {

    var stubbedCountries: [Country] = []

    func execute() -> [Country] {
        stubbedCountries
    }
}

final class MockResolveDefaultCountryUseCase: ResolveDefaultCountryUseCase {

    var stubbedResult: Country?
    private(set) var calls: [(available: [Country], locationCountry: String?)] = []

    func execute(among available: [Country], locationCountry: String?) -> Country? {
        calls.append((available, locationCountry))
        return stubbedResult
    }
}
