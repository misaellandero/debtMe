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
    
    @State var paymentTotal : Double = 0.0
    
    var body: some View {
      
        ZStack{
            Rectangle()
                .fill(.clear)
            VStack{
                ScrollView(.vertical){
                    ForEach(transaction.paymentsArray, id : \.id){ payment in
                        PaymentRow(payment: payment, updateTotal: getTotals)
                    }
                    .onAppear(perform: getTotals)
                    Spacer()
                }
            }
            
            TotalsView(amount: transaction.amount, current: $paymentTotal)
        
        }
         
        #if os(iOS)
        
        .background(.ultraThinMaterial)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement:.principal){
                Text(transaction.wrappedDes)
            }
            ToolbarItem(placement:.principal){
                Text("\(Image(systemName: "dollarsign.square")) Summary")
            }
        }
        .navigationBarItems(
            leading:
                Button(action:{
                        self.presentationMode.wrappedValue.dismiss()
                }){
                    Label("Return", systemImage: "chevron.backward")
                        .foregroundColor(.gray)
                },
            
            trailing:
                Button(action:{
                    showAddPayment.toggle()
                }){
                    Label("Add", systemImage: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                }
        )
        #elseif os(macOS)
        .padding()
        .toolbar {
            ToolbarItem(placement:.automatic){
                Text(transaction.wrappedDes) 
            }
            
            ToolbarItem(placement: .automatic ){
                Label("Add", systemImage: "tray.and.arrow.down.fill")
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        showAddPayment.toggle()
                    }
            }
        }
        #endif
        .sheet(isPresented: $showAddPayment.onChange(modalUpdate)){
            PaymentNewForm(transaction: transaction)
        }
       
    }
    
    
    func modalUpdate(_ tag: Bool){
        getTotals()
    }
    
    func getTotals(){
        var total = 0.0
        for payment in transaction.paymentsArray {
            total += payment.amount
        }
        
        paymentTotal = total
    }
    
   
}
 
