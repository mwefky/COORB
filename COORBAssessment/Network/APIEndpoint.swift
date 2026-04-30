//
//  APIEndpoint.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 30/04/2026.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]

    init(path: String,
         method: HTTPMethod = .get,
         queryItems: [URLQueryItem] = []) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
    }
}
