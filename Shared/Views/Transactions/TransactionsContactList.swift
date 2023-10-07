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
    @State private var showEditContact = false
    var body: some View {
        Group{
           
            List{
                Section(){
                    ContactsRow(contact: contact, showDetails: true)
                }
                ForEach(contact.transactionsArray, id : \.id){ transaction in
                    TransactionsRow(transaction: transaction) 
                    
                }.onDelete(perform: deleteItem)
            }
            .toolbar {
                ToolbarItem(placement:.automatic){
                    Text("\(Image(systemName: "folder")) Summary")
                }
                 
                
                ToolbarItem(placement: .automatic ){
                    
                    Button(action:{
                        showEditContact.toggle()
                    }){
                        Label("Edit", systemImage: "square.and.pencil")
                            .foregroundColor(.accentColor)
                    }
                }
                
                ToolbarItem(placement: .automatic ){
                    
                    Button(action:{
                        showAddTransaction.toggle()
                    }){
                        Label("Add", systemImage: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showAddTransaction){
                TransactionsNewForm(contact: contact)
            }
            .sheet(isPresented: $showEditContact){
                ContactsNewForm(edition: true, contactToEdit: contact)
            }
            #if os(iOS)
            .listStyle(InsetGroupedListStyle())
            #endif
           
      
        }
     
    }
    
    func deleteItem(at offsets: IndexSet) {
        
        for offset in offsets {
            let transaction =  self.contact.transactionsArray[offset]
            
            //Delete payment related
            for payment in transaction.paymentsArray {
                self.moc.delete(payment)
            }
            
            self.moc.delete(transaction)
        }
         
        try? self.moc.save()
        
       }
}

 
