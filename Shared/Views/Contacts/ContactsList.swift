//
//  ContactsList.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI
import CoreData

struct ContactsList: View {
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    @State private var showingNewContactForm = false
  
    @FetchRequest(entity: Contact.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Contact.name, ascending: true)]) var contacts: FetchedResults<Contact>
    
    var body: some View {
        List{
            ForEach(contacts, id: \.id){ contact in
                ContactsRow(contact: contact)
            }
            
        }
        //.navigationTitle("Contacts")
        .toolbar {
            ToolbarItem(placement:.navigation){
                Text("Contacts")
                    .font(Font.system(.largeTitle, design: .rounded).weight(.black))
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action :{showingNewContactForm.toggle()}){
                    Label("New", systemImage: "person.crop.circle.fill.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showingNewContactForm){
            ContactsNewForm(contact: ContactModel(name: "", emoji: "🙂", label: "", labelColor: 1))
        }
    }
    
    
    
}

struct ContactsList_Previews: PreviewProvider {
    static var previews: some View {
        ContactsList()
    }
}
