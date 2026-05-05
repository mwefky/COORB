//
//  LoadCountriesUseCase.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation

protocol LoadCountriesUseCase {
    func execute() async throws -> [Country]
}

class DefaultLoadCountriesUseCase: LoadCountriesUseCase {

    private let repository: CountriesRepository

    init(repository: CountriesRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Country] {
        try await repository.fetchCountries()
    }
}
