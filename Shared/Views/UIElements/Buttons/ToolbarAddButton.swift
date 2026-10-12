//
//  ToolbarAddButton.swift
//  debtMe
//
//  Created by Misael Landero on 12/06/25.
//

import SwiftUI

struct ToolbarAddButton: View {
    let edition: Bool
    let action: () -> Void
    var body: some View {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            Button(action: action) {
                Label(
                    edition ? "Save" : "Add",
                    systemImage: edition ? "checkmark" : "plus"
                )
                .labelStyle(.iconOnly)
            }
            .buttonStyle(.glassProminent)
            .tint(AppTheme.actionTint)
            .accessibilityLabel(edition ? "Save" : "Add")
        } else {
            Button(action: action) {
                AppToolbarIconLabel(
                    systemImage: edition ? "checkmark" : "plus",
                    accessibilityLabel: edition ? "Save" : "Add"
                )
            }
            .buttonStyle(.plain)
        }
    }
}

struct SheetConfirmationButton: View {
    let edition: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(
                edition ? "Save" : "Add",
                systemImage: edition ? "checkmark" : "plus"
            )
            .appToolbarLabel()
            .labelStyle(.titleAndIcon)
        }
        .appSheetPrimaryButtonStyle()
    }
}

#Preview {
    NavigationStack(){
        Text("Sample view")
            .toolbar {
            ToolbarItem(placement: .primaryAction){
                ToolbarAddButton(edition: true, action: {})
            }
        }
    }
        
   
}
