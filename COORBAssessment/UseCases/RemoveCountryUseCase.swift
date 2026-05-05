//
//  RemoveCountryUseCase.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation

protocol RemoveCountryUseCase {
    func execute(_ country: Country)
}

class DefaultRemoveCountryUseCase: RemoveCountryUseCase {

    private let store: LocalStore

    init(store: LocalStore) {
        self.store = store
    }

    func execute(_ country: Country) {
        store.remove(country)
    }
}
