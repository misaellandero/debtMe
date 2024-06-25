//
//  AmountUpdateList.swift
//  debtMe
//
//  Created by Misael Landero on 17/06/24.
//

import SwiftUI

struct AmountUpdateList: View {
    @ObservedObject var service : Services
    @State var newAmount = ""
    @FocusState private var amountIsFocuse: Bool
    
    //Model View de Coredata
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        
       
        Section{
            VStack{
                #if os(macOS)
                TextField("Amount", text: $newAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                #else
                TextField("Amount", text: $newAmount)
                    .keyboardType(.decimalPad)
                    .focused($amountIsFocuse)
                    .toolbar{
                        ToolbarItemGroup(placement: .keyboard){
                            Spacer()
                            if amountIsFocuse {
                                Button("Done"){
                                    amountIsFocuse = false
                                }
                            }
                        }
                    }
            #endif
                
                Button(action:{
                    addPaymnetUpdate()
                }){
                    ButtonLabelAdd()
                }
                
            }
        }
      
        
        ForEach(service.amountUpdatesArray){ amountUpdate in
            VStack(alignment: .leading, content: {
                Text(service.frequencyDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)
                Text(amountUpdate.amount.toCurrencyString())
            })
        }
    }
    
    func addPaymnetUpdate(){
        
        service.amount = Double(newAmount) ?? 0
        
        let amountUpdate = AmountUpdate(context: moc)
        amountUpdate.id = UUID()
        amountUpdate.amount = Double(newAmount) ?? 0
        amountUpdate.updateDate = Date()
        amountUpdate.service = service
        try? self.moc.save()
        
        newAmount = ""
        
    }
}

