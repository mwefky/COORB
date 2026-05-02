//
//  CountriesRepository.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation

protocol CountriesRepository {
    func fetchCountries() async throws -> [Country]
}

class DefaultCountriesRepository: CountriesRepository {

    static let defaultTTL: TimeInterval = 60 * 60 * 24

    private let apiClient: APIClient
    private let cache: CountriesCache
    private let ttl: TimeInterval
    private let now: () -> Date

    init(apiClient: APIClient = URLSessionAPIClient(),
         cache: CountriesCache = FileCountriesCache(),
         ttl: TimeInterval = DefaultCountriesRepository.defaultTTL,
         now: @escaping () -> Date = Date.init) {
        self.apiClient = apiClient
        self.cache = cache
        self.ttl = ttl
        self.now = now
    }

    func fetchCountries() async throws -> [Country] {
        let cached = try? cache.load()

        if let cached, cached.isFresh(ttl: ttl, now: now()) {
            Task { [weak self] in
                _ = try? await self?.refreshFromAPI()
            }
            return cached.countries
        }

        do {
            return try await refreshFromAPI()
        } catch {
            if let cached, !cached.countries.isEmpty {
                return cached.countries
            }
            throw error
        }
    }

    @discardableResult
    private func refreshFromAPI() async throws -> [Country] {
        let dtos: [CountryDTO] = try await apiClient.send(.allCountries)
        let countries = CountryMapper.map(dtos)
        try? cache.save(countries)
        return countries
    }
}
