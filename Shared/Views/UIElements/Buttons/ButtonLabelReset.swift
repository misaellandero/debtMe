//
//  ButtonLabelReset.swift
//  debtMe
//
//  Created by Misael Landero on 02/10/23.
//

import SwiftUI

struct ButtonLabelReset: View {
    var label : String = "Toggle Status to Unpaid"
    var systemImage: String = "arrow.counterclockwise"
    var foreground : Color = .white
    var body: some View {
        HStack{
            Spacer()
            LabelSFRounder(label: label, systemImage: systemImage, foreground: foreground)
                .font(.headline)
                .padding()
            Spacer()
        }
        .background(.orange)
        .cornerRadius(10)
        .padding()
    }
}

#Preview {
    ButtonLabelReset()
}
