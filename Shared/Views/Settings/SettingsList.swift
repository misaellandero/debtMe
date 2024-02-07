//
//  SettingsList.swift
//  debtMe
//
//  Created by Misael Landero on 26/01/24.
//

import SwiftUI

struct SettingsList: View {
    var body: some View {
        List{
            Section{
                NavigationLink(destination: WhatsNewView()) {
                    Label("About this App", systemImage: "star.bubble.fill")
                }
               /* NavigationLink(destination: AboutThisAppView()) {
                    Label("What's New?", systemImage: "info.bubble.fill")
                }*/
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsList()
}
