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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
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
            .padding(12)
            .background(.thinMaterial)
            .cornerRadius(12)

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
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
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
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
