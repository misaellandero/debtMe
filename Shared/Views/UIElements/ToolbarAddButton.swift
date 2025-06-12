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
        Button(action: action) {
            Label(edition ? "Save" : "Add", systemImage: "plus")
        }
        .buttonStyle(BorderedProminentButtonStyle())
        .tint(.accentColor)
    }
}

#Preview {
    NavigationStack(){
        Text("sime view")
            .toolbar {
            ToolbarItem(placement: .primaryAction){
                ToolbarAddButton(edition: true, action: {})
            }
        }
    }
        
   
}
