//
//  LocationProvider.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Combine
import CoreLocation

protocol LocationProviding {
    var currentCountryPublisher: AnyPublisher<String?, Never> { get }
    var permissionDeniedPublisher: AnyPublisher<Bool, Never> { get }
    func requestLocation()
}

class LocationProvider: NSObject, LocationProviding, CLLocationManagerDelegate {

    @Published private var currentCountry: String?
    @Published private var isPermissionDenied: Bool = false

    var currentCountryPublisher: AnyPublisher<String?, Never> {
        $currentCountry.eraseToAnyPublisher()
    }

    var permissionDeniedPublisher: AnyPublisher<Bool, Never> {
        $isPermissionDenied.eraseToAnyPublisher()
    }

    private let locationManager: CLLocationManager
    private let geocoder: Geocoding

    init(locationManager: CLLocationManager = CLLocationManager(),
         geocoder: Geocoding = CoreLocationGeocoder()) {
        self.locationManager = locationManager
        self.geocoder = geocoder
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            isPermissionDenied = true
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            isPermissionDenied = true
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        manager.stopUpdatingLocation()

        Task { [weak self] in
            guard let self else { return }
            self.currentCountry = try? await self.geocoder.reverseGeocode(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // ignored — resolver falls back to the default country
    }
}
