//
//  AppAddButtonStyle.swift
//  debtMe
//
//  Used for creating new services, contacts, transactions, labels, and amount updates.
//

import SwiftUI

extension ButtonStyle where Self == AppActionButtonStyle {
    static var appAdd: AppActionButtonStyle {
        AppActionButtonStyle(tint: AppTheme.actionTint)
    }
}

#Preview("Add Button") {
    AppButtonStylePreviewContainer {
        Button {
        } label: {
            Label("Add", systemImage: "plus")
        }
        .buttonStyle(.appAdd)
    }
}
