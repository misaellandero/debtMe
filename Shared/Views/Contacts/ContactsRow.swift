//
//  ContactsRow.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct ContactsRow: View {
    @ObservedObject var contact : Contact
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
      
        HStack{
            Text(contact.wrappedEmoji)
                .padding()
                .font(.largeTitle)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(20)
            VStack(alignment: .leading){
                
                HStack{
                    Text(contact.wrappedName)
                        .font(Font.system(.title, design: .rounded).weight(.bold))
                    Spacer()
                    if contact.haveALabel {
                        Text(contact.WrappedLabelName)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(4)
                            .font(Font.system(.caption, design: .rounded).weight(.semibold))
                            .background(contact.WrappedLabelColor)
                            .cornerRadius(10)
                    }
                }
                
                HStack{
                    Image(systemName: "banknote.fill")
                    Text("Balance")
                    Text(contact.balance.toCurrencyString())
                    Spacer()
                }
                
            }
            Spacer()
        }
        
        .font(Font.system(.body, design: .rounded).weight(.semibold))
        .padding(3)
        .listRowBackground(Color.secondary.opacity(0.2))
    }
}
