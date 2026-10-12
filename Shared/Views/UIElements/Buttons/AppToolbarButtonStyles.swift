//
//  AppToolbarButtonStyles.swift
//  debtMe
//
//  Used for compact toolbar actions in navigation bars and sheets.
//

import SwiftUI

extension ButtonStyle where Self == AppToolbarCircleButtonStyle {
    static var appToolbarAdd: AppToolbarCircleButtonStyle {
        AppToolbarCircleButtonStyle(tint: AppTheme.actionTint, foreground: .white)
    }

    static var appToolbarEdit: AppToolbarCircleButtonStyle {
        AppToolbarCircleButtonStyle(tint: AppTheme.actionTint, foreground: .white)
    }

    static var appToolbarSave: AppToolbarCircleButtonStyle {
        AppToolbarCircleButtonStyle(tint: AppTheme.actionTint, foreground: .white)
    }

    static var appToolbarCancel: AppToolbarCircleButtonStyle {
        #if os(macOS)
        AppToolbarCircleButtonStyle(tint: AppTheme.destructiveTint, foreground: .white, usesFilledBackground: true, size: 34)
        #else
        AppToolbarCircleButtonStyle(tint: AppTheme.destructiveTint, foreground: .white, usesFilledBackground: true, size: 44)
        #endif
    }
}

#Preview("Toolbar Buttons") {
    AppButtonStylePreviewContainer {
        HStack(spacing: 16) {
            Button {
            } label: {
                Label("Close", systemImage: "xmark")
            }
            .buttonStyle(.appToolbarCancel)

            Button {
            } label: {
                Label("Add", systemImage: "plus")
            }
            .buttonStyle(.appToolbarAdd)

            Button {
            } label: {
                Label("Save", systemImage: "checkmark")
            }
            .buttonStyle(.appToolbarSave)
        }
    }
}
