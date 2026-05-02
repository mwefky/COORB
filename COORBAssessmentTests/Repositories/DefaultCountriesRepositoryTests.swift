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

    private let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)
    private let ttl: TimeInterval = 3600

    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient()
        cache = MockCountriesCache()
        sut = DefaultCountriesRepository(
            apiClient: apiClient,
            cache: cache,
            ttl: ttl,
            now: { self.referenceDate }
        )
    }

    override func tearDown() {
        sut = nil
        cache = nil
        apiClient = nil
        super.tearDown()
    }

    func test_fetchCountries_returnsAndCachesAPIResult_whenNoCache() async throws {
        apiClient.stubbedResponse = [
            makeDTO(code: "EG"),
            makeDTO(code: "FR", name: "France", capital: "Paris")
        ]
        cache.loadResult = .success(nil)

        let countries = try await sut.fetchCountries()

        XCTAssertEqual(countries.count, 2)
        XCTAssertEqual(countries.first?.code, "EG")
        XCTAssertEqual(cache.savedCountries?.count, 2)
    }

    func test_fetchCountries_callsAllCountriesEndpoint() async throws {
        apiClient.stubbedResponse = [CountryDTO]()
        cache.loadResult = .success(nil)

        _ = try await sut.fetchCountries()

        XCTAssertEqual(apiClient.sentEndpoints.count, 1)
        XCTAssertEqual(apiClient.sentEndpoints.first?.path, "/all")
    }

    func test_fetchCountries_returnsFreshCache_withoutWaitingForAPI() async throws {
        let cached = [
            Country(code: "EG", name: "Egypt", capital: "Cairo",
                    currency: "EGP", flagURL: "")
        ]
        cache.loadResult = .success(CachedCountries(
            savedAt: referenceDate.addingTimeInterval(-60),
            countries: cached
        ))
        apiClient.stubbedResponse = [makeDTO(code: "JP", name: "Japan", capital: "Tokyo")]

        let countries = try await sut.fetchCountries()

        XCTAssertEqual(countries, cached)
    }

    func test_fetchCountries_skipsStaleCache_andHitsAPI() async throws {
        let cached = [Country(code: "EG", name: "Egypt", capital: "Cairo",
                              currency: "EGP", flagURL: "")]
        cache.loadResult = .success(CachedCountries(
            savedAt: referenceDate.addingTimeInterval(-(ttl + 1)),
            countries: cached
        ))
        apiClient.stubbedResponse = [makeDTO(code: "JP", name: "Japan", capital: "Tokyo")]

        let countries = try await sut.fetchCountries()

        XCTAssertEqual(countries.first?.code, "JP")
    }

    func test_fetchCountries_fallsBackToStaleCache_whenAPIFails() async throws {
        let cached = [Country(code: "EG", name: "Egypt", capital: "Cairo",
                              currency: "EGP", flagURL: "")]
        cache.loadResult = .success(CachedCountries(
            savedAt: referenceDate.addingTimeInterval(-(ttl + 1)),
            countries: cached
        ))
        apiClient.stubbedError = APIError.server(statusCode: 500)

        let countries = try await sut.fetchCountries()

        XCTAssertEqual(countries, cached)
    }

    func test_fetchCountries_throws_whenAPIFailsAndNoCache() async {
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
        cache.loadResult = .success(CachedCountries(
            savedAt: referenceDate.addingTimeInterval(-(ttl + 1)),
            countries: []
        ))

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
        cache.loadResult = .success(nil)
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
