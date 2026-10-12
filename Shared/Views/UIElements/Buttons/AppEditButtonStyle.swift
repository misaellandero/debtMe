//
//  AppEditButtonStyle.swift
//  debtMe
//
//  Used for edit actions in detail views and image controls.
//

import SwiftUI

extension ButtonStyle where Self == AppActionButtonStyle {
    static var appEdit: AppActionButtonStyle {
        AppActionButtonStyle(tint: AppTheme.actionTint, foreground: .white, cornerRadius: 18)
    }
}

#Preview("Edit Button") {
    AppButtonStylePreviewContainer {
        Button {
        } label: {
            Label("Edit", systemImage: AppIcons.edit)
        }
        .buttonStyle(.appEdit)
    }
}
