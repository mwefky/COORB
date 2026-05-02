//
//  DefaultCountriesRepositoryTests.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import XCTest
@testable import COORBAssessment

final class DefaultCountriesRepositoryTests: XCTestCase {

    private var apiClient: MockAPIClient!
    private var cache: MockCountriesCache!
    private var sut: DefaultCountriesRepository!

    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient()
        cache = MockCountriesCache()
        sut = DefaultCountriesRepository(apiClient: apiClient, cache: cache)
    }

    override func tearDown() {
        sut = nil
        cache = nil
        apiClient = nil
        super.tearDown()
    }

    func test_fetchCountries_returnsMappedCountries_andSavesToCache_onAPISuccess() async throws {
        apiClient.stubbedResponse = [
            makeDTO(code: "EG"),
            makeDTO(code: "FR", name: "France", capital: "Paris")
        ]

        let countries = try await sut.fetchCountries()

        XCTAssertEqual(countries.count, 2)
        XCTAssertEqual(countries.first?.code, "EG")
        XCTAssertEqual(cache.savedCountries?.count, 2)
        XCTAssertEqual(cache.savedCountries?.last?.name, "France")
    }

    func test_fetchCountries_callsAllCountriesEndpoint() async throws {
        apiClient.stubbedResponse = [CountryDTO]()

        _ = try await sut.fetchCountries()

        XCTAssertEqual(apiClient.sentEndpoints.count, 1)
        XCTAssertEqual(apiClient.sentEndpoints.first?.path, "/all")
    }

    func test_fetchCountries_returnsCachedCountries_whenAPIFailsAndCacheExists() async throws {
        apiClient.stubbedError = APIError.server(statusCode: 500)
        let cached = [Country(code: "EG", name: "Egypt", capital: "Cairo",
                              currency: "EGP", flagURL: "")]
        cache.loadResult = .success(cached)

        let countries = try await sut.fetchCountries()

        XCTAssertEqual(countries, cached)
    }

    func test_fetchCountries_throws_whenAPIFailsAndCacheIsEmpty() async {
        apiClient.stubbedError = APIError.server(statusCode: 500)
        cache.loadResult = .success(nil)

        do {
            _ = try await sut.fetchCountries()
            XCTFail("expected an error")
        } catch APIError.server(let code) {
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func test_fetchCountries_throws_whenAPIFailsAndCacheReturnsEmptyArray() async {
        apiClient.stubbedError = APIError.server(statusCode: 500)
        cache.loadResult = .success([])

        do {
            _ = try await sut.fetchCountries()
            XCTFail("expected an error")
        } catch APIError.server {
            // expected
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func test_fetchCountries_rethrowsOriginalAPIError_whenCacheLoadFails() async {
        apiClient.stubbedError = APIError.server(statusCode: 500)
        cache.loadResult = .failure(NSError(domain: "test", code: 1))

        do {
            _ = try await sut.fetchCountries()
            XCTFail("expected an error")
        } catch APIError.server {
            // expected — original API error rethrown
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func test_fetchCountries_doesNotThrow_whenCacheSaveFails() async throws {
        apiClient.stubbedResponse = [makeDTO(code: "EG")]
        cache.saveError = NSError(domain: "test", code: 1)

        let countries = try await sut.fetchCountries()
        XCTAssertEqual(countries.count, 1)
    }

    // MARK: - Helpers

    private func makeDTO(
        code: String,
        name: String = "Egypt",
        capital: String = "Cairo"
    ) -> CountryDTO {
        CountryDTO(
            name: name, alpha2Code: code,
            capital: capital, currencies: nil,
            flags: .init(png: nil, svg: nil)
        )
    }
}
