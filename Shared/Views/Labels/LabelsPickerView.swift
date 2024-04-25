//
//  LabelsPickerView.swift
//  debtMe
//
//  Created by Misael Landero on 24/04/24.
//

import SwiftUI

struct LabelsPickerView: View {
    
    // MARK: - Contacts label from form
    @Binding var label : ContactLabel?
    
    // MARK: - Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    // Contacts label list
    @FetchRequest(entity: ContactLabel.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ContactLabel.name, ascending: true)]) var labels: FetchedResults<ContactLabel>
    
    var serviceLabelMode = false
    @State var showFormLabel = false
    
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
       
            Group{
                List{
                    ForEach(labels, id: \.id){ label in
                            
                            if serviceLabelMode {
                                if label.labelForService {
                                    HStack{
                                        Image(systemName: serviceLabelMode ? "" :  "circle.fill")
                                        Text(label.wrappedName)
                                    }
                                    .foregroundStyle(serviceLabelMode ? .primary : label.labelColor)
                                    .tag(Optional(label))
                                    .onTapGesture {
                                        setLabel(label: label)
                                    }
                                }
                            } else {
                                if label.labelForService {
                                } else {
                                    HStack{
                                        Image(systemName: serviceLabelMode ? "" :  "circle.fill")
                                        Text(label.wrappedName)
                                    }
                                    .foregroundStyle(serviceLabelMode ? .primary : label.labelColor)
                                    .tag(Optional(label))
                                    .onTapGesture {
                                        setLabel(label: label)
                                    }
                                }
                                
                            }
                            
                        }
                    .onDelete(perform: deleteItem)
                }
               
                      
            }
            .sheet(isPresented: $showFormLabel, content: {
                LabelNewForm(showForm: $showFormLabel)
                .environment(\.horizontalSizeClass, .compact)
            })
            .toolbar{
                ToolbarItem(placement:.principal){
                    Text("\(Image(systemName: "tag.fill")) Tags")
                }
                ToolbarItem(placement: .confirmationAction){
                    Button(action: {
                        showFormLabel.toggle()
                    }){
                       Label("Add", image: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
            }
               
       
           
        
        
    }
    
    func deleteItem(at offsets: IndexSet) {
        
        for offset in offsets {
            let labels =  self.labels[offset]
            self.moc.delete(labels)
        }
         
        try? self.moc.save()
        
       }
    
    func setLabel(label: ContactLabel){
        self.label = label
        presentationMode.wrappedValue.dismiss()
    }
    
}

#Preview {
    NavigationStack{
        List{
            LabelsPickerView(label: .constant(.none))
        }
    }
}
