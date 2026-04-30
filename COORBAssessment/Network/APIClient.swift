//
//  APIClient.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 30/04/2026.
//

import Foundation

protocol APIClient {
    func send<Response: Decodable>(_ endpoint: APIEndpoint) async throws -> Response
}

class URLSessionAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(baseURL: URL = AppConfig.apiBaseURL,
         session: URLSession = .shared,
         decoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    func send<Response: Decodable>(_ endpoint: APIEndpoint) async throws -> Response {
        guard let request = makeRequest(for: endpoint) else {
            throw APIError.invalidURL
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }

        if let http = response as? HTTPURLResponse,
           !(200..<300).contains(http.statusCode) {
            throw APIError.server(statusCode: http.statusCode)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    private func makeRequest(for endpoint: APIEndpoint) -> URLRequest? {
        var components = URLComponents(string: baseURL.absoluteString + endpoint.path)
        if !endpoint.queryItems.isEmpty {
            components?.queryItems = endpoint.queryItems
        }

        guard let url = components?.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        return request
    }
}
