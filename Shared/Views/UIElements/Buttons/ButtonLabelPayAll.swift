//
//  ButtonLabelPayALL.swift
//  debtMe
//
//  Created by Misael Landero on 02/10/23.
//

import SwiftUI

struct ButtonLabelPayAll: View {
    var label : String = "Mark as Settled"
    var systemImage: String = "face.smiling"
    var foreground : Color = .white
    var body: some View {
        HStack{
            Spacer()
            LabelSFRounder(label: label, systemImage: systemImage, foreground: foreground)
                .font(.headline)
                .padding()
            Spacer()
        }
        .background(.green)
        .cornerRadius(10)
        .padding()
    }
}

#Preview {
    ButtonLabelPayAll()
}
