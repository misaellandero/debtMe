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
    var body: some View {
        List{
            
            Section{
                ServiceRow(BgColor: service.wrappedColor, ServiceName: service.wrappedName, Amount: service.amount.toCurrencyString(), frequency: service.frecuencyString, limitDate: service.frequencyDate.formatted(date: .abbreviated, time: .omitted), image: service.image)
                Text(service.wrappedDes)
                    .multilineTextAlignment(.leading)
            }
            Section("History"){
                
            }
        }
        .navigationTitle(service.wrappedName)
        .toolbar{
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

 
