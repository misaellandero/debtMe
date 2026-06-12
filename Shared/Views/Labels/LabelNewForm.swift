//
//  LabelNewForm.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 27/03/21.
//

import SwiftUI

struct LabelNewForm: View {
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    
    @State var name : String = ""
    @State var colorSelect : Int = 0
    
    @Binding var showForm : Bool
    var serviceLabelMode = false
    var body: some View {
      
            #if os(macOS)
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    LabelMultiplatformForm(name: $name, colorSelect: $colorSelect, showForm: $showForm, save: saveTag, serviceLabelMode: serviceLabelMode)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .navigationTitle("New")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showForm.toggle()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .appSheetCancelButtonStyle()
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveTag) {
                        Label("Add", systemImage: "plus.circle.fill")
                            .appToolbarLabel()
                    }
                    .appSheetPrimaryButtonStyle()
                }
            }
        }
        .macOSFixedSheet(width: 480, height: 320)
            #else
            NavigationView{
                ZStack{
                    List{
                        LabelMultiplatformForm(name: $name, colorSelect: $colorSelect, showForm: $showForm, save: saveTag, serviceLabelMode: serviceLabelMode)
                    }
                    .listStyle(InsetGroupedListStyle())
                    VStack{
                        Spacer()
                        Button(action: saveTag) {
                            Label("Add", systemImage: "plus.circle.fill")
                                .appToolbarLabel()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                        .controlSize(.large)
                        .padding()
                   }
                    
                    
                }
                .toolbar{
                    ToolbarItem(placement: .cancellationAction){
                        Button(action:{
                            showForm.toggle()
                        }){
                            Label("Return", systemImage: "xmark")
                        }
                        .tint(.red)
                    }
                    
                    ToolbarItem(placement: .primaryAction ){
                        ToolbarAddButton(edition: false, action: saveTag)
                    }
                    
                    ToolbarItem(placement:.principal){
                        Label("New", systemImage: "tag.fill")
                    }
                }
            }
            #endif
     
        
    }
    
    func saveTag(){
        let newTag = ContactLabel(context: self.moc)
        newTag.id = UUID()
        newTag.name =  self.name
        newTag.color = Int16(self.colorSelect)
        newTag.labelForService = serviceLabelMode
        
        try? self.moc.save()
        showForm.toggle()
    }
}

 
struct LabelMultiplatformForm: View {
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    
    @Binding var name : String
    @Binding var colorSelect : Int
    @Binding var showForm : Bool
    var save : () -> Void
    var serviceLabelMode = false
    var body: some View {
        
        TextField("Name", text: $name)
        #if os(macOS)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        #endif
       
        if !serviceLabelMode{
        #if os(macOS)
        ScrollView{
            Picker(selection: $colorSelect) {
                ForEach(0..<AppColorsModel.colors.count){ index in
                    Text(AppColorsModel.colors[index].name)
                    .tag(index)
                }
            } label: {
                Image(systemName: "tag.fill")
                    .foregroundStyle(AppColorsModel.colors[colorSelect].color)
            }
             
        }

        #else

        Picker(selection: $colorSelect, label: Label("Color", systemImage: "paintbrush.fill") , content: {
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
        .labelsHidden()
         .pickerStyle(NavigationLinkPickerStyle())
        #endif
        }
      
         
        
    }
}
