//
//  BillsList.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI

struct BillsList: View {
  
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
            BillsForm()
        })
    }
}

#Preview {
    NavigationStack{
        BillsList()
    }
}
