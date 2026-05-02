//
//  DefaultCountryResolver.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation

protocol DefaultCountryResolving {
    func resolveDefault(among countries: [Country],
                        locationCountry: String?) -> Country?
}

class DefaultCountryResolver: DefaultCountryResolving {

    static let fallbackCountryName = "Egypt"

    func resolveDefault(among countries: [Country],
                        locationCountry: String?) -> Country? {
        if let locationCountry,
           let match = countries.first(where: { $0.name == locationCountry }) {
            return match
        }
        return countries.first(where: { $0.name == DefaultCountryResolver.fallbackCountryName })
    }
}
