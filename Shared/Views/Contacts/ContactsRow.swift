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
    
    var showDetails = false
    
    var body: some View {
        
        ZStack(alignment: .leading){
            VStack{
                HStack{
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
                Spacer()
            }
            HStack{
                VStack{
                    Text(contact.wrappedEmoji)
                        .padding()
                        .font(.largeTitle)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(20)
                    
                }
                
                VStack(alignment: .leading){
                    
                    HStack{ 
#if os(visionOS)
                        Text(contact.wrappedName)
#else
                        Text(contact.wrappedName)
                            .font(Font.system(.title, design: .rounded).weight(.bold))
#endif
                        
                    }
                    
                    if showDetails {
                        HStack{
                            Text(LocalizedStringKey("They Owes me"))
                            Spacer()
                            Text(contact.totalLoans.toCurrencyString())
                                .foregroundColor(.blue)
                            
                        }
                        HStack{
                            Text(LocalizedStringKey("I Owe Them"))
                            Spacer()
                            Text(contact.totalDebt.toCurrencyString())
                                .foregroundColor(.orange)
                            
                        }
                    }
                    
#if os(visionOS)
                    VStack(alignment: .leading){
                        Text("Balance")
                        
                        Text(contact.balance.toCurrencyString())
                        
                    }
#else
                    HStack{
                        Text("Balance")
                        
                        Spacer()
                        Text(contact.balance.toCurrencyString())
                        
                    }
#endif
                    
                    
                    
                }
                Spacer()
            }
            
            .font(Font.system(.body, design: .rounded).weight(.semibold))
            .padding(3)
            .listRowBackground(Color.secondary.opacity(0.2))
            
#if os(visionOS)
            if contact.haveALabel {
                HStack{
                    Image(systemName: "circle.fill")
                        .foregroundColor(contact.WrappedLabelColor)
                    Text(contact.WrappedLabelName)
                        .fontWeight(.bold)
                        .padding(4)
                        .cornerRadius(10)
                }
            }
#endif
        }
        
    }
}
