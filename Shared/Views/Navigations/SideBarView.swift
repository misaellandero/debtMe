//
//  SideBarView.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct SideBarView: View {
    // MARK: - current section selected 
    @Binding var sectionSelected : SectionSelected? 
    @State private var isDefaultItemActive = true
    
    var body: some View {
        NavigationView {
            List(selection: $sectionSelected) {
                NavigationLink(destination: ContactsList(), tag: SectionSelected.contacts, selection: $sectionSelected) {
                    Label("Contacts", systemImage: "person.2.fill")
                }
                
                NavigationLink(destination: Text("Debts"), tag: SectionSelected.debts, selection: $sectionSelected) {
                    Label("Debts", systemImage: "dollarsign.square")
                }
                
                NavigationLink(destination: Text("Loans"), tag: SectionSelected.loans, selection: $sectionSelected) {
                    Label("Loans", systemImage: "dollarsign.square.fill")
                }
                
                NavigationLink(destination: Text("Settings"), tag: SectionSelected.settings, selection: $sectionSelected) {
                    Label("Settings", systemImage: "gear")
                } 
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 250, idealWidth: 250, maxWidth: 350)
            .toolbar{
                ToolbarItem(placement:.navigation){
                    Text("DebtMe")
                        .font(Font.system(.largeTitle, design: .rounded).weight(.black))
                }
            }
            //.navigationTitle("DebtMe")
        }
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView(sectionSelected: .constant(.contacts))
    }
}
