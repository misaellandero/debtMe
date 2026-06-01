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
    
    @State var edition : Bool = false
    
    
    //Data if is edition
    @State var transaction: Transaction?
    //Data if is new
    @State var transactionModel = TransactionModel(amout: "", des: "", notes: "", date: Date(), debt: false)
    
    //To asosiate the transaction
    @State var contact : Contact?
   
   
    var body: some View {
        Group{
          
            #if os(macOS)
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        TransactionMultiPlataformForm(transactionModel: $transactionModel, saveTransaction:performSaveAcion, closeView: closeView, edition: edition)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .navigationTitle(edition ? "Edit" : "New")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: closeView) {
                            Label("Cancel", systemImage: "xmark")
                        }
                        .appSheetCancelButtonStyle()
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: performSaveAcion) {
                            Label(edition ? "Save" : "Add", systemImage: edition ? "checkmark.circle.fill" : "plus.circle.fill")
                                .appToolbarLabel()
                        }
                        .appSheetPrimaryButtonStyle()
                    }
                }
            }
            .macOSFixedSheet(width: 560, height: 640)
            #else
            NavigationView{
                VStack{
                    List{
                        TransactionMultiPlataformForm(transactionModel: $transactionModel, saveTransaction: performSaveAcion,closeView: closeView, edition: edition)
                        Section{
                            Button(action: performSaveAcion) {
                                Label(edition ? "Save" : "Add", systemImage: "plus.circle.fill")
                                    .appToolbarLabel()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                  
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction){
                        Button(action:{
                            closeView()
                        }){
                            Label("Return", systemImage: "xmark")
                        }
                        .tint(.red)
                    }
                   
                    ToolbarItem(placement: .primaryAction ){
                        ToolbarAddButton(edition: edition, action: performSaveAcion)
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
                transactionModel.photo = transaction.image
                if let estimatedDate = transaction.estimatedPaymentDate {
                    transactionModel.hasEstimatedPaymentDate = true
                    transactionModel.estimatedPaymentDate = estimatedDate
                } else {
                    transactionModel.hasEstimatedPaymentDate = false
                }
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
            transaction.image =  transactionModel.photo
            transaction.estimatedPaymentDate = transactionModel.hasEstimatedPaymentDate ? transactionModel.estimatedPaymentDate : nil
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
        newTransaction.image = transactionModel.photo
        newTransaction.estimatedPaymentDate = transactionModel.hasEstimatedPaymentDate ? transactionModel.estimatedPaymentDate : nil
        newTransaction.contact?.sync.toggle()
        try? self.moc.save()
        
        closeView()
        
    }
}

struct TransactionMultiPlataformForm: View {
    
    @Binding var transactionModel : TransactionModel
    var saveTransaction : () -> Void
    var closeView : () -> Void
    var debtOptions = ["They Owe me" , "I Owe Them"]
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
            Toggle("Estimated payment date", isOn: $transactionModel.hasEstimatedPaymentDate)
            if transactionModel.hasEstimatedPaymentDate {
                DatePicker("Estimated payment date", selection: $transactionModel.estimatedPaymentDate)
                    #if os(macOS)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    #else
                    .datePickerStyle(CompactDatePickerStyle())
                    #endif
            }
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
        
        ImagePickerView(photoData: $transactionModel.photo, imagename: transactionModel.des)
        
        
    }
}

 
