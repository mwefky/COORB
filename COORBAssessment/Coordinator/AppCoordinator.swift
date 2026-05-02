//
//  AppCoordinator.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import SwiftUI

protocol Coordinator {
    associatedtype RootView: View
    func start() -> RootView
}

class AppCoordinator: Coordinator {

    private let repository: CountriesRepository
    private let store: LocalStore
    private let locationProvider: LocationProviding
    private let resolver: DefaultCountryResolving

    init(repository: CountriesRepository = DefaultCountriesRepository(),
         store: LocalStore = LocalStore(),
         locationProvider: LocationProviding = LocationProvider(),
         resolver: DefaultCountryResolving = DefaultCountryResolver()) {
        self.repository = repository
        self.store = store
        self.locationProvider = locationProvider
        self.resolver = resolver
    }

    func start() -> some View {
        // The country list view will be wired in once that feature lands.
        NavigationStack {
            ProgressView()
                .progressViewStyle(.circular)
                .navigationTitle("Countries")
        }
    }
}
