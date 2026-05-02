//
//  View+HideKeyboard.swift
//  COORBAssessment
//
//  Created by Mina Wefky on 02/05/2026.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
