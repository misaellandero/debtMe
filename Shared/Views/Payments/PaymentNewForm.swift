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
    

    @State var paymentModel = PaymentModel(amout: "0.0", note: "", date: Date())
    @State var transaction : Transaction
    var body: some View {
        Group{
            #if os(iOS)
            NavigationView(){
                List{
                    PaymentMultiplatformForm(paymentModel: $paymentModel, savePayment: savePayment, closeView: closeView)
                }
                .listStyle(InsetGroupedListStyle())
                .toolbar(){
                    ToolbarItem(placement:.principal){
                        Text("\(Image(systemName: "dollarsign.square.fill")) New")
                            .font(Font.system(.title, design: .rounded).weight(.black))
                    }
                }
                .navigationBarItems(
                    leading:
                        Button(action:{
                            closeView()
                        }){
                            
                            Label("Return", systemImage: "xmark")
                                //Image(systemName: "chevron.left.circle.fill")
                                .foregroundColor(Color.gray)
                                .font(Font.system(.headline, design: .rounded).weight(.black))
                        }
                    ,
                    trailing:
                        Button(action:savePayment){
                            Label("Add", systemImage: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(Font.system(.headline, design: .rounded).weight(.black))
                        }
                )
            }
            #elseif os(macOS)
            List{
                Text("\(Image(systemName: "dollarsign.square.fill")) New")
                    .font(Font.system(.title, design: .rounded).weight(.black))
                PaymentMultiplatformForm(paymentModel: $paymentModel, savePayment: savePayment, closeView: closeView)
                    .padding()
            }
            .frame(width: 300, height: 220)
            
            
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
        payment.amount = paymentModel.amountNumber
        payment.transaction = transaction
        
        try? self.moc.save()
        
        closeView()
        
    }
    
}


struct PaymentMultiplatformForm: View {
    
    @Binding var paymentModel : PaymentModel
    var savePayment : () -> Void
    var closeView : () -> Void
    
    var body: some View {
        DatePicker("Date", selection: $paymentModel.date)
        TextField("Note", text: $paymentModel.note)
        TextField("Amount", text: $paymentModel.amout)
        #if os(iOS)
            .keyboardType(.decimalPad)
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
                             
                            .font(Font.system(.headline, design: .rounded).weight(.black))
                        
                }
                .accentColor(.red)
                Spacer()
                Button(action: savePayment){
                    Label("Add", systemImage: "plus.circle.fill")
                            .font(Font.system(.headline, design: .rounded).weight(.black))
                }
                .accentColor(.accentColor)
            }
            #endif
        }
        
    }
    
}
 
