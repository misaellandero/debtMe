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
    
    @State var searchQuery = ""
    
    
    //Filter and order
    @AppStorage("shortModeTransactions") var shortMode: shortMode = .dateCreationDes
  
    
    // Computed property to filter and order transactions
    var filteredAndOrderedTransactions: [Transaction] {
        var filteredTransactions = contact.transactionsArray
        
        // Filter based on settled status
        if !contact.hideSettled {
            filteredTransactions = filteredTransactions.filter { !$0.settled }
        }
        
        // Order transactions based on shortMode
        switch shortMode {
        case .amountAsc:
            filteredTransactions.sort { $0.amount < $1.amount }
        case .amountDes :
            filteredTransactions.sort { $0.amount > $1.amount }
        case .dateCreationAsc:
            filteredTransactions.sort { $0.wrappedDateCreation < $1.wrappedDateCreation }
        case .dateCreationDes:
            filteredTransactions.sort { $0.wrappedDateCreation > $1.wrappedDateCreation }
        case .dateSettledAsc:
            filteredTransactions.sort { $0.wrappedDateSettled < $1.wrappedDateSettled }
        case .dateSettledDes:
            filteredTransactions.sort { $0.wrappedDateSettled > $1.wrappedDateSettled }
        default:
            //same like creaation des
            filteredTransactions.sort { $0.wrappedDateCreation > $1.wrappedDateCreation }
        }
        
        if searchQuery.isEmpty {
            return filteredTransactions
        } else {
            // Further filter transactions based on the search query
            return filteredTransactions.filter { transaction in
                let descriptionMatches = transaction.wrappedDes.localizedCaseInsensitiveContains(searchQuery) == true
                let notesMatches = transaction.wrappedNotes.localizedCaseInsensitiveContains(searchQuery) == true
                return descriptionMatches || notesMatches
            }
        }
         
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
                    
                    //No records
                    if contact.transactionsArray.isEmpty {
                        HStack{
                            Spacer()
                            VStack{
                                EmptyPaymentView(empty: true)
                                Button {
                                    showAddTransaction.toggle()
                                } label: {
                                    Label("New Transaction", systemImage: "plus.circle.fill")
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(BorderedProminentButtonStyle())
                            }
                            Spacer()
                        }
                         
                        
                    } else {
                        //HideSettled info
                        if !contact.hideSettled {
                            
                            Button(action: {
                                contact.hideSettled.toggle()
                                try? self.moc.save()
                            }) {
                                HStack{
                                    Spacer()
                                    VStack{
                                        Image(.notSeePig)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100)
                                        ButtonLabelShowSetled()
                                    }
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                  
                    
                }
                #if os(iOS)
                .searchable(text: $searchQuery)
                #endif
            
            
        }
            
            .toolbar {
                
                ToolbarItem(placement: .automatic ){
                    
                    Button(action:{
                        showEditContact.toggle()
                    }){
                        Label("Edit", systemImage: "square.and.pencil")
                            .foregroundColor(.accentColor)
                    }
                }
                
                #if os(macOS)
                ToolbarItem(placement: .automatic ){
                    SearchTextField(searchQuery: $searchQuery)
                        
                }
                #endif
                
                ToolbarItem(placement: .primaryAction ){
                    
                    Button(action:{
                        showAddTransaction.toggle()
                    }){
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .tint(.accentColor)
                }
                
                ToolbarItem(placement: .automatic) {
                    Menu {
                        
                        //Order by Amount
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
                        
                        //Order by Date
                        
                        Divider()
                        Label("Sort by Date", systemImage: "arrow.up.and.down.text.horizontal")
                        
                        Button(action: {
                            shortMode = .dateCreationAsc
                        }) {
                            Label("Oldest Creation First", systemImage: "platter.filled.top.and.arrow.up.iphone")
                        }
                        Button(action: {
                            shortMode = .dateCreationDes
                        }) {
                            Label("Newest Creation First", systemImage: "platter.filled.bottom.and.arrow.down.iphone")
                        }
                        
                        Button(action: {
                            shortMode = .dateSettledAsc
                        }) {
                            Label("Oldest Settled First", systemImage: "platter.filled.top.and.arrow.up.iphone")
                        }
                        Button(action: {
                            shortMode = .dateSettledDes
                        }) {
                            Label("Newest Settled First", systemImage: "platter.filled.bottom.and.arrow.down.iphone")
                        }
                        
                        //Payed
                        Divider()
                        
                        Button(action: {
                            contact.hideSettled.toggle()
                            try? self.moc.save()
                        }) {
                            Label(NSLocalizedString((contact.hideSettled ? "Hide" : "Show") + " Settled", comment: ""), systemImage: contact.hideSettled ? "eye.slash" :"eye")
                        }
                        
                    } label: {
                        Label("Filter", systemImage: "line.horizontal.3.decrease.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
            }
            .sheet(isPresented: $showAddTransaction){
                TransactionsForm(contact: contact)
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
