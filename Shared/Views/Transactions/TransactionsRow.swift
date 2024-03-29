//
//  TransactionsRow.swift
//  debtMe (iOS)
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct TransactionsRow: View {
    @ObservedObject var transaction : Transaction
    @State var showContactName = false
    var body: some View {
        NavigationLink(destination: PaymentsTransactionsList(transaction: transaction)){

            VStack{
                HStack{
                    if showContactName {
                        Image(systemName: "person.crop.circle.fill")
                        Text(transaction.contactName)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    Image(systemName: "calendar.badge.clock")
                    Text(transaction.transactionCreationDateFormated)
                    if !showContactName {
                        Spacer()
                    }
                    if transaction.settled {
                        Text("Paid in")
                        Image(systemName: "calendar.badge.clock")
                        Text(transaction.transactionSettledDateFormated)
                    }
                }
                .font(.caption)
                .padding(.vertical,1)
                HStack{
                    if transaction.wrappedDes != "No details provided" {
                        Text(transaction.wrappedDes)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(transaction.settled ?  "Already paid" : "Not paid" )
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(4)
                            .font(.caption)
                            .background(transaction.settled ? Color.green : Color.red )
                            .cornerRadius(20)
                    }
                }
                
                HStack{
                    Text(LocalizedStringKey(transaction.debt ? "They Owes me" : "I Owe Them"))
                        .strikethrough(transaction.settled)
                    Spacer()
                    Text(transaction.amount.toCurrencyString())
                        .strikethrough(transaction.settled)
                        .foregroundColor(dolarIconColor)
                    
                }
                
                if transaction.settled {
                    Divider()
                    HStack{
                        Text(LocalizedStringKey("Already paid"))
                        Spacer()
                        Text(transaction.totalPayments.toCurrencyString())
                    }
                } else {
                    TotalsViewRow(amount: transaction.amount, current: .constant(transaction.totalPayments))
                }
                
            }
            .font(Font.system(.body, design: .rounded).weight(.semibold))
            .padding()
        }
    }
    
    var dolarIconColor : Color {
        // They own us and not pay
        if transaction.debt && !transaction.settled {
            return Color.blue
        }
        // They own us and and already pay us
        else if transaction.debt && transaction.settled {
            return Color.green
        }
        // we own they and havent pay
        else if !transaction.debt && !transaction.settled {
            return Color.red
        }
        // we own they and already pay
        else {
            return Color.green
        }
        
    }
}


 
/*
struct TransactionsRow_Previews: PreviewProvider {
    static var previews: some View {
        /*
        // debt not pay
        TransactionsRow(date: "10 Mar 2021", amount: 5, des: "Money for candies", settled: false, dateSettled: "14 Mar 2021", debt: true, contactName: "Misael Landero")
                .previewLayout(.fixed(width: 400, height: 90))
                .preferredColorScheme(.dark)
        // debt  pay
        TransactionsRow(date: "10 Mar 2021", amount: 5, des: "Money for candies", settled: true, dateSettled: "14 Mar 2021", debt: true, contactName: "Misael Landero", showContactName: true)
                .previewLayout(.fixed(width: 400, height: 90))
        
        // loans not pay
        TransactionsRow(date: "10 Mar 2021", amount: 5, des: "Money for candies", settled: false, dateSettled: "14 Mar 2021", debt: false, contactName: "Misael Landero")
                .previewLayout(.fixed(width: 400, height: 90))
                .preferredColorScheme(.dark)
        
        // loans  pay
        TransactionsRow(date: "10 Mar 2021", amount: 5, des: "Money for candies", settled: true, dateSettled: "14 Mar 2021", debt: false, contactName: "Misael Landero")
                .previewLayout(.fixed(width: 400, height: 90))
                .preferredColorScheme(.dark)
        
        // loans  pay
        TransactionsRow(date: "10 Mar 2021", amount: 5, des: "Money for candies", settled: true, dateSettled: "14 Mar 2021", debt: false, contactName: "Misael Landero")
                .previewLayout(.fixed(width: 400, height: 90))*/
    }
}
*/
