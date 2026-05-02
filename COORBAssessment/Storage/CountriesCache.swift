//
//  CountriesCache.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation

protocol CountriesCache {
    func save(_ countries: [Country]) throws
    func load() throws -> [Country]?
}

class FileCountriesCache: CountriesCache {
    private let fileURL: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(directory: URL? = nil,
         fileName: String = "countries.json",
         fileManager: FileManager = .default,
         encoder: JSONEncoder = JSONEncoder(),
         decoder: JSONDecoder = JSONDecoder()) {
        let baseDir = directory ?? FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
        self.fileURL = baseDir.appendingPathComponent(fileName)
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder
    }

    func save(_ countries: [Country]) throws {
        let data = try encoder.encode(countries)
        try data.write(to: fileURL, options: .atomic)
    }

    func load() throws -> [Country]? {
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([Country].self, from: data)
    }
}
