//
//  GetSavedCountriesUseCase.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation

protocol GetSavedCountriesUseCase {
    func execute() -> [Country]
}

class DefaultGetSavedCountriesUseCase: GetSavedCountriesUseCase {

    private let store: LocalStore

    init(store: LocalStore) {
        self.store = store
    }

    func execute() -> [Country] {
        store.addedCountries
    }
}
