//
//  ContactsList.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct ContactsList: View {
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    
    
    @State private var showingNewContactForm = false
    var body: some View {
        List{
            ForEach(0..<100) { index in
                Text("Hello, World! \(index)")
            }
            
        }
        .navigationTitle("Contacts")
        .toolbar {
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
