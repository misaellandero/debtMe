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
    var body: some View {
        Picker(selection: $label, label: Label("Tag", systemImage: "tag.fill")) {
            ForEach(labels, id: \.id){ label in
                HStack{
                    Image(systemName: serviceLabelMode ? "" :  "circle.fill")
                    Text(label.wrappedName)
                }
                .foregroundStyle(serviceLabelMode ? .primary : label.labelColor)
                .tag(label)
            }
        }
        #if os(macOS)
        .datePickerStyle(DefaultDatePickerStyle())
        #else
        .pickerStyle(NavigationLinkPickerStyle())
        #endif
        
        
    }
}

#Preview {
    LabelsPickerView(label: .constant(.none))
}
