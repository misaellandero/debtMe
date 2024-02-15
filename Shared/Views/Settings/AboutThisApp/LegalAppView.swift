//
//  LegalAppView.swift
//  debtMe
//
//  Created by Misael Landero on 15/02/24.
//

import SwiftUI

struct LegalAppView: View {
    var headerImage : String
    var title : LocalizedStringKey
    var text : LocalizedStringKey
    
    var body: some View {
        List {
            Section{
                VStack{
                    HStack{
                        Spacer()
                        Image(systemName: headerImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .padding()
                        Spacer()
                    }
                    HStack{
                        Spacer()
                        Text(title)
                            .font(.largeTitle)
                        Spacer()
                    }
                }
                .foregroundColor(.white)
                .listRowBackground(Color.accentColor)
            }
            
            Section{
                HStack{
                    Text(text)
                }.padding()
            }
             
        }
        #if os(iOS)
        .listStyle(InsetGroupedListStyle())
        #endif
        .navigationTitle(title)
    }
}

#Preview {
    LegalAppView(headerImage: "hand.raised", title: "Privacy Policy", text: """
This is the privacy policy of Misael Landero, its products and services.

Misael Landero does not sell, monetize, analyze or collect any type of information from its users. All applications that support data synchronization use iCloud, and the information is not accessible to the developer.

Some applications also use geolocation services and maps, which are provided by Apple and required each time they are used on your device, you can disable these services in the settings section of your device.

For more information on Apple's privacy policy, its services or iCloud visit www.apple.com/legal/privacy
""")
}
