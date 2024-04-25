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
    var body: some View {
      
            #if os(macOS)
        VStack{
                Text("\(Image(systemName: "tag.fill")) New")
                LabelMultiplatformForm(name: $name, colorSelect: $colorSelect, showForm: $showForm, save: saveTag)
                   
            }
            .frame(maxHeight: 150)
            .padding()
            #else
            NavigationView{
                ZStack{
                    List{
                        LabelMultiplatformForm(name: $name, colorSelect: $colorSelect, showForm: $showForm, save: saveTag)
                    }
                    .listStyle(InsetGroupedListStyle())
                    VStack{
                        Spacer()
                        Button(action: saveTag){
                            HStack{
                                Spacer()
                                Label( "Add" , systemImage: "plus.circle.fill")
                                    .foregroundColor(.white)
                                    .font(Font.system(.headline, design: .rounded).weight(.black))
                                    .padding()
                                Spacer()
                            }
                            
                            .padding(.vertical, 15)
                        }
                        .background(Color.accentColor)
                        .cornerRadius(10)
                        .padding()
                   }
                    
                    
                }
               /* .navigationBarItems(
                    leading:
                        Button(action:{
                            showForm.toggle()
                        }){
                            LabelSFRounder(label: "Return", systemImage: "xmark", foreground: .gray)
                        },
                    trailing:
                        Button(action:{}){
                            LabelSFRounder(label: "Add", systemImage: "plus.circle.fill", foreground: .accentColor)
                        }
                )*/
                .toolbar{
                    ToolbarItem(placement: .cancellationAction){
                        Button(action:{
                            showForm.toggle()
                        }){
                            Label("Return", systemImage: "xmark")
                        }
                        .tint(.red)
                    }
                    ToolbarItem(placement: .confirmationAction){
                        Button(action: saveTag){
                           Label("Add", image: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    ToolbarItem(placement:.principal){
                        Text("\(Image(systemName: "tag.fill")) New")
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
      
         
        
        #if os(macOS)
        Spacer()
        HStack{
            Button(action: {
                showForm.toggle()
                
            }){
                Label("Cancel", systemImage: "xmark")
                
                .foregroundStyle(.red)
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                    
            }
            Spacer()
            Button(action: save){
                Label("Add", systemImage: "plus.circle.fill")
                    .foregroundStyle(Color.accentColor)
                        .font(Font.system(.headline, design: .rounded).weight(.black))
            }
            
        }
      
        #endif
    }
}
