//
//  AppPaidButtonStyle.swift
//  debtMe
//
//  Used for payment status actions such as Mark paid and Mark spent.
//

import SwiftUI

extension ButtonStyle where Self == AppActionButtonStyle {
    static var appPaid: AppActionButtonStyle {
        AppActionButtonStyle(tint: .green, cornerRadius: 18)
    }

    static var appPayAll: AppActionButtonStyle {
        AppActionButtonStyle(tint: .green)
    }
}

#Preview("Paid Button") {
    AppButtonStylePreviewContainer {
        Button {
        } label: {
            Label("Mark paid", systemImage: "checkmark")
        }
        .buttonStyle(.appPaid)
    }
}
