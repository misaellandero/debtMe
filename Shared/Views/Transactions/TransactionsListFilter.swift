//
//  TransactionsListFilter.swift
//  debtMe
//
//  Created by Misael Landero on 28/08/23.
//

import SwiftUI

enum transactionsType {
    case all, debts, loads
}

struct TransactionsListFilter: View {
    
     var isDebt = false
    
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
  
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.dateCreation, ascending: true)]) var transactions: FetchedResults<Transaction>
    

    @State var transactionsArray = [Transaction]()
    
    var body: some View {
        NavigationView{
            List{
                ForEach(transactionsArray, id : \.id){ transaction in
                    TransactionsRow(transaction: transaction)
                }
            }
            #if os(iOS)
            .listStyle(InsetGroupedListStyle())
            #endif
            .navigationTitle(isDebt ? "Debts" : "Loans")
            .onAppear(perform: loadTransactions)
        }
    }
    
    func loadTransactions() {
        var debtTransactions: [Transaction] = []
        var nonDebtTransactions: [Transaction] = []
        
        for transaction in transactions {
            if transaction.debt == isDebt {
                debtTransactions.append(transaction)  // Debts
            } else {
                nonDebtTransactions.append(transaction)  // Non-debts
            }
        }
        
        if isDebt {
            transactionsArray = debtTransactions
        } else {
            transactionsArray = nonDebtTransactions
        }
        
    }
}

 
