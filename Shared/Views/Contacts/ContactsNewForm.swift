//
//  ContactsNewForm.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI
import CoreData

#if canImport(ImagePlayground)
import ImagePlayground
#endif

struct ContactsNewForm: View {
    
    @State var contact = ContactModel(name: "", emoji: "🙂", label: "", labelColor: 1)
    
    @Environment(\.presentationMode) var presentationMode
    
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    
    @State var labelContact: ContactLabel?
    
    var edition = false
    
    @State var contactToEdit : Contact?
    
    var body: some View {
            Group{
                #if os(macOS)
                NavigationStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            NewContactMultiplatformForm(contact: $contact, labelContact: $labelContact, saveContact: performSaveAcion)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .navigationTitle(edition ? "Edit Contact" : "New Contact")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Label("Close", systemImage: "xmark")
                            }
                            .appSheetCancelButtonStyle()
                        }

                        ToolbarItem(placement: .confirmationAction) {
                            SheetConfirmationButton(edition: edition, action: performSaveAcion)
                        }
                    }
                    .appSheetBottomConfirmationAction(edition: edition, action: performSaveAcion)
                }
                .macOSFixedSheet(width: 520, height: 360)
                #else
                NavigationStack{
                    List{
                        NewContactMultiplatformForm(contact: $contact, labelContact: $labelContact, saveContact: performSaveAcion, edition: edition)
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle(edition ? "Edit Contact" : "New Contact")
                    .appSheetBottomConfirmationAction(edition: edition, action: performSaveAcion)
                .toolbar{
                    ToolbarItem(placement: .cancellationAction){
                        Button(action:{
                            self.presentationMode.wrappedValue.dismiss()
                        }){
                            Label("Close", systemImage: "xmark")
                        }
                        .appSheetCancelButtonStyle()
                    }
                     
                    ToolbarItem(placement: .confirmationAction ){
                        SheetConfirmationButton(edition: edition, action: performSaveAcion)
                    }
                }
                }
                #endif
            }
            .onAppear(perform: loadDataForEdit)
       
        
    }
    
    func loadDataForEdit(){
        if edition {
            if let contactToEdit {
                contact.emoji = contactToEdit.wrappedEmoji
                contact.avatarImage = contactToEdit.avatarImage
                contact.name = contactToEdit.wrappedName
                labelContact = contactToEdit.label
            }
        }
    }
    
    func editContact(){
        if let contactToEdit {
            contactToEdit.name =  contact.name
            contactToEdit.emoji = contact.emoji
            contactToEdit.avatarImage = contact.avatarImage
            contactToEdit.label = self.labelContact
            try? self.moc.save()
            self.presentationMode.wrappedValue.dismiss()
        }
        
    }
    
    func performSaveAcion(){
        if edition {
            editContact()
        } else {
            saveContact()
        }
    }
    
    func saveContact(){
        let newContact = Contact(context: self.moc)
        newContact.id = UUID()
        newContact.name =  contact.name
        newContact.emoji = contact.emoji
        newContact.avatarImage = contact.avatarImage
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
    @State private var showImagePlayground = false
    
    @Binding var labelContact: ContactLabel?
    var saveContact : () -> Void
    
    // MARK: - To close the sheet
    @Environment(\.presentationMode) var presentationMode
    
    @State var showLabelList = false
    
    // Contacts label list
    @FetchRequest(entity: ContactLabel.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ContactLabel.name, ascending: true)]) var labels: FetchedResults<ContactLabel>
    
    var edition = false
    
    @State var showFormLabel = false
    
    var body: some View {
        Group {
#if os(macOS)
            VStack(spacing: 16) {
                contactAvatarMenu(size: 64, cornerRadius: 18)
                    .buttonStyle(.plain)

                AppMacFormSection {
                    AppMacFormRow("Name") {
                        TextField("Name", text: $contact.name)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.trailing)
                    }
                    AppMacFormDivider()
                    AppMacFormRow("Tag", systemImage: "tag.fill") {
                        HStack(spacing: 8) {
                            Picker(selection: $labelContact) {
                                Text("Select a tag")
                                    .tag(Optional<ContactLabel>.none)
                                ForEach(labels, id: \.id) { label in
                                    Text(label.wrappedName)
                                        .tag(Optional(label))
                                }
                            } label: {
                                Text(labelContact?.wrappedName ?? "Select a tag")
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .foregroundStyle(labelContact?.labelColor ?? AppTheme.actionTint)

                            Button {
                                showFormLabel.toggle()
                            } label: {
                                Label("New", systemImage: "plus")
                            }
                            .appGlassControlButtonStyle()
                        }
                    }
                }
            }
#else
            HStack {
                contactAvatarMenu(size: 46, cornerRadius: 12)
                TextField("Name", text: $contact.name)
            }
            .buttonStyle(BorderlessButtonStyle())

            HStack {
                Button(action:{
                    showLabelList.toggle()
                }){
                    Group{
                       Text(LocalizedStringKey(labelContact?.wrappedName ?? "Nothing selected"))
                    }
                    .font(Font.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(4)
                    .padding(.horizontal,4)
                    .background(labelContact?.labelColor ?? Color.gray)
                    .cornerRadius(10)
                }
                .sheet(isPresented: $showLabelList){
                    NavigationStack{
                        labelPicker(label: $labelContact, showLabelList: $showLabelList)
                    }
                    .environment(\.horizontalSizeClass, .compact)
                }
            }
#endif
        }
        .sheet(isPresented: $showFormLabel, content: {
            LabelNewForm(showForm: $showFormLabel)
                .environment(\.horizontalSizeClass, .compact)
        })
    }

    private func contactAvatarMenu(size: CGFloat, cornerRadius: CGFloat) -> some View {
        Menu {
            Button {
                showEmojiPicker()
            } label: {
                Label("Emoji Picker", systemImage: "face.smiling")
            }

            #if canImport(ImagePlayground)
            Button {
                showImagePlayground = true
            } label: {
                Label("Create with Apple Intelligence", systemImage: "sparkles")
            }
            #endif

            if contact.avatarImage != nil {
                Button(role: .destructive) {
                    contact.avatarImage = nil
                } label: {
                    Label("Remove Generated Image", systemImage: "trash")
                }
            }
        } label: {
            ContactAvatarView(
                imageData: contact.avatarImage,
                emoji: contact.emoji,
                size: size,
                cornerRadius: cornerRadius
            )
            .scaleEffect(animate ? 1.12 : 1)
            .animation(.easeInOut, value: animate)
        }
        .menuStyle(.button)
        .popover(
            isPresented: self.$showPopover,
            arrowEdge: .top
        ) {
            #if os(macOS)
            EmojiPicker(emoji: $contact.emoji.onChange(showChange))
            #elseif os(visionOS)
            EmojiPicker(emoji: $contact.emoji.onChange(showChange))
            #else
            if horizontalSizeClass == .compact {
                EmojiSelecter(emoji: $contact.emoji.onChange(showChange))
            } else {
                EmojiPicker(emoji: $contact.emoji.onChange(showChange))
            }
            #endif
        }
        #if canImport(ImagePlayground)
        .imagePlaygroundSheet(
            isPresented: $showImagePlayground,
            concept: imagePlaygroundConcept,
            sourceImage: nil,
            onCompletion: { url in
                loadGeneratedContactImage(from: url)
            },
            onCancellation: nil
        )
        #endif
    }
    
    
    func showChange(_ tag: String){
        self.animate = true
        contact.avatarImage = nil
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

    private var imagePlaygroundConcept: String {
        let trimmedName = contact.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            return "friendly contact emoji avatar"
        }
        return "\(trimmedName) friendly contact emoji avatar"
    }

    private func loadGeneratedContactImage(from url: URL) {
        guard let data = try? Data(contentsOf: url) else { return }
        contact.avatarImage = data
        animate = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            animate = false
        }
    }
    
    
}

struct ContactsNewForm_Previews: PreviewProvider {
    static var previews: some View {
        ContactsNewForm(contact: ContactModel(name: "", emoji: "🙂", label: "", labelColor: 2))
  
    }
}
