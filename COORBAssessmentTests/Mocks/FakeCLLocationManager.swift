//
//  FakeCLLocationManager.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import CoreLocation

final class FakeCLLocationManager: CLLocationManager {

    var stubbedAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    private(set) var requestWhenInUseAuthorizationCalls = 0
    private(set) var startUpdatingLocationCalls = 0
    private(set) var stopUpdatingLocationCalls = 0

    override var authorizationStatus: CLAuthorizationStatus {
        stubbedAuthorizationStatus
    }

    override func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalls += 1
    }

    override func startUpdatingLocation() {
        startUpdatingLocationCalls += 1
    }

    override func stopUpdatingLocation() {
        stopUpdatingLocationCalls += 1
    }
}
