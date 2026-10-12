//
//  AppResetButtonStyle.swift
//  debtMe
//
//  Used for undo/reset actions that are not destructive.
//

import SwiftUI

extension ButtonStyle where Self == AppActionButtonStyle {
    static var appReset: AppActionButtonStyle {
        AppActionButtonStyle(tint: .orange)
    }
}

#Preview("Reset Button") {
    AppButtonStylePreviewContainer {
        Button {
        } label: {
            Label("Reset", systemImage: "arrow.counterclockwise")
        }
        .buttonStyle(.appReset)
    }
}
