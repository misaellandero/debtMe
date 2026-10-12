//
//  TransactionsNewForm.swift
//  debtMe (iOS)
//
//  Created by Francisco Misael Landero Ychante on 18/04/21.
//

import SwiftUI
import CoreData

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
                            Label("Close", systemImage: "xmark")
                        }
                        .appSheetCancelButtonStyle()
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        SheetConfirmationButton(edition: edition, action: performSaveAcion)
                    }
                }
                .appSheetBottomConfirmationAction(edition: edition, action: performSaveAcion)
            }
            .macOSFixedSheet(width: 560, height: 640)
            #else
            NavigationStack{
                List{
                    TransactionMultiPlataformForm(transactionModel: $transactionModel, saveTransaction: performSaveAcion,closeView: closeView, edition: edition)
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle(edition ? "Edit" : "New")
                .appSheetBottomConfirmationAction(edition: edition, action: performSaveAcion)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction){
                        Button(action:{
                            closeView()
                        }){
                            Label("Close", systemImage: "xmark")
                        }
                        .appSheetCancelButtonStyle()
                    }
                   
                    ToolbarItem(placement: .confirmationAction ){
                        SheetConfirmationButton(edition: edition, action: performSaveAcion)
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
    var edition = false
    @State private var amountIsFocused = false
    
    var body: some View {
#if os(macOS)
        VStack(spacing: 16) {
            AppMacFormSection {
                Picker("Type", selection: $transactionModel.debt) {
                    Text("They Owe Me")
                        .tag(true)
                    Text("I Owe Them")
                        .tag(false)
                }
                .pickerStyle(.segmented)
            }

            AppMacFormSection {
                AppMacFormRow("Date", systemImage: "calendar") {
                    DatePicker("Date", selection: $transactionModel.date, displayedComponents: .date)
                        .labelsHidden()
                }
                AppMacFormDivider()
                AppMacFormRow("Estimated payment date") {
                    Toggle("Estimated payment date", isOn: $transactionModel.hasEstimatedPaymentDate)
                        .labelsHidden()
                }
                if transactionModel.hasEstimatedPaymentDate {
                    AppMacFormDivider()
                    AppMacFormRow("Estimated date", systemImage: "calendar.badge.clock") {
                        DatePicker("Estimated date", selection: $transactionModel.estimatedPaymentDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                }
            }

            AppMacFormSection {
                AppMacFormRow("Description") {
                    TextField("Description", text: $transactionModel.des)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.trailing)
                }
                AppMacFormDivider()
                AppMacFormRow("Notes") {
                    TextField("Notes", text: $transactionModel.notes)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.trailing)
                }
            }

            AppAmountEntryField(amountText: $transactionModel.amout, isFocused: $amountIsFocused)

            AppMacFormSection {
                ImagePickerView(photoData: $transactionModel.photo, imagename: transactionModel.des)
                    .padding(.vertical, 8)
            }
        }
#else
            Picker("Type", selection: $transactionModel.debt){
                Text("They Owe Me")
                    .tag(true)
                Text("I Owe Them")
                    .tag(false)
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
        Section {
            TextField("Description", text: $transactionModel.des)
            TextField("Notes", text: $transactionModel.notes)
        }

        Section {
            AppAmountEntryField(amountText: $transactionModel.amout, isFocused: $amountIsFocused)
        }
        
        ImagePickerView(photoData: $transactionModel.photo, imagename: transactionModel.des)
#endif
    }
}

 
