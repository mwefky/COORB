//
//  COORBAssessmentApp.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 30/04/2026.
//

import SwiftUI

@main
struct COORBAssessmentApp: App {

    private let coordinator: AppCoordinator

    init() {
        if ProcessInfo.processInfo.arguments.contains("--reset") {
            UserDefaults.standard.removeObject(forKey: "addedCountries")
        }
        self.coordinator = AppCoordinator()
    }

    var body: some Scene {
        WindowGroup {
            coordinator.start()
        }
    }
}
