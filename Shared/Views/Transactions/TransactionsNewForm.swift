//
//  TransactionsNewForm.swift
//  debtMe (iOS)
//
//  Created by Francisco Misael Landero Ychante on 18/04/21.
//

import SwiftUI

struct TransactionsNewForm: View {
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @State var transactionModel = TransactionModel(amout: "0.0", des: "", date: Date(), debt: false)
    @State var contact : Contact
    var body: some View {
        Group{
            #if os(iOS)
            NavigationView{
                List{
                    NewTransactionForm(transactionModel: $transactionModel, saveTransaction: {
                        saveTransaction()
                    })
                }
                .listStyle(InsetGroupedListStyle())
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
                        Button(action:{
                        }){
                            Label("Add", systemImage: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(Font.system(.headline, design: .rounded).weight(.black))
                        }
                )
                .toolbar {
                    ToolbarItem(placement:.principal){
                        Text("\(Image(systemName: "dollarsign.square.fill")) New")
                            .font(Font.system(.title, design: .rounded).weight(.black))
                    }
                    /*ToolbarItem(placement: .primaryAction) {
                     Button(action :{showingNewContactForm.toggle()}){
                     Label("New", systemImage: "person.crop.circle.fill.badge.plus")
                     }
                     }*/
                }
            }
            #elseif os(macOS)
            Text("more to come")
            #endif
        }
    }
    
    
    func closeView(){
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func saveTransaction(){
        let newTransaction = Transaction(context: moc)
        newTransaction.id = UUID()
        newTransaction.dateCreation = transactionModel.date
        newTransaction.debt = transactionModel.debt
        newTransaction.des = transactionModel.des
        newTransaction.amount = transactionModel.amountNumber
        newTransaction.contact = contact
        
        try? self.moc.save()
        
        closeView()
        
    }
}

struct NewTransactionForm: View {
    @Binding var transactionModel : TransactionModel
    var saveTransaction : () -> Void
    var debtOptions = ["They Owes me" , "I Owe They"]
    var debtValue = [true, false]
    var body: some View {
        
        DatePicker("Date", selection: $transactionModel.date)
        TextField("Description", text: $transactionModel.des)
        TextField("Amount", text: $transactionModel.amout)
            .keyboardType(.decimalPad)
        
        Picker("Type", selection: $transactionModel.debt){
            ForEach(0..<debtOptions.count){ index in
                Text(debtOptions[index])
                    .tag(debtValue[index])
            }
        }.pickerStyle(SegmentedPickerStyle())
        
        Section{
            #if os(iOS)
            Button(action: saveTransaction){
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
                Button(action: {
                        //self.presentationMode.wrappedValue.dismiss()
                }){
                    Label("Cancel", systemImage: "xmark")
                             
                            .font(Font.system(.headline, design: .rounded).weight(.black))
                        
                }
                .accentColor(.red)
                Spacer()
                Button(action: saveTransaction){
                    Label("Add", systemImage: "plus.circle.fill")
                            .font(Font.system(.headline, design: .rounded).weight(.black))
                }
                .accentColor(.accentColor)
            }
            #endif
        }
    }
}

 
