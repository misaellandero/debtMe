//
//  ServicesList.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI

struct ServicesList: View {
  
    @State var showNewBill = false
    
    var body: some View {
        List{
            Text("Bill Row")
        }
        .navigationBarTitle(Text("Bills"))
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
