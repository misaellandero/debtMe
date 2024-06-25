//
//  ServiceRow.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI

struct ServiceRow: View {
    var BgColor: Color
    var ServiceName: String
    var Amount: String
    var frequency: String
    var limitDate: String
    var image : Data?
    var expense : Bool = true
    var body: some View {
        VStack{
            HStack{
                ImageView(photoData: image, showModalDetail: false, shadowRadius: 0)
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .disabled(true)
                VStack(alignment:.leading){
                    Text(ServiceName)
                    Text("Pay Before ")
                        .font(.caption)
                    Text(limitDate)
                        .font(.caption)
                }
                Spacer()
                VStack(alignment:.trailing){
                    Text(Amount)
                    Text(LocalizedStringKey(frequency))
                        .font(.caption)
                        .multilineTextAlignment(.trailing)
                }
                
            }
            .bold()
            .foregroundColor(.white)
            .listRowBackground(BgColor)
            HStack{
                Spacer()
                Text(expense ? "Expense" : "Income") 
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(4)
                    .font(Font.system(.caption, design: .rounded).weight(.semibold))
                    .background(expense ? .red :  .green)
                    .cornerRadius(10)
            }
        }
        
    }
}

#Preview {
    #if os(macOS) 
    let image =  NSImage(resource: .cromaPig)
    #else
    
    let image =  UIImage(resource: .cromaPig)
    #endif
    let imagedata = image.jpegData(quality: .high)
    return List{
        Section(header: Text("Credit Cards")){
            ServiceRow(BgColor: .red, ServiceName: "Santader Credit card",Amount: "$2,500",frequency: "Montly",limitDate : "04 mar", image: imagedata)
            ServiceRow(BgColor: .blue, ServiceName: "BBVA Credit card",Amount: "$1,500",frequency: "Monthly",limitDate : "05 mar")
            ServiceRow(BgColor: .gray, ServiceName: "Amex Credit card",Amount: "$750",frequency: "Monthly",limitDate : "15 mar")
        }
        Section(header: Text("Subscriptions")){
            ServiceRow(BgColor: .pink, ServiceName: "Apple music",Amount: "$2,500",frequency: "Monthly",limitDate : "04 mar")
            ServiceRow(BgColor: .cyan, ServiceName: "ICloud +",Amount: "$2,500",frequency: "Monthly",limitDate : "04 mar")
            ServiceRow(BgColor: .darkBlue, ServiceName: "HBOMAX",Amount: "$1,500",frequency: "Monthly",limitDate : "05 mar")
            ServiceRow(BgColor: .orange, ServiceName: "Mercado Pago",Amount: "$750",frequency: "Monthly",limitDate : "15 mar")
        }
        Section(header: Text("Services")){
            ServiceRow(BgColor: .blue, ServiceName: "Telmex",Amount: "$2,500",frequency: "Monthly",limitDate : "04 mar")
            ServiceRow(BgColor: .greenSea, ServiceName: "CFE",Amount: "$1,500",frequency: "Monthly",limitDate : "05 mar")
            ServiceRow(BgColor: .belizeHole, ServiceName: "Agua",Amount: "$750",frequency: "Monthly",limitDate : "15 mar")
        }
        
    }
}
