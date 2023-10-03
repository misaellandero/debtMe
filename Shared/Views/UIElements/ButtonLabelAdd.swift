//
//  ButtonLabelAdd.swift
//  debtMe
//
//  Created by Misael Landero on 22/04/23.
//

import SwiftUI

struct ButtonLabelAdd: View {
    var label : String = "Add"
    var systemImage: String = "plus.circle.fill"
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

struct ButtonLabelAdd_Previews: PreviewProvider {
    static var previews: some View {
        ButtonLabelAdd(label: "Add", systemImage:  "plus.circle.fill", foreground: .white)
    }
}
