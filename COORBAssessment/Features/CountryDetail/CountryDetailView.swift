//
//  CountryDetailView.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import SwiftUI

struct CountryDetailView: View {

    @StateObject var viewModel: CountryDetailViewModel

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            flagImage
                .frame(width: Theme.FlagSize.width, height: Theme.FlagSize.height)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                .shadow(color: Theme.Colors.shadowStrong,
                        radius: Theme.Shadow.strong.radius,
                        x: Theme.Shadow.strong.x,
                        y: Theme.Shadow.strong.y)

            VStack(spacing: Theme.Spacing.md + 2) {
                DetailRow(label: "Capital", value: viewModel.capital)
                Divider()
                DetailRow(label: "Currency", value: viewModel.currency)
            }
            .infoCardStyle()

            Spacer()
        }
        .padding()
        .padding(.top, Theme.Spacing.lg)
        .screenBackground()
        .navigationTitle(viewModel.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var flagImage: some View {
        if let url = viewModel.flagURL {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
        } else {
            ZStack {
                Theme.Colors.placeholderBackground
                Image(systemName: "flag")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct DetailRow: View {

    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}
