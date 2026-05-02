//
//  CountryDetailViewModel.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation

class CountryDetailViewModel: ObservableObject {

    let country: Country

    init(country: Country) {
        self.country = country
    }

    var name: String { country.name }
    var capital: String { country.capital }
    var currency: String { country.currency }

    var flagURL: URL {
        URL(string: country.flagURL)!
    }
}
