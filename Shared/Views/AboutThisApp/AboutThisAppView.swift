//
//  AboutThisAppView.swift
//  debtMe
//
//  Created by Misael Landero on 26/01/24.
//

import SwiftUI

struct AboutThisAppView: View {
    var body: some View {
        List{
            Section{
                DebtMeAppHeaderView()
            }
            Section{
                Text("")
            }
        }
    }
}

#Preview {
    AboutThisAppView()
}
