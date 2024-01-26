//
//  ButtonLabelContinue.swift
//  debtMe
//
//  Created by Misael Landero on 25/01/24.
//

import SwiftUI

struct ButtonLabelContinue: View {
    var label : String = "Continue"
    var systemImage: String = "checkmark.circle"
    var foreground : Color = .white
    var body: some View {
        HStack{
            Spacer()
            LabelSFRounder(label: label, systemImage: systemImage, foreground: foreground)
                .font(.headline)
                .padding()
            Spacer()
        }
        .background(Color.accentColor )
        .cornerRadius(10)
        .padding()
    }
}

#Preview {
    ButtonLabelContinue()
}
