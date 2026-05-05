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
    private let policy: CountryListPolicy

    init(repository: CountriesRepository = DefaultCountriesRepository(),
         store: LocalStore = LocalStore(),
         locationProvider: LocationProviding = LocationProvider(),
         resolver: DefaultCountryResolving = DefaultCountryResolver(),
         policy: CountryListPolicy = DefaultCountryListPolicy()) {
        self.repository = repository
        self.store = store
        self.locationProvider = locationProvider
        self.resolver = resolver
        self.policy = policy
    }

    func start() -> some View {
        NavigationStack {
            CountryListView(viewModel: self.makeListViewModel())
        }
    }

    private func makeListViewModel() -> CountryListViewModel {
        CountryListViewModel(
            loadCountries: DefaultLoadCountriesUseCase(repository: repository),
            addCountry: DefaultAddCountryUseCase(store: store, policy: policy),
            removeCountry: DefaultRemoveCountryUseCase(store: store),
            getSavedCountries: DefaultGetSavedCountriesUseCase(store: store),
            resolveDefault: DefaultResolveDefaultCountryUseCase(resolver: resolver),
            locationProvider: locationProvider,
            maxCountries: policy.maxCountries
        )
    }
}
