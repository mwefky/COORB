//
//  MockAPIClient.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation
@testable import COORBAssessment

final class MockAPIClient: APIClient {

    var stubbedResponse: Any?
    var stubbedError: Error?
    private(set) var sentEndpoints: [APIEndpoint] = []

    func send<Response: Decodable>(_ endpoint: APIEndpoint) async throws -> Response {
        sentEndpoints.append(endpoint)

        if let stubbedError {
            throw stubbedError
        }

        guard let response = stubbedResponse as? Response else {
            fatalError("MockAPIClient: response not configured for \(Response.self)")
        }
        return response
    }
}
