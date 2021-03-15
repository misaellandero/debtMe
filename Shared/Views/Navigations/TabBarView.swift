//
//  TabBarView.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct TabBarView: View {
    // MARK: - current section selected
    @Binding var sectionSelected : SectionSelected?
    
    var body: some View {
        TabView(selection: $sectionSelected){
            // MARK: - Contacts
            Text("Contacts")
                .tabItem {
                    Label("Contacts", systemImage: "person.2.fill")
                }
                .tag(SectionSelected.contacts)
            // MARK: - Debts
            Text("Debts")
                .tabItem {
                    Label("Debts", systemImage: "dollarsign.square")
                }
                .tag(SectionSelected.debts)
            // MARK: - Loans
            Text("Loans")
                .tabItem {
                    Label("Loans", systemImage: "dollarsign.square.fill")
                }
                .tag(SectionSelected.loans)
            // MARK: - Settings
            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(SectionSelected.settings)
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(sectionSelected: .constant(.contacts))
    }
}
