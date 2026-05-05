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
        VStack(alignment: .leading, spacing: Theme.Spacing.sm - 2) {
            Text(country.name)
                .font(.headline)
            HStack(spacing: Theme.Spacing.sm) {
                Label(country.capital, systemImage: "building.2")
                Spacer()
                Label(country.currency, systemImage: "dollarsign.circle")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .cardStyle()
    }
}
