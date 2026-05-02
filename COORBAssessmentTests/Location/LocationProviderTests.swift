//
//  LocationProviderTests.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import XCTest
import Combine
import CoreLocation
@testable import COORBAssessment

final class LocationProviderTests: XCTestCase {

    private var fakeManager: FakeCLLocationManager!
    private var mockGeocoder: MockGeocoder!
    private var sut: LocationProvider!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        fakeManager = FakeCLLocationManager()
        mockGeocoder = MockGeocoder()
        sut = LocationProvider(locationManager: fakeManager, geocoder: mockGeocoder)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        mockGeocoder = nil
        fakeManager = nil
        super.tearDown()
    }

    func test_requestLocation_requestsAuthorization_whenNotDetermined() {
        fakeManager.stubbedAuthorizationStatus = .notDetermined

        sut.requestLocation()

        XCTAssertEqual(fakeManager.requestWhenInUseAuthorizationCalls, 1)
    }

    func test_requestLocation_publishesPermissionDenied_whenDenied() {
        fakeManager.stubbedAuthorizationStatus = .denied

        var observed: Bool = false
        sut.permissionDeniedPublisher
            .sink { observed = $0 }
            .store(in: &cancellables)

        sut.requestLocation()

        XCTAssertTrue(observed)
    }

    func test_requestLocation_startsUpdates_whenAlreadyAuthorized() {
        fakeManager.stubbedAuthorizationStatus = .authorizedWhenInUse

        sut.requestLocation()

        XCTAssertEqual(fakeManager.startUpdatingLocationCalls, 1)
    }

    func test_didUpdateLocations_publishesGeocodedCountry() {
        mockGeocoder.stubbedCountry = "Egypt"

        let exp = expectation(description: "country published")
        sut.currentCountryPublisher
            .compactMap { $0 }
            .sink { country in
                XCTAssertEqual(country, "Egypt")
                exp.fulfill()
            }
            .store(in: &cancellables)

        let location = CLLocation(latitude: 30, longitude: 31)
        sut.locationManager(fakeManager, didUpdateLocations: [location])

        wait(for: [exp], timeout: 2.0)
        XCTAssertEqual(fakeManager.stopUpdatingLocationCalls, 1)
    }

    func test_didUpdateLocations_keepsCountryNil_whenGeocoderFails() {
        mockGeocoder.stubbedError = NSError(domain: "test", code: 1)

        let location = CLLocation(latitude: 30, longitude: 31)
        sut.locationManager(fakeManager, didUpdateLocations: [location])

        let exp = expectation(description: "geocoder called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(self.mockGeocoder.reverseGeocodeCalls, 1)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
