//
//  APIClientTests.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 30/04/2026.
//

import XCTest
@testable import COORBAssessment

final class APIClientTests: XCTestCase {

    private var sut: URLSessionAPIClient!

    override func setUp() {
        super.setUp()
        URLProtocolStub.reset()
        sut = URLSessionAPIClient(
            baseURL: URL(string: "https://example.com")!,
            session: .stubbed()
        )
    }

    override func tearDown() {
        URLProtocolStub.reset()
        sut = nil
        super.tearDown()
    }

    func test_send_decodesSuccessfulResponse() async throws {
        URLProtocolStub.statusCode = 200
        URLProtocolStub.responseData = #"{"value":"ok"}"#.data(using: .utf8)

        let result: Stub = try await sut.send(.init(path: "/test"))
        XCTAssertEqual(result.value, "ok")
    }

    func test_send_throwsServerErrorOnNon2xx() async {
        URLProtocolStub.statusCode = 500
        URLProtocolStub.responseData = Data()

        do {
            let _: Stub = try await sut.send(.init(path: "/test"))
            XCTFail("expected an error")
        } catch APIError.server(let code) {
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func test_send_throwsDecodingOnInvalidJSON() async {
        URLProtocolStub.statusCode = 200
        URLProtocolStub.responseData = "not json".data(using: .utf8)

        do {
            let _: Stub = try await sut.send(.init(path: "/test"))
            XCTFail("expected an error")
        } catch APIError.decoding {
            // expected
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func test_send_wrapsTransportError() async {
        URLProtocolStub.error = NSError(domain: "test", code: -1009)

        do {
            let _: Stub = try await sut.send(.init(path: "/test"))
            XCTFail("expected an error")
        } catch APIError.transport {
            // expected
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func test_send_buildsRequestWithQueryItems() async throws {
        URLProtocolStub.statusCode = 200
        URLProtocolStub.responseData = #"{"value":"ok"}"#.data(using: .utf8)

        let endpoint = APIEndpoint(
            path: "/search",
            queryItems: [URLQueryItem(name: "q", value: "egypt")]
        )
        let _: Stub = try await sut.send(endpoint)
    }
}

private struct Stub: Decodable {
    let value: String
}
