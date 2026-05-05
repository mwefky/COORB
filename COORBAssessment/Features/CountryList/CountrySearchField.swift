//
//  CountrySearchField.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import SwiftUI

struct CountrySearchField: View {

    @Binding var text: String
    let suggestions: [Country]
    let onSelection: (Country) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search for a country", text: $text)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(Theme.Spacing.md)
            .background(.thinMaterial)
            .cornerRadius(Theme.Radius.md)

            if !text.isEmpty && !suggestions.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(suggestions) { country in
                            Button {
                                onSelection(country)
                                text = ""
                                hideKeyboard()
                            } label: {
                                Text(country.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, Theme.Spacing.sm + 2)
                                    .padding(.horizontal, Theme.Spacing.md)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier(country.name)
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 220)
                .background(Color(.systemBackground))
                .cornerRadius(Theme.Radius.md)
                .shadow(color: Theme.Colors.shadow,
                        radius: Theme.Shadow.card.radius,
                        x: Theme.Shadow.card.x,
                        y: Theme.Shadow.card.y)
            }
        }
        .padding(.horizontal)
        .padding(.top, Theme.Spacing.sm)
    }
}
