//
//  AddCountryUseCase.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation

protocol AddCountryUseCase {
    func execute(_ country: Country) -> CountryListAdmission
}

class DefaultAddCountryUseCase: AddCountryUseCase {

    private let store: LocalStore
    private let policy: CountryListPolicy

    init(store: LocalStore, policy: CountryListPolicy) {
        self.store = store
        self.policy = policy
    }

    func execute(_ country: Country) -> CountryListAdmission {
        let admission = policy.evaluate(country, against: store.addedCountries)
        if admission == .allowed {
            store.save(country)
        }
        return admission
    }
}
