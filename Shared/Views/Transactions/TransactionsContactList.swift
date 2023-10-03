//
//  TransactionsContactList.swift
//  debtMe (iOS)
//
//  Created by Francisco Misael Landero Ychante on 18/04/21.
//

import SwiftUI

struct TransactionsContactList: View {
    
    @State var filter : transactionsType = .all
    
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
                }
                ForEach(contact.transactionsArray, id : \.id){ transaction in
                    TransactionsRow(transaction: transaction) 
                    
                }.onDelete(perform: deleteItem)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarItems(
                trailing:
                    Button(action:{
                        showAddTransaction.toggle()
                    }){
                        Label("Add", systemImage: "plus.circle.fill")
                            .foregroundColor(.accentColor) 
                    }
            )
            .toolbar {
                ToolbarItem(placement:.principal){
                    Text("\(Image(systemName: "folder")) Summary")
                }
            }
        #elseif os(macOS)
            Section(){
                ContactsRow(contact: contact)
            }
            List{
                
                ForEach(contact.transactionsArray, id : \.id){ transaction in
                    TransactionsRow(transaction: transaction)
                }
                .onDelete(perform: deleteItem)
            }
            .toolbar {
                ToolbarItem(placement:.automatic){
                    Text("\(Image(systemName: "folder")) Summary")
                }
                
                ToolbarItem(placement: .automatic ){
              
                        Label("Add", systemImage: "plus.circle.fill")
                            .foregroundColor(.accentColor) 
                            .onTapGesture {
                                showAddTransaction.toggle()
                            }
                }
            }
        #endif
        }
        
        .sheet(isPresented: $showAddTransaction){
            TransactionsNewForm(contact: contact)
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

 
