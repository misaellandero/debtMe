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
}

#Preview {
    ServicesForm()
}




// MARK: - Multiplaform Form

struct ServiceMultiPlataformForm : View {
    
    // MARK: - To close the sheet
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var service : ServicesModel
    @Binding var label: ContactLabel?
    var save : () -> Void
    var edition = false
    
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
                        Text(ServicesModel.frequency[index]).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                switch service.frecuencyIndex {
                case 0: //"Daily":
                    Text("Daily Fee")
                case 1, 2: //"Weekly","Biweekly":
                    Text("\(ServicesModel.frequency[service.frecuencyIndex])") + Text(" Fee each ") + Text("\(service.dayName ?? "")")
                    
                case 3, 4, 5: //"Monthly", "Quarterly", "Semester":
                    Text("\(ServicesModel.frequency[service.frecuencyIndex])") + Text(" Fee each ") + Text("\(service.frequencyDay ?? 0)")
                    
                case 6: //"Yearly":
                    Text("\(ServicesModel.frequency[service.frecuencyIndex])") + Text(" Fee each ") + Text("\(service.frequencyDay)") + Text(" of ") + Text("\(service.monthName ?? "")")
                    
                default:
                    Text("Select Frequency")
                }
                
            }
            Section{
#if os(iOS)
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
    }
    var dayName: String? {
        //"Day Name"
        let day = service.frequencyDay
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // "EEEE" gives full name of the day (e.g., Monday)
        return dateFormatter.string(from: DateComponents(day: day).date!)
        
    }
}
