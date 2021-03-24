//
//  ContactsNewForm.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct ContactsNewForm: View {
    
    @State var contact : ContactModel
    
    var body: some View {
        NavigationView{
            Group{
                
                #if os(iOS)
                List{
                    NewContactForm(contact: $contact)
                }
                .listStyle(InsetGroupedListStyle())
                
                #elseif os(macOS)
                List{
                    NewContactForm(contact: $contact, save: save)
                }
                #endif
            }
            .font(Font.system(.body, design: .rounded).weight(.semibold))
            .navigationTitle("New Contact")
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
    
    var body: some View {
        Group{
            HStack{
                Button(action:showEmojiPicker){
                    Text(contact.emoji)
                        .scaleEffect(animate ? 1.2 : 1)
                        .animation(.easeInOut)
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
            
            HStack{
                
                Button(action:showEmojiPicker){
                    Image(systemName: "circle.fill")
                        .foregroundColor(AppColorsModel.colors[contact.labelColor].color)
                }
                
                TextField("Label", text: $contact.label)
            }
            
            Button(action: saveContact){
                HStack{
                    Spacer()
                    Text("Save")
                    Spacer()
                }
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
    }
}

struct ContactsNewForm_Previews: PreviewProvider {
    static var previews: some View {
        ContactsNewForm(contact: ContactModel(name: "", emoji: "🙂", label: "", labelColor: 2))
    }
}
