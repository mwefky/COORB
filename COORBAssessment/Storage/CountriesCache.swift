//
//  CountriesCache.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation

struct CachedCountries: Codable, Equatable {
    let savedAt: Date
    let countries: [Country]

    func isFresh(ttl: TimeInterval, now: Date = Date()) -> Bool {
        now.timeIntervalSince(savedAt) <= ttl
    }
}

protocol CountriesCache {
    func save(_ countries: [Country]) throws
    func load() throws -> CachedCountries?
}

class FileCountriesCache: CountriesCache {

    private let fileURL: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let now: () -> Date

    init(directory: URL? = nil,
         fileName: String = "countries.json",
         fileManager: FileManager = .default,
         encoder: JSONEncoder = JSONEncoder(),
         decoder: JSONDecoder = JSONDecoder(),
         now: @escaping () -> Date = Date.init) {
        let baseDir = directory ?? FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
        self.fileURL = baseDir.appendingPathComponent(fileName)
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder
        self.now = now
    }

    func save(_ countries: [Country]) throws {
        let envelope = CachedCountries(savedAt: now(), countries: countries)
        let data = try encoder.encode(envelope)
        try data.write(to: fileURL, options: .atomic)
    }

    func load() throws -> CachedCountries? {
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(CachedCountries.self, from: data)
    }
}
