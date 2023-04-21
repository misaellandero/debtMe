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
            //Text("hi")
            List(/*selection: $sectionSelected*/) {
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
            //.listStyle(SidebarListStyle())
            .frame(minWidth: 150, idealWidth: 250, maxWidth: 350)
            .toolbar{
                #if os(iOS)
                ToolbarItem(placement:.principal){
                    Text("DebtMe")
                }
                #elseif os(macOS)
                //Toggle Sidebar Button
                ToolbarItem(placement: .navigation){
                    
                    Text("\(Image(systemName: "sidebar.left"))")
                        .onTapGesture {
                            toggleSidebar()
                        }
                    
                    /*Button(action: toggleSidebar, label: {
                        Text("\(Image(systemName: "sidebar.left"))")
                            .font(Font.system(.headline, design: .rounded).weight(.bold))
                        
                        /*Image(systemName: "sidebar.left")
                            .font(Font.system(.title, design: .rounded).weight(.black))*/
                    })*/
                }
                #endif
            }
            
            
            Text("Detail view")
            Text("Detail view")
            #if  os(macOS)
            Text("Detail view")
            #endif
           
            //.navigationTitle("DebtMe")
        }
    }
    
    // Toggle Sidebar Function
    func toggleSidebar() {
        #if os(macOS)
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView(sectionSelected: .constant(.contacts))
    }
}
