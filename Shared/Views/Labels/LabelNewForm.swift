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
    @Binding var showForm : Bool
    var body: some View {
        Group{
            #if os(iOS)
            NavigationView{
                List{
                    LabelForm( showForm: $showForm)
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarItems(
                    leading:
                        Button(action:{
                            showForm.toggle()
                        }){
                            
                            Label("Return", systemImage: "xmark")
                            //Image(systemName: "chevron.left.circle.fill")
                                .foregroundColor(Color.gray)
                                .font(Font.system(.headline, design: .rounded).weight(.black))
                        },
                    trailing:
                        Button(action:{}){
                            Label("Add", systemImage: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(Font.system(.headline, design: .rounded).weight(.black))
                        }
                )
                .toolbar{
                    ToolbarItem(placement:.principal){
                        Text("\(Image(systemName: "tag.fill")) New")
                            .font(Font.system(.title, design: .rounded).weight(.black))
                    }
                }
            }
            #elseif os(macOS)
            List{
                LabelForm( showForm: $showForm)
            }
            #endif
        }
        
    }
}

 
struct LabelForm: View {
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    @State var name : String = ""
    @State var colorSelect : Int = 0
    @Binding var showForm : Bool
    var body: some View {
        TextField("Tag", text: $name)
        Picker(selection: $colorSelect, label: Label("Color", systemImage: "paintbrush.fill") , content: {
            ForEach(0..<AppColorsModel.colors.count){ index in
                HStack{
                    Image(systemName: "paintbrush.pointed.fill")
                    Text(AppColorsModel.colors[index].name)
                }
                .foregroundColor(AppColorsModel.colors[index].color)
                .tag(index)
            }
        })
        .pickerStyle(InlinePickerStyle())
        .labelsHidden()
        
        #if os(iOS)
        Section{
            Button(action: saveTag){
                HStack{
                    Spacer()
                    Label("Add", systemImage: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                        .padding()
                    Spacer()
                }
            }
            .listRowBackground(Color.accentColor )
        }
        #elseif os(macOS)
        Section{
            Button(action: saveTag){
                HStack{
                    Spacer()
                    Label("Add", systemImage: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                        .padding()
                    Spacer()
                }
            }
            .listRowBackground(Color.accentColor )
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
