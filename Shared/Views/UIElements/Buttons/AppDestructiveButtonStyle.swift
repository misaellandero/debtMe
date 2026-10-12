//
//  AppDestructiveButtonStyle.swift
//  debtMe
//
//  Used for delete, remove, and destructive actions.
//

import SwiftUI

extension ButtonStyle where Self == AppActionButtonStyle {
    static func appAction(
        tint: Color,
        foreground: Color = .white,
        expandsHorizontally: Bool = true
    ) -> AppActionButtonStyle {
        AppActionButtonStyle(tint: tint, foreground: foreground, expandsHorizontally: expandsHorizontally)
    }

    static var appDestructive: AppActionButtonStyle {
        AppActionButtonStyle(tint: AppTheme.destructiveTint)
    }
}

#Preview("Destructive Button") {
    AppButtonStylePreviewContainer {
        Button(role: .destructive) {
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .buttonStyle(.appDestructive)
    }
}
