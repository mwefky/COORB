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

    private let apiClient: APIClient
    private let cache: CountriesCache

    init(apiClient: APIClient = URLSessionAPIClient(),
         cache: CountriesCache = FileCountriesCache()) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func fetchCountries() async throws -> [Country] {
        do {
            let dtos: [CountryDTO] = try await apiClient.send(.allCountries)
            let countries = CountryMapper.map(dtos)
            try? cache.save(countries)
            return countries
        } catch {
            if let cached = try? cache.load(), !cached.isEmpty {
                return cached
            }
            throw error
        }
    }
}
