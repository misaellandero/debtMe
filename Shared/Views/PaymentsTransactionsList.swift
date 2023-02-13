//
//  PaymentsListTransactionsView.swift
//  debtMe
//
//  Created by Misael Landero on 12/02/23.
//

import SwiftUI

struct PaymentsTransactionsList: View {
    
    @ObservedObject var transaction : Transaction
    @State var showAddPayment = false
    
    //To hide view
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
      
        ZStack{
            Rectangle()
                .fill(.clear)
            ScrollView(.vertical){
                ForEach(transaction.paymentsArray, id : \.id){ payment in
                    PaymentRow(payment: payment)
                }
                Spacer()
            }
        }
         
        #if os(iOS)
        
        .background(.ultraThinMaterial)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement:.principal){
                Text(transaction.wrappedDes)
                    .font(Font.system(.title, design: .rounded).weight(.black))
            }
        }
        .navigationBarItems(
            leading:
                Button(action:{
                        self.presentationMode.wrappedValue.dismiss()
                }){
                    Label("Return", systemImage: "chevron.backward")
                        .foregroundColor(.gray)
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                },
            
            trailing:
                Button(action:{
                    showAddPayment.toggle()
                }){
                    Label("Add", systemImage: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                }
        )
        .toolbar {
            ToolbarItem(placement:.principal){
                Text("\(Image(systemName: "dollarsign.square")) Summary")
                    .font(Font.system(.title, design: .rounded).weight(.black))
            }
        }
        #elseif os(macOS)
        .padding()
        .toolbar {
            ToolbarItem(placement:.automatic){
                Text(transaction.wrappedDes)
                    .font(Font.system(.title, design: .rounded).weight(.black))
            }
            
            ToolbarItem(placement: .automatic ){
                Label("Add", systemImage: "tray.and.arrow.down.fill")
                    .foregroundColor(.accentColor)
                    .font(Font.system(.title, design: .rounded).weight(.black))
                    .onTapGesture {
                        showAddPayment.toggle()
                    }
            }
        }
        #endif
        
       
        .sheet(isPresented: $showAddPayment){
            PaymentNewForm(transaction: transaction)
        }
       
    }
}

/*
 struct PaymentsTransactionsList_Previews: PreviewProvider {
     static var previews: some View {
         PaymentsTransactionsList()
     }
 }
 */
