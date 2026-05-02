//
//  APIEndpoint+Countries.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation

extension APIEndpoint {
    static let allCountries = APIEndpoint(
        path: "/all",
        queryItems: [
            URLQueryItem(name: "fields", value: "name,alpha2Code,capital,currencies,flags")
        ]
    )
}
