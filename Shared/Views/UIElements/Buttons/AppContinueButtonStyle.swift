//
//  AppContinueButtonStyle.swift
//  debtMe
//
//  Used for positive confirmation flows such as Save, Continue, and Done.
//

import SwiftUI

extension ButtonStyle where Self == AppActionButtonStyle {
    static var appContinue: AppActionButtonStyle {
        AppActionButtonStyle(tint: AppTheme.actionTint)
    }
}

#Preview("Continue Button") {
    AppButtonStylePreviewContainer {
        Button {
        } label: {
            Label("Save", systemImage: "checkmark")
        }
        .buttonStyle(.appContinue)
    }
}
