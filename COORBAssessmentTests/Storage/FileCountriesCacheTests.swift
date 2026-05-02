//
//  FileCountriesCacheTests.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import XCTest
@testable import COORBAssessment

final class FileCountriesCacheTests: XCTestCase {

    private var tempDirectory: URL!
    private var sut: FileCountriesCache!
    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CountriesCacheTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDirectory,
                                                withIntermediateDirectories: true)
        sut = FileCountriesCache(
            directory: tempDirectory,
            fileName: "countries.json",
            now: { self.fixedDate }
        )
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDirectory)
        sut = nil
        tempDirectory = nil
        try super.tearDownWithError()
    }

    func test_load_returnsNil_whenNoCacheExists() throws {
        XCTAssertNil(try sut.load())
    }

    func test_save_thenLoad_returnsCountriesWithSavedAtTimestamp() throws {
        let countries = [
            makeCountry(code: "EG"),
            makeCountry(code: "FR", name: "France", capital: "Paris")
        ]

        try sut.save(countries)
        let loaded = try sut.load()

        XCTAssertEqual(loaded?.countries, countries)
        XCTAssertEqual(loaded?.savedAt, fixedDate)
    }

    func test_save_overwritesPreviousData() throws {
        try sut.save([makeCountry(code: "EG")])
        try sut.save([makeCountry(code: "FR", name: "France", capital: "Paris")])

        let loaded = try sut.load()
        XCTAssertEqual(loaded?.countries.count, 1)
        XCTAssertEqual(loaded?.countries.first?.code, "FR")
    }

    func test_load_throwsDecodingError_whenFileIsCorrupt() throws {
        let url = tempDirectory.appendingPathComponent("countries.json")
        try Data("not json".utf8).write(to: url)

        XCTAssertThrowsError(try sut.load())
    }

    // MARK: - Helpers

    private func makeCountry(
        code: String,
        name: String = "Egypt",
        capital: String = "Cairo",
        currency: String = "Egyptian pound",
        flagURL: String = ""
    ) -> Country {
        Country(code: code, name: name, capital: capital,
                currency: currency, flagURL: flagURL)
    }
}
