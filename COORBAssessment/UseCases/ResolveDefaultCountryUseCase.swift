//
//  ResolveDefaultCountryUseCase.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation

protocol ResolveDefaultCountryUseCase {
    func execute(among available: [Country], locationCountry: String?) -> Country?
}

class DefaultResolveDefaultCountryUseCase: ResolveDefaultCountryUseCase {

    private let resolver: DefaultCountryResolving

    init(resolver: DefaultCountryResolving) {
        self.resolver = resolver
    }

    func execute(among available: [Country], locationCountry: String?) -> Country? {
        resolver.resolveDefault(among: available, locationCountry: locationCountry)
    }
}
