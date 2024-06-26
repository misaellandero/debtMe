//
//  ServicesForm.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI

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
 

        Text("\(Image(systemName: "chart.bar.doc.horizontal")) ") +
        Text(edition ? "Edit" : "New")
            .font(Font.system(.headline, design: .rounded).weight(.black))
            
            List{
                
                
                ServiceMultiPlataformForm(service: $serviceModel, label: $serviceLabel, save: performSaveAcion, edition: edition)
            }
            .frame(width: 500, height: 500)
            
            HStack{
                Button(action: {
                    dismiss()
                    
                }){
                    Label("Cancel", systemImage: "xmark")
                    
                    .foregroundStyle(.red)
                            .font(Font.system(.headline, design: .rounded).weight(.black))
                        
                }
                Spacer()
                Button(action: {
                    performSaveAcion()
                }){
                    Label(edition ? "Save" : "Add", systemImage: "plus.circle.fill")
                        .foregroundStyle(Color.accentColor)
                            .font(Font.system(.headline, design: .rounded).weight(.black))
                }
                
            }
        #else
            NavigationStack{
                List{
                    ServiceMultiPlataformForm(service: $serviceModel, label: $serviceLabel, save: performSaveAcion, edition: edition)
                }
                .listStyle(InsetGroupedListStyle())
                .toolbar {
                    ToolbarItem(placement: .cancellationAction){
                        Button(action:{
                            closeView()
                        }){
                            Label("Return", systemImage: "xmark")
                        }
                        
                        .tint(.red)
                    }
                    ToolbarItem(placement: .confirmationAction){
                        Button(action: performSaveAcion){
                            Label(edition ? "Save": "Add", systemImage: "plus")
                                .foregroundColor(.accentColor)
                            
                        }
                    }
                    ToolbarItem(placement:.principal){
                        Text("\(Image(systemName: "chart.bar.doc.horizontal")) New")
                    }
                }
            }
            
#endif
        }
        .onAppear(perform:loadData)
        #if os(macOS)
        .padding()
        #endif
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
                serviceLabel = service.label
                serviceModel.image = service.image
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
    @FocusState private var amountIsFocuse: Bool
    
    @State var showTagPicker = false
    var body: some View {
        
            Section{
                TextField("Name", text: $service.name)
                TextField("Description", text: $service.des)
                Picker("Type", selection: $service.expense) {
                    Text("Expense").tag(true)
                    Text("Income").tag(false)
                }
            }
            Section{
                DatePicker("Payment date", selection: $service.frequencyDate, displayedComponents: .date)
                    
                Picker("Frequency", selection: $service.frecuencyIndex) {
                    ForEach(0..<ServicesModel.frequency.count) { index in
                        Text(LocalizedStringKey(ServicesModel.frequency[index])).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                switch service.frecuencyIndex {
                case 0: //"Daily":
                    Text("Daily Fee")
                case 1, 2: //"Weekly","Biweekly":
                    Text(LocalizedStringKey(ServicesModel.frequency[service.frecuencyIndex])) + Text(" Fee each ") + Text("\(service.dayName ?? "")")
                    
                case 3, 4, 5: //"Monthly", "Quarterly", "Semester":
                    Text(LocalizedStringKey(ServicesModel.frequency[service.frecuencyIndex])) + Text(" Fee each ") + Text("\(service.frequencyDay ?? 0)")
                    
                case 6: //"Yearly":
                    Text(LocalizedStringKey(ServicesModel.frequency[service.frecuencyIndex])) + Text(" Fee each ") + Text("\(service.frequencyDay)") + Text(" of ") + Text("\(service.monthName ?? "")")
                    
                default:
                    Text("Select Frequency")
                }
                
            }
            Section{
            #if os(macOS)
            TextField("Amount", text: $service.amout)
            #else
            TextField("Amount", text: $service.amout)
            .keyboardType(.decimalPad)
            .focused($amountIsFocuse)
            .toolbar{
             ToolbarItemGroup(placement: .keyboard){
                  Spacer()
                 if amountIsFocuse {
                     Button("Done"){
                        amountIsFocuse = false
                      }
                 }
               }
           }
            #endif
            }
            
            Section {
                
                #if os(macOS)
                Button( label != nil ? (label?.wrappedName ?? "Select a tag") : "Select a tag", systemImage: "tag", action: {
                    showTagPicker.toggle()
                })
                    .sheet(isPresented: $showTagPicker, content: {
                        LabelsPickerView(label:$label, serviceLabelMode: true)
                            .frame(width: 250, height: 200)
                    })
                #else
                NavigationLink(destination: {
                    LabelsPickerView(label:$label, serviceLabelMode: true)
                }, label: {
                    HStack{
                        Label("Tag", systemImage: "tag.fill")
                        Spacer()
                        Text(label?.name ?? "")
                    }
                })
                #endif
              
                
                
                Picker(selection: $service.colorIndex, label: Label("Color", systemImage: "paintbrush.fill"), content: {
                    ForEach(0..<AppColorsModel.colors.count){ index in
                        HStack{
                            #if os(iOS)
                            Image(systemName: "circle.fill")
                                .foregroundColor(AppColorsModel.colors[index].color)
                            
                            Text(AppColorsModel.colors[index].name)
                            #elseif os(macOS)
                            Text(AppColorsModel.colors[index].name)       #endif
                        }
                        .padding()
                        .tag(index)
                    }
                })
                #if os(iOS)
                .pickerStyle(NavigationLinkPickerStyle())
                #else
                .pickerStyle(MenuPickerStyle())
                #endif
                
                ImagePickerView(photoData: $service.image)
            }
            
            
            Section(footer: Text("Preview")){
                ServiceRow(BgColor: service.color, ServiceName: service.name, Amount: service.amountNumber.toCurrencyString(), frequency: ServicesModel.frequency[service.frecuencyIndex], limitDate: service.frequencyDate.formatted(date: .abbreviated, time: .omitted), image: service.image, expense: service.expense)
                    .listRowBackground(service.color)
                
                    
            }
            
            Section{
#if os(iOS)
                Button(action: save){
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
        
       
        .sheet(isPresented: $showFormLabel, content: {
            labelPicker(label: $label, showLabelList: $showLabelList)
        })
    }
 
}
