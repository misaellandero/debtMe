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
    var useAdaptiveText: Bool = false
    var isPaid: Bool = false
    var body: some View {
        VStack{
            HStack{
                ServiceIconView(photoData: image, backgroundColor: BgColor, cornerRadius: 14)
                    .frame(width: 50, height: 50)
                VStack(alignment:.leading){
                    Text(ServiceName)
                        .strikethrough(isPaid, color: useAdaptiveText ? .secondary : .white.opacity(0.8))
                    Text("Pay Before ")
                        .font(.caption)
                    Text(limitDate)
                        .font(.caption)
                }
                Spacer()
                VStack(alignment:.trailing){
                    Text(Amount)
                        .strikethrough(isPaid, color: useAdaptiveText ? .secondary : .white.opacity(0.8))
                    Text(LocalizedStringKey(frequency))
                        .font(.caption)
                        .multilineTextAlignment(.trailing)
                    if isPaid {
                        Text("Paid")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.white.opacity(useAdaptiveText ? 0.12 : 0.2), in: Capsule())
                    }
                }
                
            }
            .bold()
            .foregroundStyle(useAdaptiveText ? Color.primary : Color.white)
            .opacity(isPaid ? 0.68 : 1)
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
