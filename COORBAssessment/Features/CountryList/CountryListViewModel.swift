//
//  CountryListViewModel.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation
import Combine

class CountryListViewModel: ObservableObject {

    @Published private(set) var addedCountries: [Country] = []
    @Published private(set) var availableCountries: [Country] = []
    @Published var searchQuery: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var permissionDenied: Bool = false

    private let repository: CountriesRepository
    private let store: LocalStore
    private let locationProvider: LocationProviding
    private let resolver: DefaultCountryResolving
    private var cancellables = Set<AnyCancellable>()

    private var locationCountry: String?
    private var didResolveDefault = false

    init(repository: CountriesRepository,
         store: LocalStore,
         locationProvider: LocationProviding,
         resolver: DefaultCountryResolving) {
        self.repository = repository
        self.store = store
        self.locationProvider = locationProvider
        self.resolver = resolver
        self.addedCountries = store.addedCountries
        bindLocation()
    }

    var searchSuggestions: [Country] {
        guard !searchQuery.isEmpty else { return [] }
        let query = searchQuery.lowercased()
        return availableCountries
            .filter { $0.name.lowercased().contains(query) }
            .prefix(20)
            .map { $0 }
    }

    func start() async {
        locationProvider.requestLocation()
        await loadCountries()
    }

    func loadCountries() async {
        await MainActor.run { [weak self] in
            self?.isLoading = true
            self?.errorMessage = nil
        }

        do {
            let countries = try await repository.fetchCountries()
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.availableCountries = countries
                self.isLoading = false
                self.resolveDefaultIfNeeded()
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.errorMessage = "Failed to load countries: \(error.localizedDescription)"
                self?.isLoading = false
            }
        }
    }

    func addCountry(_ country: Country) {
        store.add(country)
        addedCountries = store.addedCountries
    }

    func removeCountry(_ country: Country) {
        store.remove(country)
        addedCountries = store.addedCountries
    }

    func removeCountry(at offsets: IndexSet) {
        let toRemove = offsets.map { addedCountries[$0] }
        toRemove.forEach { store.remove($0) }
        addedCountries = store.addedCountries
    }

    private func bindLocation() {
        locationProvider.permissionDeniedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] denied in
                self?.permissionDenied = denied
                if denied {
                    self?.resolveDefaultIfNeeded()
                }
            }
            .store(in: &cancellables)

        locationProvider.currentCountryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] country in
                self?.locationCountry = country
                self?.resolveDefaultIfNeeded()
            }
            .store(in: &cancellables)
    }

    private func resolveDefaultIfNeeded() {
        guard !didResolveDefault else { return }

        guard addedCountries.isEmpty else {
            didResolveDefault = true
            return
        }
        guard !availableCountries.isEmpty else { return }
        guard locationCountry != nil || permissionDenied else { return }

        if let country = resolver.resolveDefault(among: availableCountries,
                                                 locationCountry: locationCountry) {
            store.add(country)
            addedCountries = store.addedCountries
        }
        didResolveDefault = true
    }
}
