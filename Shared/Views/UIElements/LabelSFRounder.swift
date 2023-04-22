//
//  LabelSFRounder.swift
//  debtMe
//
//  Created by Misael Landero on 22/04/23.
//

import SwiftUI

struct LabelSFRounder: View {
    var label : String
    var systemImage : String
    var foreground : Color
    var body: some View {
        Label(LocalizedStringKey(label), systemImage: systemImage)
            .foregroundColor(foreground)
            .font(Font.system(.headline, design: .rounded).weight(.black))
    }
}

struct LabelSFRounder_Previews: PreviewProvider {
    static var previews: some View {
        LabelSFRounder(label: "Cancel", systemImage: "xmark", foreground: .gray)
    }
}
