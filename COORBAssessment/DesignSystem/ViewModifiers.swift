//
//  ViewModifiers.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.Radius.md)
            .shadow(color: Theme.Colors.shadow,
                    radius: Theme.Shadow.card.radius,
                    x: Theme.Shadow.card.x,
                    y: Theme.Shadow.card.y)
    }
}

struct InfoCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Theme.Colors.cardBackgroundOpaque)
            .cornerRadius(Theme.Radius.lg)
            .shadow(color: Theme.Colors.shadow,
                    radius: Theme.Shadow.card.radius,
                    x: Theme.Shadow.card.x,
                    y: Theme.Shadow.card.y)
    }
}

struct ScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Theme.Colors.backgroundTop,
                                            Theme.Colors.backgroundBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            content
        }
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }
    func infoCardStyle() -> some View { modifier(InfoCardStyle()) }
    func screenBackground() -> some View { modifier(ScreenBackground()) }
}
