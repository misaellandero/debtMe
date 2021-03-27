//
//  ContactsRow.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct ContactsRow: View {
    @State var contact : Contact
    var body: some View {
        VStack{
            HStack{
                Text(contact.wrappedEmoji)
                    .padding()
                    .font(.largeTitle)
                    .background(Color.secondary)
                    .cornerRadius(20)
                VStack(alignment: .leading){
                    Text("Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.black)
                    Text(contact.wrappedName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack{
                        Image(systemName: "dollarsign.square.fill")
                        Text("Balance")
                        Text("$" + String(format: "%.2f",  contact.balance))
                        Spacer()
                        
                        if contact.haveALabel {
                            Text(contact.WrappedLabelName)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(4)
                                .font(.caption)
                                .background(contact.WrappedLabelColor)
                                .cornerRadius(20)
                        }
                    }
                    
                }
                Spacer()
            }
            
        }
        .font(Font.system(.body, design: .rounded).weight(.semibold))
        .padding()
    }
}
/*
struct ContactsRow_Previews: PreviewProvider {
    static var previews: some View {
        ContactsRow(name: "Daniel Rode", emoji: "🤓", tag: "Friend", tagColor: Color.green, balance: 200)
            .previewLayout(.fixed(width: 400, height: 90))
            .preferredColorScheme(.dark)
        ContactsRow(name: "Daniel Rode", emoji: "🤓", tag: "Friend", tagColor: Color.green, balance: 200)
                .previewLayout(.fixed(width: 400, height: 90))
            .preferredColorScheme(.light)
    }
}*/
