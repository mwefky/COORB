//
//  CountryRowSnapshotTests.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import COORBAssessment

final class CountryRowSnapshotTests: XCTestCase {

    func test_countryRow_default() {
        let country = Country(
            code: "EG",
            name: "Egypt",
            capital: "Cairo",
            currency: "Egyptian pound",
            flagURL: ""
        )

        let view = CountryRow(country: country)
            .padding()
            .background(Color.white)

        assertSnapshot(of: view, as: .image(layout: .fixed(width: 375, height: 120)))
    }
}
