//
//  MockCountriesCache.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation
@testable import COORBAssessment

final class MockCountriesCache: CountriesCache {

    var loadResult: Result<[Country]?, Error> = .success(nil)
    var saveError: Error?
    private(set) var savedCountries: [Country]?

    func save(_ countries: [Country]) throws {
        if let saveError {
            throw saveError
        }
        savedCountries = countries
    }

    func load() throws -> [Country]? {
        try loadResult.get()
    }
}
