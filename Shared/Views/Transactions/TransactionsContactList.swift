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
    
    
    //Filter and order
    @AppStorage("shortModeTransactions") var shortMode: shortMode = .amountAsc
    @AppStorage("showSettledTransactions") var showSettled: Bool = true
    
    // Computed property to filter and order transactions
    var filteredAndOrderedTransactions: [Transaction] {
        var filteredTransactions = contact.transactionsArray
        
        // Filter based on settled status
        if !showSettled {
            filteredTransactions = filteredTransactions.filter { !$0.settled }
        }
        
        // Order transactions based on shortMode
        switch shortMode {
        case .amountAsc:
            filteredTransactions.sort { $0.amount < $1.amount }
        default :
            filteredTransactions.sort { $0.amount > $1.amount }
            
        }
        
        return filteredTransactions
    }
    
    
    //Safe measures for delete
    @State private var showAlertDeletTransaction = false
    @State private var transactionToDelete: Transaction?
    
    var body: some View {
        Group{
            
            List{
                Section(){
                    ContactsRow(contact: contact, showDetails: true)
                }
                ForEach(filteredAndOrderedTransactions, id: \.id) { transaction in
                    TransactionsRow(transaction: transaction)
                }
                .onDelete(perform: deleteItem)
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
                
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        
                        Label("Sort by Amount", systemImage: "arrow.up.and.down.text.horizontal")
                        
                        Button(action: {
                            shortMode = .amountAsc
                        }) {
                            Label("Lower First", systemImage: "platter.filled.top.and.arrow.up.iphone")
                        }
                        Button(action: {
                            shortMode = .amountDes
                        }) {
                            Label("Higher First", systemImage: "platter.filled.bottom.and.arrow.down.iphone")
                        }
                        Divider()
                        
                        Button(action: {
                            showSettled.toggle()
                        }) {
                            Label(NSLocalizedString((showSettled ? "Hide" : "Show") + " Settled", comment: ""), systemImage: showSettled ? "eye.slash" :"eye") 
                        }
                        
                    } label: {
                        Label("Filter", systemImage: "line.horizontal.3.decrease.circle.fill")
                            .foregroundColor(.gray)
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
            .alert(isPresented: $showAlertDeletTransaction) {
                Alert(
                    title: Text("Delete Transaction"),
                    message: Text("This transaction is unsettled and has recorded payments. Are you sure you want to delete?"),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .destructive(Text("Delete")) {
                        // Perform the deletion when the user confirms
                        if let transactionToDelete = transactionToDelete {
                            performDeletion(for: transactionToDelete)
                        }
                    }
                )
            }
            
        }
        
    }
    
    
    
    //check is safe to delete
    func deleteItem(at offsets: IndexSet) {
        for offset in offsets {
            
            let transaction = self.filteredAndOrderedTransactions[offset]
            
            if !transaction.settled && transaction.paymentsArray.count != 0 {
                transactionToDelete = transaction
                showAlertDeletTransaction = true
            } else {
                performDeletion(for: transaction)
            }
            
        }
    }
    
    // Helper method to perform deletion
    func performDeletion(for transaction: Transaction) {
        
        //Delete payment related
        for payment in transaction.paymentsArray {
            self.moc.delete(payment)
        }
        
        self.moc.delete(transaction)
        
        try? self.moc.save()
    }
    
}
