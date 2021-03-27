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
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(20)
                VStack(alignment: .leading){
                    HStack{
                        Text("Name")
                                .font(Font.system(.caption, design: .rounded).weight(.semibold))
                                .foregroundColor(.secondary)
                                .fontWeight(.black)
                        Spacer()
                        if contact.haveALabel {
                            Text(contact.WrappedLabelName)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(4)
                                .padding(.horizontal,4)
                                .font(Font.system(.caption, design: .rounded).weight(.semibold))
                                .background(contact.WrappedLabelColor)
                                .cornerRadius(10)
                        }
                    }
                    Text(contact.wrappedName)
                        .font(Font.system(.title, design: .rounded).weight(.bold))
                    
                    HStack{
                        Image(systemName: "dollarsign.square.fill")
                        Text("Balance")
                        Text("$" + String(format: "%.2f",  contact.balance))
                        Spacer()
                    }
                    
                }
                Spacer()
            }
            
        }
        .font(Font.system(.body, design: .rounded).weight(.semibold))
        .padding(3)
        .listRowBackground(Color.secondary.opacity(0.2))
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
