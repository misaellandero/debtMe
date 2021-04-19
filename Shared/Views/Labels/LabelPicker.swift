//
//  LabelPicker.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 26/03/21.
//

import SwiftUI


struct labelPicker: View {
    // MARK: - Contacts label from form
    @Binding var label : ContactLabel?
    @Binding var showLabelList : Bool
    @State var showFormLabel = false
    var body: some View{
        Group{
            #if os(iOS)
            List{
                LabelPickerListElements(label: $label, showLabelList: $showLabelList)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarItems(
                leading:
                    Button(action:{
                        showLabelList.toggle()
                    }){
                        
                        Label("Return", systemImage: "xmark")
                        //Image(systemName: "chevron.left.circle.fill")
                            .foregroundColor(Color.gray)
                            .font(Font.system(.headline, design: .rounded).weight(.black))
                    },
                trailing:
                    Button(action:{
                        showFormLabel.toggle()
                    }){
                        Label("Add", systemImage: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(Font.system(.headline, design: .rounded).weight(.black))
                    }
                    .sheet(isPresented: $showFormLabel, content: {
                        LabelNewForm(showForm: $showFormLabel)
                            .environment(\.horizontalSizeClass, .compact)
                    })
            )
            .toolbar{
                
                ToolbarItem(placement:.principal){
                    Text("\(Image(systemName: "tag.fill")) Tags")
                        .font(Font.system(.title, design: .rounded).weight(.black))
                }
            }
            #elseif os(macOS)
            List{
                HStack{
                    Text("\(Image(systemName: "tag.fill")) Tags")
                        .font(Font.system(.title, design: .rounded).weight(.black))
                    Spacer()
                    Button(action:{
                        showFormLabel.toggle()
                    }){
                        Label("Add", systemImage: "plus.circle.fill")
                            .font(Font.system(.headline, design: .rounded).weight(.black))
                    }
                    .accentColor(.accentColor)
                    .sheet(isPresented: $showFormLabel, content: {
                        LabelNewForm(showForm: $showFormLabel)
                            .frame(width: 250, height: 200)
                    })
                }
                Divider()
                LabelPickerListElements(label: $label, showLabelList: $showLabelList)
            }
            #endif
        }
        
        
    }
    
    
}

struct LabelPickerListElements: View {
    // MARK: - Contacts label from form
    @Binding var label : ContactLabel?
    
    // MARK: - Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    // Contacts label list
    @FetchRequest(entity: ContactLabel.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ContactLabel.name, ascending: true)]) var labels: FetchedResults<ContactLabel>
   
    @State private var hovered = false
    @Binding var showLabelList : Bool
    var body: some View {
        
        ForEach(labels, id: \.id){ label in
            #if os(iOS)
            Button(action:{setLabel(label: label)}){
                HStack{
                    Spacer()
                    Text("\(Image(systemName: "tag.fill")) \(label.wrappedName)")
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                    Spacer()
                }
                //.background(label.labelColor)
                .padding()
                .foregroundColor(Color.white)
            }
            .listRowBackground(label.labelColor)
            #elseif os(macOS)
                HStack{
                    Spacer()
                    Text("\(Image(systemName: "tag.fill")) \(label.wrappedName)")
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                        .foregroundColor(.white)
                    Spacer()
                }
                .background(label.labelColor.opacity(0.3))
                .cornerRadius(5)
                .onTapGesture {
                    setLabel(label: label)
                }
                .onHover { isHovered in
                    self.hovered = isHovered
                }
                //.foregroundColor(Color.white)
            
            #endif
        }.onDelete(perform: deleteItem)
        
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
        showLabelList.toggle()
    }
}

 
