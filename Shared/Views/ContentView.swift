//
//  ContentView.swift
//  Shared
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Contact.name, ascending: true)],
        animation: .default)
    private var contacts: FetchedResults<Contact>

    var body: some View {
        List {
            ForEach(contacts) { contact in
                Text("Item at \(contact.wrappedName)")
            }
            //.onDelete(perform: {})
        }
        .toolbar {
            #if os(iOS)
            EditButton()
            #endif
            /*Button(action: {}) {
                Label("Add Item", systemImage: "plus")
            }*/
        }
    }
 
}

 

 
