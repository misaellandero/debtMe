//
//  AppShowSettledButtonStyle.swift
//  debtMe
//
//  Used for compact filtering and status visibility actions.
//

import SwiftUI

extension ButtonStyle where Self == AppActionButtonStyle {
    static var appShowSettled: AppActionButtonStyle {
        AppActionButtonStyle(tint: .gray, expandsHorizontally: false, font: .body)
    }
}

#Preview("Show Settled Button") {
    AppButtonStylePreviewContainer {
        Button {
        } label: {
            Label("Show settled", systemImage: "eye")
        }
        .buttonStyle(.appShowSettled)
    }
}
