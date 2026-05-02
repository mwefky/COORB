//
//  Geocoding.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import CoreLocation

protocol Geocoding {
    func reverseGeocode(_ location: CLLocation) async throws -> String?
}

class CoreLocationGeocoder: Geocoding {
    private let geocoder = CLGeocoder()

    func reverseGeocode(_ location: CLLocation) async throws -> String? {
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        return placemarks.first?.country
    }
}
