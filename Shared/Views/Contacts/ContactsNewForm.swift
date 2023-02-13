//
//  ContactsNewForm.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct ContactsNewForm: View {
    
    @State var contact : ContactModel
    
    @Environment(\.presentationMode) var presentationMode
    
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    
    @State var labelContact: ContactLabel?
    
    var body: some View {
       
            Group{
                
                #if os(iOS)
                NavigationView{
                List{
                    NewContactMultiplatformForm(contact: $contact, labelContact: $labelContact, saveContact: saveContact)
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarItems(
                    leading:
                        Button(action:{
                            self.presentationMode.wrappedValue.dismiss()
                        }){
                            
                            Label("Return", systemImage: "xmark")
                            //Image(systemName: "chevron.left.circle.fill")
                                .foregroundColor(Color.gray)
                                .font(Font.system(.headline, design: .rounded).weight(.black))
                        },
                    trailing:
                        Button(action:saveContact){
                            Label("Add", systemImage: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(Font.system(.headline, design: .rounded).weight(.black))
                        }
                )
                .toolbar {
                    ToolbarItem(placement:.principal){
                        Text("\(Image(systemName: "person.2.fill")) New")
                            .font(Font.system(.title, design: .rounded).weight(.black))
                    }
                }
                }
                #elseif os(macOS)
                List{
                    Text("\(Image(systemName: "person.2.fill")) New")
                        .font(Font.system(.title, design: .rounded).weight(.black))
                    NewContactMultiplatformForm(contact: $contact, labelContact: $labelContact, saveContact: saveContact)
                }
                .frame(width: 300, height: 170)
                #endif
            }
            .font(Font.system(.body, design: .rounded).weight(.semibold))
            //.navigationTitle("New Contact")
       
        
    }
    
    func saveContact(){
        let newContact = Contact(context: self.moc)
        newContact.id = UUID()
        newContact.name =  contact.name
        newContact.emoji = contact.emoji
        newContact.label = self.labelContact
        
        try? self.moc.save()
        self.presentationMode.wrappedValue.dismiss()
    }
    
    
}

struct NewContactMultiplatformForm : View {
    
    @Binding var contact : ContactModel
    // MARK: - Screen Size for determining ipad or iphone screen
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    @State private var showPopover: Bool = false
    @State var animate : Bool = false
    
    @Binding var labelContact: ContactLabel?
    var saveContact : () -> Void
    
    // MARK: - To close the sheet
    @Environment(\.presentationMode) var presentationMode
    
    @State var showLabelList = false
    var body: some View {
        Group{
            HStack{
                Button(action:showEmojiPicker){
                    Text(contact.emoji)
                        .padding(5)
                        .scaleEffect(animate ? 1.2 : 1)
                        .animation(.easeInOut)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(10)
                }
                .popover(
                    isPresented: self.$showPopover,
                    arrowEdge: .top
                ) {
                    #if os(iOS)
                    if horizontalSizeClass == .compact {
                        EmojiSelecter(emoji: $contact.emoji.onChange(showChange))
                    } else {
                        EmojiPicker(emoji: $contact.emoji.onChange(showChange))
                    }
                    #elseif os(macOS)
                    EmojiPicker(emoji: $contact.emoji.onChange(showChange))
                    #endif  
                }
                
                TextField("Name", text: $contact.name)
            }
            .buttonStyle(BorderlessButtonStyle())
            
            HStack{
                
                Text("Select a tag")
                Spacer()
                #if os(iOS)
                Button(action:{
                    showLabelList.toggle()
                }){
                    Group{
                       Text(labelContact?.wrappedName ?? "Nothing selected")
                    }
                    .font(Font.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundColor(.white)
                    .padding(4)
                    .padding(.horizontal,4)
                    .background(labelContact?.labelColor ?? Color.gray)
                    .cornerRadius(10)
                }
                .sheet(isPresented: $showLabelList){
                   
                    NavigationView{
                        labelPicker(label: $labelContact, showLabelList: $showLabelList)
                    }
                    .environment(\.horizontalSizeClass, .compact)
                  
                }
                #elseif os(macOS)
                Button(action:{
                    showLabelList.toggle()
                }){
                    Group{
                       Text(labelContact?.wrappedName ?? "Nothing selected")
                    }
                    .font(Font.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundColor(labelContact?.labelColor ?? Color.gray)
                }
                .popover(isPresented: $showLabelList){
                    labelPicker(label: $labelContact, showLabelList: $showLabelList)
                        .frame(width: 250, height: 200)
                }
                
                #endif
            }
              
            Section{
                #if os(iOS)
                Button(action: saveContact){
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
                    Button(action: saveContact){
                        Label("Add", systemImage: "plus.circle.fill")
                                .font(Font.system(.headline, design: .rounded).weight(.black))
                    }
                    .accentColor(.accentColor)
                }
                #endif
            }
            
            
        }
    }
    
    func showChange(_ tag: String){
        self.animate = true
        #if os(iOS)
        showEmojiPicker()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.animate = false
        }
        #elseif os(macOS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.animate = false
        }
        #endif
        
    }
    
    func showEmojiPicker(){
        withAnimation{
            self.showPopover.toggle()
        }
    }
    
    
}

struct ContactsNewForm_Previews: PreviewProvider {
    static var previews: some View {
        ContactsNewForm(contact: ContactModel(name: "", emoji: "🙂", label: "", labelColor: 2))
    }
}
