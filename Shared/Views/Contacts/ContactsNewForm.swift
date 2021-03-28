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
    
    var body: some View {
        NavigationView{
            Group{
                
                #if os(iOS)
                List{
                    NewContactForm(contact: $contact)
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
                        Button(action:{}){
                            Label("Add", systemImage: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(Font.system(.headline, design: .rounded).weight(.black))
                        }
                )
                #elseif os(macOS)
                List{
                    NewContactForm(contact: $contact)
                }
                #endif
            }
            .font(Font.system(.body, design: .rounded).weight(.semibold))
            .toolbar {
                ToolbarItem(placement:.principal){
                    Text("\(Image(systemName: "person.2.fill")) New")
                        .font(Font.system(.title, design: .rounded).weight(.black))
                }
                /*ToolbarItem(placement: .primaryAction) {
                    Button(action :{showingNewContactForm.toggle()}){
                        Label("New", systemImage: "person.crop.circle.fill.badge.plus")
                    }
                }*/
            }
            //.navigationTitle("New Contact")
        }
        
    }
    
    
}

struct NewContactForm : View {
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    
    @Binding var contact : ContactModel
    // MARK: - Screen Size for determining ipad or iphone screen
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    @State private var showPopover: Bool = false
    @State var animate : Bool = false
    
    @State var labelContact: ContactLabel?
    
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
            }
            
            Section{
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

struct ContactsNewForm_Previews: PreviewProvider {
    static var previews: some View {
        ContactsNewForm(contact: ContactModel(name: "", emoji: "🙂", label: "", labelColor: 2))
    }
}
