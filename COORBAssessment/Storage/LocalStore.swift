//
//  LocalStore.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import Foundation

class LocalStore {

    static let maxCountries = 5

    private let userDefaults: UserDefaults
    private let storageKey: String
    private(set) var addedCountries: [Country]

    init(userDefaults: UserDefaults = .standard,
         storageKey: String = "addedCountries") {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
        self.addedCountries = LocalStore.load(from: userDefaults, key: storageKey)
    }

    func add(_ country: Country) {
        guard !addedCountries.contains(where: { $0.code == country.code }) else { return }

        if addedCountries.count >= LocalStore.maxCountries {
            addedCountries.removeFirst()
        }

        addedCountries.append(country)
        persist()
    }

    func remove(_ country: Country) {
        addedCountries.removeAll { $0.code == country.code }
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(addedCountries) else { return }
        userDefaults.set(data, forKey: storageKey)
    }

    private static func load(from userDefaults: UserDefaults, key: String) -> [Country] {
        guard let data = userDefaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Country].self, from: data)) ?? []
    }
}
