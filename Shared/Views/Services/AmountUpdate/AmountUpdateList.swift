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
        #if os(macOS)
        VStack(alignment: .leading, spacing: 12) {
            List {
                Section("History") {
                    if service.amountUpdatesArray.isEmpty {
                        Text("No amount updates")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(service.amountUpdatesArray) { amountUpdate in
                            VStack(alignment: .leading) {
                                Text(service.frequencyDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(.secondary)
                                Text(amountUpdate.amount.toCurrencyString())
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                Text("Update Amount") 
                TextField("Amount", text: $newAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button {
                    addPaymnetUpdate()
                } label: {
                    ButtonLabelAdd()
                }
            }
            .padding()
            .glassEffect()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #else
        Section("History") {
            VStack {
                TextField("Amount", text: $newAmount)
                    .keyboardType(.decimalPad)
                    .focused($amountIsFocuse)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            if amountIsFocuse {
                                Button("Done") {
                                    amountIsFocuse = false
                                }
                            }
                        }
                    }

                Button {
                    addPaymnetUpdate()
                } label: {
                    ButtonLabelAdd()
                }
            }
        }

        ForEach(service.amountUpdatesArray) { amountUpdate in
            VStack(alignment: .leading) {
                Text(service.frequencyDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)
                Text(amountUpdate.amount.toCurrencyString())
            }
        }
        #endif
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
