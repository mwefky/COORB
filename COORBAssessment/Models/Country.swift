//
//  Country.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 30/04/2026.
//

import Foundation

struct Country: Codable, Equatable, Hashable, Identifiable {
    let code: String
    let name: String
    let capital: String
    let currency: String
    let flagURL: String

    var id: String { code }
}
