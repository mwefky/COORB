//
//  Theme.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import SwiftUI

enum Theme {

    enum Colors {
        static let backgroundTop = Color.blue.opacity(0.2)
        static let backgroundBottom = Color.white
        static let cardBackground = Color.white.opacity(0.7)
        static let cardBackgroundOpaque = Color.white.opacity(0.8)
        static let placeholderBackground = Color.gray.opacity(0.15)
        static let shadow = Color.black.opacity(0.08)
        static let shadowStrong = Color.black.opacity(0.15)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
    }

    enum Shadow {
        static let card = (radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let strong = (radius: CGFloat(6), x: CGFloat(0), y: CGFloat(4))
    }

    enum FlagSize {
        static let width: CGFloat = 200
        static let height: CGFloat = 130
    }
}
