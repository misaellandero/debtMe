//
//  ServiceDetailView.swift
//  debtMe
//
//  Created by Misael Landero on 16/06/24.
//

import SwiftUI

struct ServiceDetailView: View {
    @ObservedObject var service : Services
    @State var showEdit = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List{
            
            Section{
                ServiceRow(BgColor: service.wrappedColor, ServiceName: service.wrappedName, Amount: service.amount.toCurrencyString(), frequency: service.frecuencyString, limitDate: service.frequencyDate.formatted(date: .abbreviated, time: .omitted), image: service.image, expense: service.expense)
                Text(service.wrappedDes)
                    .multilineTextAlignment(.leading)
            } 
            .listRowBackground(service.wrappedColor)
            Section("History"){
                AmountUpdateList(service: service)
            }
        }
        .navigationTitle(service.wrappedName)
        .toolbar{
            #if os(macOS)
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
            #endif
            ToolbarItem(placement:.primaryAction){
                Button(action:{
                    showEdit.toggle()
                }){
                    Label("Edit", systemImage: "square.and.pencil") .font(Font.system(.headline, design: .rounded).weight(.black))
                        .foregroundColor(.accentColor)
                }
            }
        }
        .sheet(isPresented: $showEdit, content: {
            ServicesForm(edition:true, service: service)
        })
    }
}

 
