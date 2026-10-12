//
//  ServicesForm.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI
import CoreData

struct ServicesForm: View {
    //Model View de Coredata
    @Environment(\.managedObjectContext) var moc
    //Modal presentation
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @State var edition : Bool = false
    
    //Data if is edition
    @State var service: Services?
    //Data if is new
    @State var serviceModel = ServicesModel()
    @State var serviceLabel: ContactLabel?
    
    var body: some View {
        Group{
        #if os(macOS)
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ServiceMultiPlataformForm(service: $serviceModel, label: $serviceLabel, save: performSaveAcion, edition: edition)
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
            .macOSFixedSheet(width: 560, height: 620)
        #else
            NavigationStack{
                List{
                    ServiceMultiPlataformForm(service: $serviceModel, label: $serviceLabel, save: performSaveAcion, edition: edition)
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle(edition ? "Edit" : "New")
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
                .appSheetBottomConfirmationAction(edition: edition, action: performSaveAcion)
            }
            
#endif
        }
        .onAppear(perform:loadData)
    }
    
    func closeView(){
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func performSaveAcion(){
        if edition {
            editService()
        } else {
            saveService()
        }
    }
    
    func loadData(){
        if edition{
            if let service {
                serviceModel.amout = String(service.amount)
                serviceModel.colorIndex = Int(service.color)
                serviceModel.name = service.wrappedName
                serviceModel.des = service.wrappedDes
                serviceModel.expense = service.expense
                serviceModel.frecuencyIndex = Int(service.frequency)
                serviceModel.frequencyDate = service.frequencyDate
                serviceModel.businessDayAdjustmentIndex = Int(service.business_day_adjustment)
                serviceModel.statusIndex = Int(service.status)
                serviceLabel = service.label
                serviceModel.image = service.image
                if let endDate = service.recurrenceEndDate {
                    serviceModel.hasEndDate = true
                    serviceModel.endDate = endDate
                } else {
                    serviceModel.hasEndDate = false
                }
            }
        }
    }
    
    func editService(){
        if let service {
            service.amount = serviceModel.amountNumber
            service.color = Int16(serviceModel.colorIndex)
            service.name = serviceModel.name
            service.des = serviceModel.des
            service.expense =  serviceModel.expense
            service.frequency = Int16(serviceModel.frecuencyIndex)
            service.frequency_date = serviceModel.frequencyDate
            service.business_day_adjustment = Int16(serviceModel.businessDayAdjustmentIndex)
            service.recurrence_end_date = serviceModel.hasEndDate ? serviceModel.endDate : nil
            service.status = Int16(serviceModel.statusIndex)
            service.label = serviceLabel
            service.image = serviceModel.image
            
            let amountUpdate = AmountUpdate(context: moc)
            amountUpdate.id = UUID()
            amountUpdate.amount = serviceModel.amountNumber
            amountUpdate.updateDate = Date()
            amountUpdate.service = service
            
            try? self.moc.save()
            closeView()
        }
    }
    
    func saveService(){
        let service = Services(context: moc)
        service.id = UUID()
        service.amount = serviceModel.amountNumber
        service.color = Int16(serviceModel.colorIndex)
        service.name = serviceModel.name
        service.des = serviceModel.des
        service.expense =  serviceModel.expense
        service.frequency = Int16(serviceModel.frecuencyIndex)
        service.frequency_date = serviceModel.frequencyDate
        service.business_day_adjustment = Int16(serviceModel.businessDayAdjustmentIndex)
        service.recurrence_end_date = serviceModel.hasEndDate ? serviceModel.endDate : nil
        service.status = Int16(serviceModel.statusIndex)
        service.label = serviceLabel
        service.image = serviceModel.image
        
        let amountUpdate = AmountUpdate(context: moc)
        amountUpdate.id = UUID()
        amountUpdate.amount = serviceModel.amountNumber
        amountUpdate.updateDate = Date()
        amountUpdate.service = service
        try? self.moc.save()
        closeView()
        
    }
}

#Preview {
    NavigationStack{
        ServicesForm()
    }
    
}




// MARK: - Multiplaform Form

struct ServiceMultiPlataformForm : View {
    
    // MARK: - To close the sheet
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var service : ServicesModel
    @Binding var label: ContactLabel?
    var save : () -> Void
    var edition = false
    
    @State var showLabelList = false
    @State var showFormLabel = false
    @State private var amountIsFocused = false
    
    @State var showTagPicker = false
    var body: some View {
        Group {
#if os(macOS)
            macOSForm
#else
            iOSForm
#endif
        }
        .sheet(isPresented: $showFormLabel, content: {
            labelPicker(label: $label, showLabelList: $showLabelList)
        })
    }

#if os(macOS)
    private var macOSForm: some View {
        VStack(spacing: 16) {
            if service.image != nil {
                ServiceIconView(photoData: service.image, backgroundColor: service.color, cornerRadius: 20)
                    .frame(width: 72, height: 72)
                    .shadow(color: service.color.opacity(0.24), radius: 8, x: 0, y: 4)
            }

            AppMacFormSection {
                AppMacFormRow("Name") {
                    TextField("Name", text: $service.name)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.trailing)
                }
                AppMacFormDivider()
                AppMacFormRow("Description") {
                    TextField("Description", text: $service.des)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.trailing)
                }
                AppMacFormDivider()
                AppMacFormRow("Type") {
                    Picker("Type", selection: $service.expense) {
                        Text("Expense").tag(true)
                        Text("Income").tag(false)
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
                AppMacFormDivider()
                AppMacFormRow("Status") {
                    Picker("Status", selection: $service.statusIndex) {
                        ForEach(ServiceLifecycleStatus.allCases) { status in
                            Text(status.localizedTitle).tag(Int(status.rawValue))
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
            }

            AppMacFormSection {
                AppMacFormRow("Payment date") {
                    DatePicker("Payment date", selection: $service.frequencyDate, displayedComponents: .date)
                        .labelsHidden()
                }
                AppMacFormDivider()
                AppMacFormRow("Frequency") {
                    Picker("Frequency", selection: $service.frecuencyIndex) {
                        ForEach(0..<ServicesModel.frequency.count, id: \.self) { index in
                            Text(ServicesModel.frequencyTitle(for: index)).tag(index)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
                AppMacFormDivider()
                Text(feeDescription)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                    .padding(.vertical, 6)
                AppMacFormDivider()
                AppMacFormRow("Business day") {
                    Picker("Business day", selection: $service.businessDayAdjustmentIndex) {
                        ForEach(0..<ServicesModel.businessDayAdjustments.count, id: \.self) { index in
                            Text(ServicesModel.businessDayAdjustmentTitle(for: index)).tag(index)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
                AppMacFormDivider()
                AppMacFormRow("End date") {
                    Toggle("End date", isOn: $service.hasEndDate)
                        .labelsHidden()
                }
                if service.hasEndDate {
                    AppMacFormDivider()
                    AppMacFormRow("End date") {
                        DatePicker("End date", selection: $service.endDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                }
            }

            AppAmountEntryField(amountText: $service.amout, isFocused: $amountIsFocused)

            AppMacFormSection {
                AppMacFormRow("Tag", systemImage: "tag") {
                    Button(label?.wrappedName ?? "Select a tag") {
                        showTagPicker.toggle()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(AppTheme.actionTint)
                    .sheet(isPresented: $showTagPicker, content: {
                        LabelsPickerView(label:$label, serviceLabelMode: true)
                            .frame(width: 250, height: 200)
                    })
                }
                AppMacFormDivider()
                AppMacFormRow("Color", systemImage: "paintbrush.fill") {
                    Picker("Color", selection: $service.colorIndex) {
                        ForEach(0..<AppColorsModel.colors.count, id: \.self){ index in
                            Text(AppColorsModel.colors[index].name)
                                .tag(index)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
                AppMacFormDivider()
                ImagePickerView(photoData: $service.image, iconBackgroundColor: service.color, isIconFormat: true)
                    .padding(.vertical, 8)
            }

            AppMacFormSection {
                ServiceRow(BgColor: service.color, ServiceName: service.name, Amount: service.amountNumber.toCurrencyString(), frequency: ServicesModel.frequency[service.frecuencyIndex], limitDate: service.frequencyDate.formatted(date: .abbreviated, time: .omitted), image: service.image, expense: service.expense)
                    .padding(12)
                    .background(service.color, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
#endif

#if !os(macOS)
    private var iOSForm: some View {
        Group {
            Section{
                TextField("Name", text: $service.name)
                TextField("Description", text: $service.des)
                Picker("Type", selection: $service.expense) {
                    Text("Expense").tag(true)
                    Text("Income").tag(false)
                }
                Picker("Status", selection: $service.statusIndex) {
                    ForEach(ServiceLifecycleStatus.allCases) { status in
                        Text(status.localizedTitle).tag(Int(status.rawValue))
                    }
                }
            }
            Section{
                DatePicker("Payment date", selection: $service.frequencyDate, displayedComponents: .date)

                Picker("Frequency", selection: $service.frecuencyIndex) {
                    ForEach(0..<ServicesModel.frequency.count, id: \.self) { index in
                        Text(ServicesModel.frequencyTitle(for: index)).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Text(feeDescription)

                Picker("Business day", selection: $service.businessDayAdjustmentIndex) {
                    ForEach(0..<ServicesModel.businessDayAdjustments.count, id: \.self) { index in
                        Text(ServicesModel.businessDayAdjustmentTitle(for: index)).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())

            }
            Section {
                Toggle("End date", isOn: $service.hasEndDate)
                if service.hasEndDate {
                    DatePicker("End date", selection: $service.endDate, displayedComponents: .date)
                }
            }
            Section {
                AppAmountEntryField(amountText: $service.amout, isFocused: $amountIsFocused)
            }

            Section {
                NavigationLink(destination: {
                    LabelsPickerView(label:$label, serviceLabelMode: true)
                }, label: {
                    HStack{
                        Label("Tag", systemImage: "tag.fill")
                        Spacer()
                        Text(label?.name ?? "")
                    }
                })

                Picker(selection: $service.colorIndex, label: Label("Color", systemImage: "paintbrush.fill"), content: {
                    ForEach(0..<AppColorsModel.colors.count, id: \.self){ index in
                        HStack{
                            Image(systemName: "circle.fill")
                                .foregroundStyle(AppColorsModel.colors[index].color)

                            Text(AppColorsModel.colors[index].name)
                        }
                        .padding()
                        .tag(index)
                    }
                })
                .pickerStyle(NavigationLinkPickerStyle())

                ImagePickerView(photoData: $service.image, iconBackgroundColor: service.color, isIconFormat: true)
            }

            Section(footer: Text("Preview")){
                ServiceRow(BgColor: service.color, ServiceName: service.name, Amount: service.amountNumber.toCurrencyString(), frequency: ServicesModel.frequency[service.frecuencyIndex], limitDate: service.frequencyDate.formatted(date: .abbreviated, time: .omitted), image: service.image, expense: service.expense)
                    .listRowBackground(service.color)
            }
        }
    }
#endif

    private var feeDescription: String {
        let frequencyTitle = ServicesModel.localizedFrequencyTitle(for: service.frecuencyIndex)

        switch service.frecuencyIndex {
        case 0:
            return String(localized: "Daily Fee")
        case 1:
            return "\(frequencyTitle) \(String(localized: "Fee each")) \(service.dayName ?? "")"
        case 2:
            return "\(frequencyTitle) \(String(localized: "Fee on 15 and last day"))"
        case 3, 4, 5:
            return "\(frequencyTitle) \(String(localized: "Fee each")) \(service.frequencyDay)"
        case 6:
            return "\(frequencyTitle) \(String(localized: "Fee each")) \(service.frequencyDay) \(String(localized: "of")) \(service.monthName ?? "")"
        case 7:
            return "\(frequencyTitle) \(String(localized: "Fee")) \(service.frequencyDate.formatted(date: .abbreviated, time: .omitted))"
        case 8:
            return "\(frequencyTitle) \(String(localized: "Fee"))"
        default:
            return String(localized: "Select Frequency")
        }
    }
 
}
