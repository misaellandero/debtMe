//
//  ContactsList.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI
import CoreData

enum shortMode : String {
    case alfabethAsc, alfabethDes, amountAsc, amountDes
}

struct ContactsList: View {
    
    @State private var showingNewContactForm = false
    
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
      
    @FetchRequest(entity: ContactLabel.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ContactLabel.name, ascending: true)]) var labels: FetchedResults<ContactLabel>
    
    @State var searchQuery = ""
    
 
    @State var selectedTag : String = "All"
    
    @AppStorage("shortModeContacts") var shortMode: shortMode = .alfabethAsc
    
    var body: some View {
        Group{
            #if os(macOS)
            ContactsRows(searchQuery: $searchQuery, shortMode: $shortMode, selectedTag: $selectedTag, showingNewContactForm: $showingNewContactForm)
            .toolbar {
                
                ToolbarItem(placement: .navigation ){
                    Text("\(Image(systemName: "person.2.fill")) Contacts")
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                }
                
                ToolbarItem(placement: .navigation ){
                    SearchTextField(searchQuery: $searchQuery)
                    
                }
            }
            #else
            
            ContactsRows(searchQuery: $searchQuery, shortMode: $shortMode, selectedTag: $selectedTag, showingNewContactForm: $showingNewContactForm)
            .searchable(text: $searchQuery)
            .listStyle(InsetGroupedListStyle())
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle(Text("Contacts"))
            
            #endif
        }
        
        .toolbar{
            
            ToolbarItem(placement: .primaryAction ){
                Button(action:{
                    showingNewContactForm.toggle()
                }){
                    Label("Add", systemImage: "plus.circle.fill") .font(Font.system(.headline, design: .rounded).weight(.black))
                        .foregroundColor(.accentColor)
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Label("Sort alphabetically", systemImage: "arrow.up.and.down.text.horizontal")
                    .font(Font.system(.headline, design: .rounded).weight(.black))
                    Button(action: {
                        shortMode = .alfabethAsc
                    }) {
                        Label("Ascending A-Z", systemImage: "platter.filled.top.and.arrow.up.iphone")
                    }
                    Button(action: {
                        shortMode = .alfabethDes
                    }) {
                        Label("Descending Z-A", systemImage: "platter.filled.bottom.and.arrow.down.iphone")
                    }
                    Divider()
                    
                    Label("Sort by Amount", systemImage: "arrow.up.and.down.text.horizontal")
                    
                    .font(Font.system(.headline, design: .rounded).weight(.black))
                    Button(action: {
                        shortMode = .amountAsc
                    }) {
                        Label("Lower First", systemImage: "platter.filled.top.and.arrow.up.iphone")
                    }
                    Button(action: {
                        shortMode = .amountDes
                    }) {
                        Label("Higher First", systemImage: "platter.filled.bottom.and.arrow.down.iphone")
                    }
                    Divider()
                    
                    Label("Tags", systemImage: "tag")
                    
                    .font(Font.system(.headline, design: .rounded).weight(.black))
                    Picker(selection: $selectedTag, label: Text("Filter by tag")) {
                        Text("All").tag("All")
                        ForEach(labels){ label in
                            Text(label.wrappedName).tag(label.wrappedName)
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.horizontal.3.decrease.circle.fill")   .font(Font.system(.headline, design: .rounded).weight(.black))
                        .foregroundColor(.gray)
                }
            }
        }
        .sheet(isPresented: $showingNewContactForm){
            ContactsNewForm()
        }
    }
    
   
    
    
}

struct ContactsRows : View  {
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
     
    @FetchRequest(entity: Contact.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Contact.name, ascending: true)]) var contacts: FetchedResults<Contact>
     
    @Binding var searchQuery : String
    
    @Binding var shortMode : shortMode
    
    @Binding var selectedTag : String
    
    @Binding var showingNewContactForm : Bool
   
  
    var filteredContacts: [Contact] {
        let sortedContacts: [Contact]
        
        switch shortMode {
        case .alfabethAsc:
            sortedContacts = contacts.sorted { $0.name ?? "" < $1.name ?? "" }
        case .alfabethDes:
            sortedContacts = contacts.sorted { $0.name ?? "" > $1.name ?? "" }
        case .amountAsc:
            sortedContacts = contacts.sorted { $0.balance < $1.balance  }
        case .amountDes:
            sortedContacts = contacts.sorted { $0.balance  > $1.balance  }
        }
        
        let filteredByTag: [Contact]
         
         if selectedTag == "All" {
             // No tag selected, use all contacts
             filteredByTag = sortedContacts
         } else {
             // Filter contacts based on the selected tag
             filteredByTag = sortedContacts.filter { contact in
                 contact.label?.wrappedName == selectedTag
             }
         }
         
         if searchQuery.isEmpty {
             return filteredByTag
         } else {
             // Further filter contacts based on the search query
             return filteredByTag.filter { contact in
                 contact.name?.localizedCaseInsensitiveContains(searchQuery) == true
             }
         }
    }
    
    //Safe measures for delete
    @State private var showAlertDeletContact = false
    @State private var contactToDelete: Contact?
    
    
    var body: some View {
        //No records yet
        if filteredContacts.isEmpty {
            EmptyPaymentView(empty: true)
            Button {
                showingNewContactForm.toggle()
            } label: {
                Label("New Contact", systemImage: "plus.circle.fill")
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
        } else {
            List{
                ForEach(filteredContacts, id: \.id) { contact in
                    NavigationLink(destination: TransactionsContactList(contact: contact)) {
                        ContactsRow(contact: contact)
                            .environment(\.managedObjectContext, self.moc)
                    }
                }
                .onDelete(perform: deleteItem)
            }
            .alert(isPresented: $showAlertDeletContact) {
                Alert(
                    title: Text("Delete Contact"),
                    message: Text("This contact has unsettled transactions and balance is not Zero. Are you sure you want to delete?"),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .destructive(Text("Delete")) {
                        // Perform the deletion when the user confirms
                        if let contactToDelete = contactToDelete {
                            performDeletion(for: contactToDelete)
                        }
                    }
                )
            }
        } 
    }
    
    
    
    
 //check is safe to delete
    func deleteItem(at offsets: IndexSet) {
        for offset in offsets {
            
            let contact = self.filteredContacts[offset]
            
            if contact.balance != 0 && contact.transactionsArray.count != 0 {
                contactToDelete = contact
                showAlertDeletContact = true
            } else {
                performDeletion(for: contact)
            }
            
        }
    }
    
    // Helper method to perform deletion
    func performDeletion(for contact: Contact) {
        for transaction in contact.transactionsArray {
            for payment in transaction.paymentsArray {
                // Delete payment related
                self.moc.delete(payment)
            }
            // Delete transactions related
            self.moc.delete(transaction)
        }
        
        // Delete contact
        self.moc.delete(contact)
        
        try? self.moc.save()
    }
}

struct ContactsList_Previews: PreviewProvider {
    static var previews: some View {
        ContactsList()
    }
}
