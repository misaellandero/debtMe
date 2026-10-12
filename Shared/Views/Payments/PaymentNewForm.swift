//
//  PaymentNewForm.swift
//  debtMe
//
//  Created by Misael Landero on 12/02/23.
//

import SwiftUI
import CoreData

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
                NavigationStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            PaymentMultiplatformForm(paymentModel: $paymentModel, savePayment: performSaveAcion, closeView: closeView, edition: edition)
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
            NavigationStack {
                List{
                    PaymentMultiplatformForm(paymentModel: $paymentModel, savePayment: performSaveAcion, closeView: closeView, edition: edition)
                }
                .navigationTitle(edition ? "Edit" : "New")
                .listStyle(InsetGroupedListStyle())
                .appSheetBottomConfirmationAction(edition: edition, action: performSaveAcion)
              
                .toolbar {
                    ToolbarItem(placement: .cancellationAction ){
                        Button(action: closeView){
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
                paymentModel.isPlanned = payment.isPlanned
                paymentModel.reminderEnabled = payment.reminderEnabled
            }
        }
    }
    
    func editPayment(){
        if let payment {
        payment.date = paymentModel.date
        payment.notes = paymentModel.note
        payment.image = paymentModel.photo
        payment.planned = paymentModel.isPlanned
        payment.reminderEnabled = paymentModel.reminderEnabled
        if paymentModel.payAll {
            if payment.transaction!.totalBalance > 0 {
                payment.amount = payment.transaction!.totalBalance
            }
        }
        else
        {
            payment.amount = paymentModel.amountNumber
        }
        
        updateNotification(for: payment)
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
            payment.planned = paymentModel.isPlanned
            payment.reminderEnabled = paymentModel.reminderEnabled
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
            updateNotification(for: payment)
            //update balance
            try? self.moc.save()
            
            closeView()
            
        }
    }

    func updateNotification(for payment: Payment) {
        #if os(iOS)
        LocalNotification.cancel(id: payment.notificationId)
        if payment.isPlanned && payment.reminderEnabled {
            let title = NSLocalizedString("Scheduled Payment", comment: "")
            let body = payment.transaction?.wrappedDes ?? NSLocalizedString("Payment reminder", comment: "")
            LocalNotification.schedule(id: payment.notificationId, title: title, body: body, date: payment.wrappedDateCreation, isTimeSensitive: false)
        }
        #endif
    }
    
}


struct PaymentMultiplatformForm: View {
    
    @Binding var paymentModel : PaymentModel
    var savePayment : () -> Void
    var closeView : () -> Void
    var edition = false
    @State private var amountIsFocused = false

    var body: some View {
#if os(macOS)
        VStack(spacing: 16) {
            AppMacFormSection {
                AppMacFormRow("Date", systemImage: "calendar") {
                    DatePicker("Date", selection: $paymentModel.date, displayedComponents: .date)
                        .labelsHidden()
                }
                AppMacFormDivider()
                AppMacFormRow("Note") {
                    TextField("Note", text: $paymentModel.note)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.trailing)
                }
            }

            AppAmountEntryField(amountText: $paymentModel.amout, isFocused: $amountIsFocused)
                .disabled(paymentModel.payAll)

            AppMacFormSection {
                AppMacFormRow("Scheduled payment", systemImage: "calendar.badge.clock") {
                    Toggle("Scheduled payment", isOn: $paymentModel.isPlanned.onChange(changePlanned))
                        .labelsHidden()
                }
                AppMacFormDivider()
                AppMacFormRow("Reminder", systemImage: "bell") {
                    Toggle("Reminder", isOn: $paymentModel.reminderEnabled)
                        .labelsHidden()
                        .disabled(!paymentModel.isPlanned)
                }
                if !edition {
                    AppMacFormDivider()
                    AppMacFormRow("Pay Full Settlement") {
                        Toggle("Pay Full Settlement", isOn: $paymentModel.payAll.onChange(changePayAll))
                            .labelsHidden()
                            .disabled(paymentModel.isPlanned)
                    }
                }
            }

            AppMacFormSection {
                ImagePickerView(photoData: $paymentModel.photo)
                    .padding(.vertical, 8)
            }
        }
#else
        Section {
            DatePicker("Date", selection: $paymentModel.date)
                .datePickerStyle(GraphicalDatePickerStyle())
            TextField("Note", text: $paymentModel.note)
        }

        Section {
            AppAmountEntryField(amountText: $paymentModel.amout, isFocused: $amountIsFocused)
                .disabled(paymentModel.payAll)
        }

        Section {
            Toggle("Scheduled payment", isOn: $paymentModel.isPlanned.onChange(changePlanned))
            Toggle("Reminder", isOn: $paymentModel.reminderEnabled)
                .disabled(!paymentModel.isPlanned)
            if !edition {
                Toggle("Pay Full Settlement", isOn: $paymentModel.payAll.onChange(changePayAll))
                    .disabled(paymentModel.isPlanned)
            }
        }
        
        Section{
            ImagePickerView(photoData: $paymentModel.photo)
        }
#endif
    }
    
    
    func changePayAll(_ tag: Bool){
      
        let payAll = tag
        
        if payAll {
            paymentModel.amout = String(localized: LocalizedStringResource("All"))
        } else {
            paymentModel.amout = "0.0"
        }
            
        
    }

    func changePlanned(_ tag: Bool) {
        if tag {
            paymentModel.payAll = false
        } else {
            paymentModel.reminderEnabled = false
        }
    }
    
    
}
 
