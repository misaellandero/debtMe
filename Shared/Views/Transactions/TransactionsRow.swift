//
//  TransactionsRow.swift
//  debtMe (iOS)
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct TransactionsRow: View {
    @State var date : String
    @State var amount : Double
    @State var des : String
    @State var settled : Bool
    @State var dateSettled : String
    @State var debt : Bool
    @State var contactName : String
    @State var showContactName = false
    var body: some View {
        VStack{
            
            HStack{
                if showContactName {
                        Image(systemName: "person.crop.circle.fill")
                        Text(contactName)
                            .fontWeight(.bold)
                        Spacer()
                }
                Image(systemName: "calendar.badge.clock")
                Text(date)
                if !showContactName {
                    Spacer()
                }
                if settled {
                    Text("Paid in")
                    Image(systemName: "calendar.badge.clock")
                    Text(dateSettled)
                }
            }
            .font(.caption)
            .padding(.vertical,1)
            HStack{
                Text(debt ? "They Owes me" : "I Owe")
                    .strikethrough(settled)
                Image(systemName: debt ? "dollarsign.square.fill" :"dollarsign.square")
                    .foregroundColor(dolarIconColor)
                Text("$" + String(format: "%.2f",  amount))
                    .strikethrough(settled)
                Spacer()
                Text(settled ?  "Already paid" : "Not paid" )
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(4)
                    .font(.caption)
                    .background(settled ? Color.green : Color.red )
                    .cornerRadius(20)
            }
            if des != "No details provided" {
                HStack{
                    Text(des)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
           
        }
        .font(Font.system(.body, design: .rounded).weight(.semibold))
        .padding()
    }
    
    var dolarIconColor : Color {
        // They own us and not pay
        if debt && !settled {
            return Color.blue
        }
        // They own us and and already pay us
        else if debt && settled {
            return Color.orange
        }
        // we own they and havent pay
        else if !debt && !settled {
            return Color.red
        }
        // we own they and already pay
        else {
            return Color.green
        }
        
    }
}

struct TransactionsRow_Previews: PreviewProvider {
    static var previews: some View {
        
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
                .previewLayout(.fixed(width: 400, height: 90))
    }
}
