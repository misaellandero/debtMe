//
//  ServicesList.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI

struct ServicesList: View {
  
    @State var showNewBill = false
    
    @FetchRequest(entity: Services.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Services.name, ascending: true)]) var services: FetchedResults<Services>
    
    
    var body: some View {
        List(services){ service in
            ServiceRow(BgColor: service.wrappedColor, ServiceName: service.wrappedName, Amount: service.amount.toCurrencyString(), frequency: service.frecuencyString, limitDate: "")
        }
        .navigationTitle("Bills") 
        .toolbar{
            
            ToolbarItem(placement: .primaryAction ){
                Button(action:{
                    showNewBill.toggle()
                }){
                    Label("Add", systemImage: "plus.circle.fill") .font(Font.system(.headline, design: .rounded).weight(.black))
                        .foregroundColor(.accentColor)
                }
            }
        }
        .sheet(isPresented: $showNewBill, content: {
            ServicesForm()
        })
    }
}

#Preview {
    NavigationStack{
        ServicesList()
    }
}
