//
//  CountryDTO.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 30/04/2026.
//

import Foundation

struct CountryDTO: Decodable {
    let name: String
    let alpha2Code: String
    let capital: String?
    let currencies: [Currency]?
    let flags: Flags

    struct Flags: Decodable {
        let png: String?
        let svg: String?
    }

    struct Currency: Decodable {
        let code: String?
        let name: String?
        let symbol: String?
    }
}
