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
    
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
 
    #warning("Need to check way update is not showing")
    
    var body: some View {
        Group{
            #if os(iOS) 
                List{
                    ContactsRows()
                        //.environment(\.managedObjectContext, self.moc)
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(
                    leading:
                        Button(action:{showingNewContactForm.toggle()}){
                            Label("Filter", systemImage: "line.horizontal.3.decrease.circle.fill")
                                .foregroundColor(.gray)
                                .font(Font.system(.headline, design: .rounded).weight(.black))
                        },
                    
                    trailing:
                        Button(action:{showingNewContactForm.toggle()}){
                            Label("Add", systemImage: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(Font.system(.headline, design: .rounded).weight(.black))
                        }
                )
                .toolbar {
                    ToolbarItem(placement:.principal){
                        Text("\(Image(systemName: "person.2.fill")) Contacts")
                            .font(Font.system(.title, design: .rounded).weight(.black))
                    }
                }
            #elseif os(macOS)
        
                List{
                    ContactsRows()
                }
                .toolbar {
                    
                    ToolbarItem(placement: .navigation ){
                        Text("\(Image(systemName: "person.2.fill")) Contacts")
                            .font(Font.system(.title, design: .rounded).weight(.black))
                    }
                    
                    ToolbarItem(placement: .primaryAction ){
                  
                            Label("Add", systemImage: "person.crop.circle.badge.plus")
                                .foregroundColor(.accentColor)
                                .font(Font.system(.title, design: .rounded).weight(.black))
                                .onTapGesture {
                                    showingNewContactForm.toggle()
                                }
                    }
                }
          
            
            #endif
        } 
        /**/
        .sheet(isPresented: $showingNewContactForm){
            //Text("hi")
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
            NavigationLink(destination: TransactionsContactList(contact: contact) ){
                ContactsRow(contact: contact)
                    .environment(\.managedObjectContext, self.moc)
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
