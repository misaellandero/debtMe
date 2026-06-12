//
//  EmptyPaymentView.swift
//  debtMe
//
//  Created by Misael Landero on 02/10/23.
//

import SwiftUI

struct EmptyPaymentView: View {
    var empty = false
    var image : ImageResource = .cromaPig
    var text : LocalizedStringKey = "Nothing around here yet!"
    var body: some View {
        VStack{
            if empty {
                Text(text)
            }
            Image(image)
                .resizable()
                .scaledToFit()
                .padding()
                .frame(height: 120)
        }
    }
}
