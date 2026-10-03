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
                VStack(alignment:.leading){
                    Label(transaction.transactionCreationDateFormated, systemImage: "calendar.badge.clock")
                    if transaction.estimatedPaymentDate != nil {
                        Label("Estimated", systemImage: "calendar")
                        Text(transaction.estimatedPaymentDateFormated)
                    }
                    
                    HStack{
                        if transaction.settled {
                            Label("Paid in", systemImage: "calendar.badge.clock")
                            Text(transaction.transactionSettledDateFormated)
                        }
                    }
                }
                .font(.caption)
                
                HStack{
                    directionBadge
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
    
    // Tag that tells at a glance whether the record is money owed to me or money I owe
    var directionBadge: some View {
        Label(
            transaction.debt ? LocalizedStringKey("They Owe me") : LocalizedStringKey("I Owe Them"),
            systemImage: transaction.debt ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
        )
        .strikethrough(transaction.settled)
        .font(Font.system(.subheadline, design: .rounded).weight(.bold))
        .foregroundColor(directionColor)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(directionColor.opacity(0.15))
        .clipShape(Capsule())
    }

    // Blue for money they owe me, orange for money I owe (same scheme as the contacts list)
    var directionColor: Color {
        transaction.debt ? Color.blue : Color.orange
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
            return Color.orange
        }
        // we own they and already pay
        else {
            return Color.green
        }
        
    }
}


 
 
