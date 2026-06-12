//
//  ButtonLabelShowSetled.swift
//  debtMe
//
//  Created by Misael Landero on 03/01/24.
//

import SwiftUI

struct ButtonLabelShowSetled: View {
    var label : String = "Show Settled"
    var systemImage: String = "eye"
    var foreground : Color = .white
    var body: some View { 
            HStack{
                LabelSFRounder(label: label, systemImage: systemImage, foreground: foreground)
                    .font(.body)
                    .padding()
            }
            .background(.gray)
            .cornerRadius(10)
            .padding()
       
       
    }
}

#Preview {
    ButtonLabelShowSetled()
}
