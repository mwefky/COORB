//
//  CountryDetailViewSnapshotTests.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import COORBAssessment

final class CountryDetailViewSnapshotTests: XCTestCase {

    func test_detailView_withMissingFlag() {
        let country = Country(
            code: "EG",
            name: "Egypt",
            capital: "Cairo",
            currency: "Egyptian pound",
            flagURL: ""
        )

        let view = NavigationStack {
            CountryDetailView(viewModel: CountryDetailViewModel(country: country))
        }

        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
    }
}
