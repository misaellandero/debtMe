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
            List(selection: $sectionSelected) {
                NavigationLink(destination: ContactsList(), tag: SectionSelected.contacts, selection: $sectionSelected) {
                    Label("Contacts", systemImage: "person.2.fill")
                        .font(Font.system(.title3, design: .rounded).weight(.bold))
                }
                
                NavigationLink(destination: Text("Debts"), tag: SectionSelected.debts, selection: $sectionSelected) {
                    Label("Debts", systemImage: "dollarsign.square")
                        .font(Font.system(.title3, design: .rounded).weight(.bold))
                }
                
                NavigationLink(destination: Text("Loans"), tag: SectionSelected.loans, selection: $sectionSelected) {
                    Label("Loans", systemImage: "dollarsign.square.fill")
                        .font(Font.system(.title3, design: .rounded).weight(.bold))
                }
                
                NavigationLink(destination: Text("Settings"), tag: SectionSelected.settings, selection: $sectionSelected) {
                    Label("Settings", systemImage: "gear")
                        .font(Font.system(.title3, design: .rounded).weight(.bold))
                } 
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 250, idealWidth: 250, maxWidth: 350)
            .toolbar{
                #if os(iOS)
                ToolbarItem(placement:.principal){
                    Text("DebtMe")
                       .font(Font.system(.largeTitle, design: .rounded).weight(.black))
                }
                #elseif os(macOS)
                //Toggle Sidebar Button
                ToolbarItem(placement: .navigation){
                    
                    Text("\(Image(systemName: "sidebar.left"))")
                         .font(Font.system(.title, design: .rounded).weight(.bold))
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
            
            
            #if  os(macOS)
            Text("Detail view")
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
