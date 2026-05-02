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
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.2), .white]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                flagImage
                    .frame(width: 200, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)

                VStack(spacing: 14) {
                    DetailRow(label: "Capital", value: viewModel.capital)
                    Divider()
                    DetailRow(label: "Currency", value: viewModel.currency)
                }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)

                Spacer()
            }
            .padding()
            .padding(.top, 16)
        }
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
                Color.gray.opacity(0.15)
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
