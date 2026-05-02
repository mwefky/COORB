//
//  MockCountriesCache.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation
@testable import COORBAssessment

final class MockCountriesCache: CountriesCache {

    var loadResult: Result<CachedCountries?, Error> = .success(nil)
    var saveError: Error?
    private(set) var savedCountries: [Country]?
    private(set) var saveCallCount = 0

    func save(_ countries: [Country]) throws {
        saveCallCount += 1
        if let saveError {
            throw saveError
        }
        savedCountries = countries
    }

    func load() throws -> CachedCountries? {
        try loadResult.get()
    }
}
