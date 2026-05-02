//
//  COORBAssessmentApp.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 30/04/2026.
//

import SwiftUI

@main
struct COORBAssessmentApp: App {

    private let coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            coordinator.start()
        }
    }
}
