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
    
    @State var edition : Bool = false
    
    //Data if is edition
    @State var service: Services?
    //Data if is new
    @State var serviceModel = ServicesModel()
    @State var labelContact: ContactLabel?
    
    var body: some View {
        Group{
        #if os(macOS)
            List{
                Text("\(Image(systemName: "chart.bar.doc.horizontal")) ") +
                Text(edition ? "Edit" : "New")
                ServiceMultiPlataformForm(service: $serviceModel, label: $labelContact, save: {})
            }
            
        #else
            NavigationStack{
                List{
                    ServiceMultiPlataformForm(service: $serviceModel, label: $labelContact, save: {})
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
    }
    
    func closeView(){
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func performSaveAcion(){
        if edition {
            //editTransaction()
        } else {
            //saveTransaction()
        }
    }
    
    func saveService(){
        let service = Services(context: moc)
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
    
    var body: some View {
        Group{
            Section{
                TextField("Service Name", text: $service.name)
                TextField("Description", text: $service.des)
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
            #endif
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
                    ForEach(0..<AppColorsModel.colors.count){ index in
                        HStack{
                            Image(systemName: "circle.fill")
                                .foregroundColor(AppColorsModel.colors[index].color)
                            Text(AppColorsModel.colors[index].name)
                        }
                        .padding()
                        .tag(index)
                    }
                })
                .pickerStyle(NavigationLinkPickerStyle())
            }
            
            
            Section(footer: Text("Preview")){
                ServiceRow(BgColor: service.color, ServiceName: service.name, Amount: service.amountNumber.toCurrencyString(), frequency: ServicesModel.frequency[service.frecuencyIndex], limitDate: service.frequencyDate.formatted(date: .abbreviated, time: .omitted))
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
#elseif os(macOS)
                HStack{
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        
                    }){
                        Label("Cancel", systemImage: "xmark")
                        
                            .font(Font.system(.headline, design: .rounded).weight(.black))
                        
                    }
                    .accentColor(.red)
                    Spacer()
                    Button(action: save){
                        Label("Add", systemImage: "plus.circle.fill")
                            .font(Font.system(.headline, design: .rounded).weight(.black))
                    }
                    .accentColor(.accentColor)
                }
#endif
            }
        }
        .sheet(isPresented: $showFormLabel, content: {
            labelPicker(label: $label, showLabelList: $showLabelList)
        })
    }
 
}
