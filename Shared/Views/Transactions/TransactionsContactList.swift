//
//  TransactionsContactList.swift
//  debtMe (iOS)
//
//  Created by Francisco Misael Landero Ychante on 18/04/21.
//

import SwiftUI

struct TransactionsContactList: View {
    @ObservedObject var contact : Contact
    
    //To hide view
    @Environment(\.presentationMode) var presentationMode
    
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    
    @State private var showAddTransaction = false
    
    #warning("Need to check way the row delete dont update")
    
    var body: some View {
        Group{
            #if os(iOS)
            List{
                Section(){
                    ContactsRow(contact: contact)
                        .environment(\.managedObjectContext, self.moc)
                }
                ForEach(contact.transactionsArray, id : \.id){ transaction in
                    TransactionsRow(transaction: transaction) 
                    
                }.onDelete(perform: deleteItem)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading:
                    Button(action:{
                            self.presentationMode.wrappedValue.dismiss()
                    }){
                        Label("Return", systemImage: "chevron.backward")
                            .foregroundColor(.gray)
                            .font(Font.system(.headline, design: .rounded).weight(.black))
                    },
                
                trailing:
                    Button(action:{
                        showAddTransaction.toggle()
                    }){
                        Label("Add", systemImage: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(Font.system(.headline, design: .rounded).weight(.black))
                    }
            )
            .toolbar {
                ToolbarItem(placement:.principal){
                    Text("\(Image(systemName: "dollarsign.square")) Summary")
                        .font(Font.system(.title, design: .rounded).weight(.black))
                }
            } 
            .sheet(isPresented: $showAddTransaction){
                TransactionsNewForm(contact: contact)
            }
        #elseif os(macOS)
            Section(){
                ContactsRow(contact: contact)
            }
            List{
                
                ForEach(contact.transactionsArray, id : \.id){ transaction in
                    TransactionsRow(transaction: transaction)
                }
            }
            .toolbar {
                ToolbarItem(placement:.automatic){
                    Text("\(Image(systemName: "dollarsign.square")) Summary")
                        .font(Font.system(.title, design: .rounded).weight(.black))
                }
                
                ToolbarItem(placement: .automatic ){
              
                        Label("Add", systemImage: "doc.badge.plus")
                            .foregroundColor(.accentColor)
                            .font(Font.system(.title, design: .rounded).weight(.black))
                            .onTapGesture {
                                showAddTransaction.toggle()
                            }
                }
            }
            .sheet(isPresented: $showAddTransaction){
                TransactionsNewForm(contact: contact)
            }
        #endif
        }
    }
    
    func deleteItem(at offsets: IndexSet) {
        
        for offset in offsets {
            let transaction =  self.contact.transactionsArray[offset]
            self.moc.delete(transaction)
        }
         
        try? self.moc.save()
        
       }
}

 
