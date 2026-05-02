//
//  CountryMapper.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 30/04/2026.
//

import Foundation

enum CountryMapper {
    static func map(_ dto: CountryDTO) -> Country {
        Country(
            code: dto.alpha2Code,
            name: dto.name,
            capital: dto.capital ?? "Unknown Capital",
            currency: dto.currencies?.first?.name ?? "Unknown Currency",
            flagURL: dto.flags.png ?? ""
        )
    }

    static func map(_ dtos: [CountryDTO]) -> [Country] {
        dtos.map(map)
    }
}
