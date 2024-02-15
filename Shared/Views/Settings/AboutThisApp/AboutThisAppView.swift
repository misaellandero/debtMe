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
                HStack{
                    Image(.memoji)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(maxWidth: 100)
                    Text("Hi, my name is Misael. I like to help companies grow their businesses. Creating elegant and inclusive websites and apps.")
                }
            }
            
            Section(header: Text("Contact Me")){
                Link("LinkedIn", destination: URL(string: "https://www.linkedin.com/mwlite/in/francisco-misael-landero-ychante-07b6a9122")!)
                Link("Instagram", destination: URL(string: "https://www.instagram.com/misaellandero")!)
                Link("Twitter", destination: URL(string: "https://twitter.com/MisaelLandero")!)
                Link("My WebSite", destination: URL(string: "https://misaellandero.com")!)
                Text("Or via mail hola@misaellandero.com")
            }
        }
        .navigationTitle("About this App")
    }
}

#Preview {
    AboutThisAppView()
}
