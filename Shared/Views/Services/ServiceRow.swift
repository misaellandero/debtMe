//
//  ServiceRow.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI

struct ServiceRow: View {
    @State var BgColor: Color
    @State var ServiceName: String
    @State var Amount: String
    @State var frequency: String
    @State var limitDate: String
    var body: some View {
        HStack{
            VStack{
                Text(limitDate)
                    .font(.caption)
                Text(ServiceName)
                
                
            }
            Spacer()
            VStack{
                Text(frequency)
                    .font(.caption)
                Text(Amount)
                
            }
            
        }
        .bold()
        .foregroundColor(.white)
        .padding()
        .listRowBackground(BgColor)
         
    }
}

#Preview {
    List{
        Section(header: Text("Credit Cards")){
            ServiceRow(BgColor: .red, ServiceName: "Santader Credit card",Amount: "$2,500",frequency: "Montly",limitDate : "Pay Before 04 mar")
            ServiceRow(BgColor: .blue, ServiceName: "BBVA Credit card",Amount: "$1,500",frequency: "Montly",limitDate : "Pay Before 05 mar")
            ServiceRow(BgColor: .gray, ServiceName: "Amex Credit card",Amount: "$750",frequency: "Montly",limitDate : "Pay Before 15 mar")
        }
        Section(header: Text("Subscriptions")){
            ServiceRow(BgColor: .pink, ServiceName: "Apple music",Amount: "$2,500",frequency: "Montly",limitDate : "Pay Before 04 mar")
            ServiceRow(BgColor: .cyan, ServiceName: "ICloud +",Amount: "$2,500",frequency: "Montly",limitDate : "Pay Before 04 mar")
            ServiceRow(BgColor: .darkBlue, ServiceName: "HBOMAX",Amount: "$1,500",frequency: "Montly",limitDate : "Pay Before 05 mar")
            ServiceRow(BgColor: .orange, ServiceName: "Mercado Pago",Amount: "$750",frequency: "Montly",limitDate : "Pay Before 15 mar")
        }
        Section(header: Text("Services")){
            ServiceRow(BgColor: .blue, ServiceName: "Telmex",Amount: "$2,500",frequency: "Montly",limitDate : "Pay Before 04 mar")
            ServiceRow(BgColor: .greenSea, ServiceName: "CFE",Amount: "$1,500",frequency: "Montly",limitDate : "Pay Before 05 mar")
            ServiceRow(BgColor: .belizeHole, ServiceName: "Agua",Amount: "$750",frequency: "Montly",limitDate : "Pay Before 15 mar")
        }
        
    }
}
