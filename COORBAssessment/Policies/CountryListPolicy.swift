//
//  CountryListPolicy.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation

protocol CountryListPolicy {
    var maxCountries: Int { get }
    func evaluate(_ country: Country, against existing: [Country]) -> CountryListAdmission
}

enum CountryListAdmission: Equatable {
    case allowed
    case duplicate
    case limitReached
}

class DefaultCountryListPolicy: CountryListPolicy {

    let maxCountries: Int

    init(maxCountries: Int = 5) {
        self.maxCountries = maxCountries
    }

    func evaluate(_ country: Country, against existing: [Country]) -> CountryListAdmission {
        if existing.contains(where: { $0.code == country.code }) {
            return .duplicate
        }
        if existing.count >= maxCountries {
            return .limitReached
        }
        return .allowed
    }
}
