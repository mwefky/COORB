//
//  URLProtocolStub.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 30/04/2026.
//

import Foundation

final class URLProtocolStub: URLProtocol {

    static var responseData: Data?
    static var statusCode: Int = 200
    static var error: Error?

    static func reset() {
        responseData = nil
        statusCode = 200
        error = nil
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let error = URLProtocolStub.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        let url = request.url ?? URL(string: "https://example.com")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: URLProtocolStub.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        if let data = URLProtocolStub.responseData {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

extension URLSession {
    static func stubbed() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: config)
    }
}
