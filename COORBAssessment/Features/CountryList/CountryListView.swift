//
//  CountryListView.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import SwiftUI

struct CountryListView: View {

    @StateObject var viewModel: CountryListViewModel
    @State private var showPermissionAlert = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.2), .white]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                CountrySearchField(
                    text: $viewModel.searchQuery,
                    suggestions: viewModel.searchSuggestions,
                    onSelection: { country in
                        viewModel.addCountry(country)
                    }
                )
                content
            }
        }
        .navigationTitle("Countries")
        .alert("Location permission denied",
               isPresented: $showPermissionAlert,
               actions: { Button("OK", role: .cancel) {} },
               message: { Text("We couldn't determine your location. Defaulting to Egypt.") })
        .alert("You've reached the limit",
               isPresented: $viewModel.limitReachedAlert,
               actions: { Button("OK", role: .cancel) {} },
               message: { Text("You can save up to \(viewModel.maxCountries) countries. Remove one before adding another.") })
        .onChange(of: viewModel.permissionDenied) { denied in
            if denied { showPermissionAlert = true }
        }
        .task {
            await viewModel.start()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.availableCountries.isEmpty {
            Spacer()
            ProgressView("Loading countries...")
                .padding()
            Spacer()
        } else if let error = viewModel.errorMessage, viewModel.availableCountries.isEmpty {
            Spacer()
            Text(error)
                .foregroundColor(.red)
                .padding()
            Spacer()
        } else if viewModel.addedCountries.isEmpty {
            Spacer()
            Text("Search for a country and add it to your list.")
                .foregroundColor(.secondary)
                .padding()
            Spacer()
        } else {
            countryList
        }
    }

    private var countryList: some View {
        List {
            ForEach(viewModel.addedCountries) { country in
                NavigationLink(value: country) {
                    CountryRow(country: country)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .padding(.vertical, 4)
            }
            .onDelete(perform: viewModel.removeCountry(at:))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .navigationDestination(for: Country.self) { country in
            CountryDetailView(viewModel: CountryDetailViewModel(country: country))
        }
    }
}
