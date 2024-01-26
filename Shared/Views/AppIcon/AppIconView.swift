//
//  AppIconView.swift
//  debtMe
//
//  Created by Misael Landero on 24/01/24.
//

import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack{
            Color.accentColor
                .clipShape(.circle)
            Image(.billetes)
                .resizable()
                .scaledToFit()
            Image(.pig)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    AppIconView()
}
