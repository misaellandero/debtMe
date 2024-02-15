//
//  TransactionsNewForm.swift
//  debtMe (iOS)
//
//  Created by Francisco Misael Landero Ychante on 18/04/21.
//

import SwiftUI

struct TransactionsForm: View {
    //Model View de Coredata
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    
    @State var transactionModel = TransactionModel(amout: "", des: "", notes: "", date: Date(), debt: false)
    
    @State var contact : Contact?
    @State var edition : Bool = false
    @State var transaction: Transaction?
    
    var body: some View {
        Group{
          
            #if os(macOS)
            List{
                Text("\(Image(systemName: "dollarsign.square.fill")) ") +
                Text(edition ? "Edit" : "New")
                TransactionMultiPlataformForm(transactionModel: $transactionModel, saveTransaction:performSaveAcion, closeView: closeView, edition: edition)
                .padding()
            }
            .frame(width: 400, height: 500)
            #else
            NavigationView{
                VStack{
                    List{
                        TransactionMultiPlataformForm(transactionModel: $transactionModel, saveTransaction: performSaveAcion,closeView: closeView, edition: edition)
                        Section{
                            Button(action: performSaveAcion){
                                HStack{
                                    Spacer()
                                    Label(edition ? "Save": "Add" , systemImage: "plus.circle.fill")
                                        .foregroundColor(.white)
                                        .font(Font.system(.headline, design: .rounded).weight(.black))
                                        .padding()
                                    Spacer()
                                }
                            }
                            .listRowBackground(Color.accentColor)
                            .cornerRadius(10)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                  
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction){
                        Button(action:{
                            closeView()
                        }){
                           Label("Return", image: "xmark")
                                .foregroundColor(.red)
                        }
                    }
                    ToolbarItem(placement: .confirmationAction){
                        Button(action: performSaveAcion){
                           Label(edition ? "Save": "Add", image: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    ToolbarItem(placement:.principal){
                        Text("\(Image(systemName: "dollarsign.square.fill")) New")
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
    
    func loadDataForEdit(){
        if edition {
            if let transaction {
                transactionModel.amout = String(transaction.amount)
                transactionModel.des = transaction.wrappedDes
                transactionModel.notes = transaction.wrappedNotes
                transactionModel.date = transaction.wrappedDateCreation
                transactionModel.debt = transaction.debt
            }
        }
    }
    func performSaveAcion(){
        if edition {
            editTransaction()
        } else {
            saveTransaction()
        }
    }
    
    func editTransaction(){
        if let transaction {
            transaction.amount = transactionModel.amountNumber
            transaction.des = transactionModel.des
            transaction.notes = transactionModel.notes
            transaction.dateCreation = transactionModel.date
            transaction.settled = transactionModel.settled
            transaction.debt = transactionModel.debt
            
            try? self.moc.save()
            closeView()
        }
        
    }
    
    func saveTransaction(){
        let newTransaction = Transaction(context: moc)
        newTransaction.id = UUID()
        newTransaction.dateCreation = transactionModel.date
        newTransaction.debt = transactionModel.debt
        newTransaction.des = transactionModel.des
        newTransaction.notes = transactionModel.notes
        newTransaction.amount = transactionModel.amountNumber
        newTransaction.contact = contact
        newTransaction.contact?.sync.toggle()
        try? self.moc.save()
        
        closeView()
        
    }
}

struct TransactionMultiPlataformForm: View {
    
    @Binding var transactionModel : TransactionModel
    var saveTransaction : () -> Void
    var closeView : () -> Void
    var debtOptions = ["They Owes me" , "I Owe Them"]
    var debtValue = [true, false]
    var edition = false
    
    var body: some View {
        
   
            Picker("Type", selection: $transactionModel.debt){
                ForEach(0..<debtOptions.count){ index in
                    Text(LocalizedStringKey(debtOptions[index]))
                        .tag(debtValue[index])
                }
            }.pickerStyle(SegmentedPickerStyle())
        
        
        Section{
            DatePicker("Date", selection: $transactionModel.date)
            #if os(macOS)
                .datePickerStyle(GraphicalDatePickerStyle())
            #else
                .datePickerStyle(CompactDatePickerStyle())
            #endif
        }
        Section{
            TextField("Description", text: $transactionModel.des)
            TextField("Notes", text: $transactionModel.notes)
            #if os(macOS)
            TextField("Amount", text: $transactionModel.amout)
            #else
            TextField("Amount", text: $transactionModel.amout)
                .keyboardType(.decimalPad)
            #endif
        }
        #if os(macOS)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        #endif
        
        
        
        
        Section{
            #if os(macOS)
            HStack{
                Button(action: closeView){
                    Label("Cancel", systemImage: "xmark")
                              
                        
                }
                .accentColor(.red)
                Spacer()
                Button(action: saveTransaction){
                    Label(edition ? "Save": "Add", systemImage: "plus.circle.fill")
                }
                .accentColor(.accentColor)
            }
            #endif
        }
    }
}

 
