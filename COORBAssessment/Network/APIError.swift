//
//  APIError.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 30/04/2026.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case transport(Error)
    case server(statusCode: Int)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .transport(let error):
            return error.localizedDescription
        case .server(let code):
            return "Server returned status \(code)."
        case .decoding:
            return "Could not parse the server response."
        }
    }
}
