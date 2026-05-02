//
//  MockCountriesRepository.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation
@testable import COORBAssessment

final class MockCountriesRepository: CountriesRepository {

    var stubbedResponse: [Country] = []
    var stubbedError: Error?
    private(set) var fetchCallCount = 0

    func fetchCountries() async throws -> [Country] {
        fetchCallCount += 1
        if let stubbedError {
            throw stubbedError
        }
        return stubbedResponse
    }
}
