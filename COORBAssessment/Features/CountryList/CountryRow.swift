//
//  CountryRow.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import SwiftUI

struct CountryRow: View {

    let country: Country

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(country.name)
                .font(.headline)
            HStack(spacing: 8) {
                Label(country.capital, systemImage: "building.2")
                Spacer()
                Label(country.currency, systemImage: "dollarsign.circle")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.7))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
