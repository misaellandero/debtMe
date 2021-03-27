//
//  ContactsList.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI
import CoreData

struct ContactsList: View {
     
     @State private var showingNewContactForm = false
   
    var body: some View {
        Group{
            #if os(iOS) 
                List{
                    ContactsRows()
                }
                .listStyle(InsetGroupedListStyle())
          
            #elseif os(macOS)
            List{
                ContactsRows()
            }
            #endif
        }
        //.navigationTitle("Contacts")
        .toolbar {
            ToolbarItem(placement:.navigation){
                Text("\(Image(systemName: "person.2.fill")) Contacts")
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

struct ContactsRows : View  {
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
  
    @FetchRequest(entity: Contact.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Contact.name, ascending: true)]) var contacts: FetchedResults<Contact>
    
    var body: some View {
        ForEach(contacts, id: \.id){ contact in
            NavigationLink(destination: ContactsDetail() ){
                ContactsRow(contact: contact)
            }
        }.onDelete(perform: deleteItem)
    }
    
    func deleteItem(at offsets: IndexSet) {
        
        for offset in offsets {
            let contact =  self.contacts[offset]
            self.moc.delete(contact)
        }
         
        try? self.moc.save()
        
       }
}

struct ContactsList_Previews: PreviewProvider {
    static var previews: some View {
        ContactsList()
    }
}
