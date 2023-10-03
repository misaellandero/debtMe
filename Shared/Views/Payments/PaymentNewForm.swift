//
//  PaymentNewForm.swift
//  debtMe
//
//  Created by Misael Landero on 12/02/23.
//

import SwiftUI

struct PaymentNewForm: View {
    //Model View de Coredata
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    

    @State var paymentModel = PaymentModel(amout: "", note: "", date: Date())
    @State var transaction : Transaction
    var body: some View {
        Group{
            #if os(iOS)
            NavigationView(){
                List{
                    PaymentMultiplatformForm(paymentModel: $paymentModel, savePayment: savePayment, closeView: closeView)
                }
                .navigationTitle(Text("\(Image(systemName: "dollarsign.square.fill")) New"))
                .listStyle(InsetGroupedListStyle())
                .navigationBarItems(
                    leading:
                        Button(action:{
                            closeView()
                        }){
                            
                            Label("Return", systemImage: "xmark")
                                .foregroundColor(Color.gray)
                        }
                    ,
                    trailing:
                        Button(action:savePayment){
                            Label("Add", systemImage: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                )
            }
            #elseif os(macOS)
                List{
                    Text("New") 
                    PaymentMultiplatformForm(paymentModel: $paymentModel, savePayment: savePayment, closeView: closeView)
                        .padding()
                }
                .frame(width: 400, height: 500)
            
            #endif
        }
        
    }
    
    func closeView(){
        self.presentationMode.wrappedValue.dismiss()
    }
     
    
    func savePayment(){
        let payment = Payment(context: moc)
        payment.id = UUID()
        payment.date = paymentModel.date
        payment.notes = paymentModel.note
        if paymentModel.payAll {
            if transaction.totalBalance > 0 {
                payment.amount = transaction.totalBalance
            }
        }
        else
        {
            payment.amount = paymentModel.amountNumber
        }
        
        payment.transaction = transaction
        
        //update balance
        try? self.moc.save()
        
        closeView()
        
    }
    
}


struct PaymentMultiplatformForm: View {
    
    @Binding var paymentModel : PaymentModel
    var savePayment : () -> Void
    var closeView : () -> Void
    
    var body: some View {
        Section{
            DatePicker("Date", selection: $paymentModel.date)
                .datePickerStyle(GraphicalDatePickerStyle())
            TextField("Note", text: $paymentModel.note)
            TextField("Amount", text: $paymentModel.amout)
                .disabled(paymentModel.payAll)
            Toggle("Pay Full Settlement", isOn: $paymentModel.payAll.onChange(changePayAll))
            #if os(iOS)
            .keyboardType(.decimalPad)
            #endif
        }
                #if os(macOS)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                #endif
                Section{
                    #if os(iOS)
                    Button(action: savePayment){
                        HStack{
                            Spacer()
                            Label("Add", systemImage: "plus.circle.fill")
                                .foregroundColor(.white)
                                .font(Font.system(.headline, design: .rounded).weight(.black))
                                .padding()
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.accentColor )
                    #elseif os(macOS)
                    HStack{
                        Button(action: closeView){
                            Label("Cancel", systemImage: "xmark")
                        }
                        .accentColor(.red)
                        Spacer()
                        Button(action: savePayment){
                            Label("Add", systemImage: "plus.circle.fill")
                        }
                        .accentColor(.accentColor)
                    }
                    #endif
                }
            
      
         
        
    }
    
    
    func changePayAll(_ tag: Bool){
      
        var payAll = tag
        
        if payAll {
            paymentModel.amout = "All"
        } else {
            paymentModel.amout = "0.0"
        }
            
        
    }
    
    
}
 
