//
//  WhatsNewView.swift
//  debtMe
//
//  Created by Misael Landero on 26/01/24.
//

import SwiftUI

//For the settings App
struct WhatsNewView: View {
    var body: some View {
        List{
            FeaturesList()
        }
        .navigationTitle("What's New?")
    }
}

#Preview {
    WhatsNewView()
}
