//
//  DebtMeAppHeaderView.swift
//  debtMe
//
//  Created by Misael Landero on 26/01/24.
//

import SwiftUI

struct DebtMeAppHeaderView: View {
    var body: some View {
        VStack{
            AppIconView()
                .frame(height: 150)
            VStack(){
                Text("Wellcome to")
                    .font(.headline)
                HStack{
                    Text("debtMe")
                        .font(.largeTitle.weight(.bold))
                    + Text(getCurrentAppVersion())
                        .font(.callout)
                        .baselineOffset(10)
                }
            }
        }
        .padding()
    }
    // Get current Version of the App
    func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "1.0.0"
        let version = (appVersion as! String)
        return version
    }
}

#Preview {
    DebtMeAppHeaderView()
}
