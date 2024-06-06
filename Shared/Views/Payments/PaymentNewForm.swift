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
    @State var transaction : Transaction?
    var edition = false
    @State var payment: Payment?
    
    var body: some View {
        Group{
           
            #if os(macOS)
                List{
                    Text(edition ? "Edit" : "New")
                    PaymentMultiplatformForm(paymentModel: $paymentModel, savePayment: performSaveAcion, closeView: closeView, edition: edition)
                        .padding()
                }
                .frame(width: 400, height: 500)
            #else
            NavigationView(){
                List{
                    PaymentMultiplatformForm(paymentModel: $paymentModel, savePayment: performSaveAcion, closeView: closeView, edition: edition)
                }
                .navigationTitle(LocalizedStringKey(edition ? "Edit" : "New"))
                .listStyle(InsetGroupedListStyle())
              
                .toolbar {
                    ToolbarItem(placement: .cancellationAction ){
                        Button(action: closeView){
                            Label("Return", systemImage: "xmark")
                        }
                        .tint(.red)
                    }
                    ToolbarItem(placement: .primaryAction ){
                        Button(action: savePayment){
                            Label(edition ? "Save": "Add", systemImage: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            
            #endif
        }
        .onAppear(perform: loadDataForEdit)
        
    }
    
    func closeView(){
        self.presentationMode.wrappedValue.dismiss() 
    }
    
    func performSaveAcion(){
        if edition {
            editPayment()
        } else {
            savePayment()
        }
    }
    
    func loadDataForEdit(){
        if edition {
            if let payment {
                paymentModel.amout = String(payment.amount)
                paymentModel.date = payment.wrappedDateCreation
                paymentModel.note = payment.wrappedNotes
                paymentModel.photo = payment.image
            }
        }
    }
    
    func editPayment(){
        if let payment {
        payment.date = paymentModel.date
        payment.notes = paymentModel.note
        payment.image = paymentModel.photo
        if paymentModel.payAll {
            if payment.transaction!.totalBalance > 0 {
                payment.amount = payment.transaction!.totalBalance
            }
        }
        else
        {
            payment.amount = paymentModel.amountNumber
        }
            
        
        try? self.moc.save()
        closeView()
        }
    }
    
    func savePayment(){
        if let transaction {
            let payment = Payment(context: moc)
            payment.id = UUID()
            payment.date = paymentModel.date
            payment.notes = paymentModel.note
            payment.image = paymentModel.photo
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
    
}


struct PaymentMultiplatformForm: View {
    
    @Binding var paymentModel : PaymentModel
    var savePayment : () -> Void
    var closeView : () -> Void
    var edition = false
    var body: some View {
        Section{
            DatePicker("Date", selection: $paymentModel.date)
                .datePickerStyle(GraphicalDatePickerStyle())
            TextField("Note", text: $paymentModel.note)
                #if os(macOS)
            TextField("Amount", text: $paymentModel.amout)
                .disabled(paymentModel.payAll)
                #else
            TextField("Amount", text: $paymentModel.amout)
                .disabled(paymentModel.payAll)
                .keyboardType(.decimalPad)
                #endif
            if !edition {
                Toggle("Pay Full Settlement", isOn: $paymentModel.payAll.onChange(changePayAll))
               
            }
        }
        
        Section{
            ImagePickerView(photoData: $paymentModel.photo)
        }
                #if os(macOS)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                #endif
                Section{
                   
                    #if os(macOS)
                    HStack{
                        Button(action: closeView){
                            Label("Return", systemImage: "xmark") 
                        }
                        .tint(.red)
                        Spacer()
                        Button(action: savePayment){
                            Label(edition ? "Save": "Add", systemImage: "plus.circle.fill")
                        }
                        .accentColor(.accentColor)
                    }
                    #else
                    Button(action: savePayment){
                        HStack{
                            Spacer()
                            Label(edition ? "Save": "Add", systemImage: "plus.circle.fill")
                                .foregroundColor(.white)
                                .font(Font.system(.headline, design: .rounded).weight(.black))
                                .padding()
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.accentColor )
                    #endif
                }
            
      
         
        
    }
    
    
    func changePayAll(_ tag: Bool){
      
        var payAll = tag
        
        if payAll {
            paymentModel.amout = String(localized: LocalizedStringResource("All"))
        } else {
            paymentModel.amout = "0.0"
        }
            
        
    }
    
    
}
 
