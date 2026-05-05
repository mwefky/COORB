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
    @Published var limitReachedAlert: Bool = false

    let maxCountries: Int

    private let loadCountriesUseCase: LoadCountriesUseCase
    private let addCountryUseCase: AddCountryUseCase
    private let removeCountryUseCase: RemoveCountryUseCase
    private let getSavedCountriesUseCase: GetSavedCountriesUseCase
    private let resolveDefaultUseCase: ResolveDefaultCountryUseCase
    private let locationProvider: LocationProviding
    private var cancellables = Set<AnyCancellable>()

    private var locationCountry: String?
    private var didResolveDefault = false

    init(loadCountries: LoadCountriesUseCase,
         addCountry: AddCountryUseCase,
         removeCountry: RemoveCountryUseCase,
         getSavedCountries: GetSavedCountriesUseCase,
         resolveDefault: ResolveDefaultCountryUseCase,
         locationProvider: LocationProviding,
         maxCountries: Int = 5) {
        self.loadCountriesUseCase = loadCountries
        self.addCountryUseCase = addCountry
        self.removeCountryUseCase = removeCountry
        self.getSavedCountriesUseCase = getSavedCountries
        self.resolveDefaultUseCase = resolveDefault
        self.locationProvider = locationProvider
        self.maxCountries = maxCountries
        self.addedCountries = getSavedCountries.execute()
        bindLocation()
    }

    var searchSuggestions: [Country] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let query = trimmed.lowercased()
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
            let countries = try await loadCountriesUseCase.execute()
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
        switch addCountryUseCase.execute(country) {
        case .allowed:
            addedCountries = getSavedCountriesUseCase.execute()
        case .limitReached:
            limitReachedAlert = true
        case .duplicate:
            break
        }
    }

    func removeCountry(_ country: Country) {
        removeCountryUseCase.execute(country)
        addedCountries = getSavedCountriesUseCase.execute()
    }

    func removeCountry(at offsets: IndexSet) {
        for index in offsets {
            removeCountryUseCase.execute(addedCountries[index])
        }
        addedCountries = getSavedCountriesUseCase.execute()
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

        if let country = resolveDefaultUseCase.execute(among: availableCountries,
                                                       locationCountry: locationCountry) {
            _ = addCountryUseCase.execute(country)
            addedCountries = getSavedCountriesUseCase.execute()
        }
        didResolveDefault = true
    }
}
