//
//  EmptyPaymentView.swift
//  debtMe
//
//  Created by Misael Landero on 02/10/23.
//

import SwiftUI

struct EmptyPaymentView: View {
    var empty = false
    var body: some View {
        VStack{
            if empty {
                Text("Nothing around here yet!")
            }
            Image(.cromaPig)
                .resizable()
                .scaledToFit()
                .padding()
                .frame(height: 120)
        }
    }
}
