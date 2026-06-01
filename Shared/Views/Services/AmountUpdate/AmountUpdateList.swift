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
        Section("History") {
            ForEach(service.amountUpdatesArray) { amountUpdate in
                VStack(alignment: .leading) {
                    Text(service.frequencyDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.secondary)
                    Text(amountUpdate.amount.toCurrencyString())
                }
            }

            Divider()

            VStack(spacing: 12) {
                TextField("Amount", text: $newAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button {
                    addPaymnetUpdate()
                } label: {
                    ButtonLabelAdd()
                }
            }
            .padding(.vertical, 6)
        }
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
