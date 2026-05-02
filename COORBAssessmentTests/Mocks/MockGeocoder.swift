//
//  MockGeocoder.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import CoreLocation
@testable import COORBAssessment

final class MockGeocoder: Geocoding {

    var stubbedCountry: String?
    var stubbedError: Error?
    private(set) var reverseGeocodeCalls = 0

    func reverseGeocode(_ location: CLLocation) async throws -> String? {
        reverseGeocodeCalls += 1
        if let stubbedError {
            throw stubbedError
        }
        return stubbedCountry
    }
}
