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
      
        NavigationSplitView {
            List(/*selection: $sectionSelected*/) {
                NavigationLink(destination: ContactsList(), tag: SectionSelected.contacts, selection: $sectionSelected) {
                    Label("Contacts", systemImage: "person.2.fill")
                }
                
                NavigationLink(destination: TransactionsListFilter(isDebt:true) , tag: SectionSelected.debts, selection: $sectionSelected) {
                    Label("Debts", systemImage: "dollarsign.square")
                }
                .disabled(true)
                
                NavigationLink(destination: TransactionsListFilter(isDebt:false), tag: SectionSelected.loans, selection: $sectionSelected) {
                    Label("Loans", systemImage: "dollarsign.square.fill")
                }
                .disabled(true)
                
                NavigationLink(destination: Text("Settings"), tag: SectionSelected.settings, selection: $sectionSelected) {
                    Label("Settings", systemImage: "gear")
                }
                .disabled(true)
                
            }
            .toolbar{
                ToolbarItem(placement:.navigation){
                    Text("DebtMe")
                }
             }
             
          
          } content: {
              ContactsList()
          } detail: {
              EmptyPaymentView(empty: true)
          }
        
             
        
       /* NavigationView {
            List() {
                NavigationLink(destination: ContactsList(), tag: SectionSelected.contacts, selection: $sectionSelected) {
                    Label("Contacts", systemImage: "person.2.fill")
                }
                
                NavigationLink(destination: TransactionsListFilter(isDebt:true) , tag: SectionSelected.debts, selection: $sectionSelected) {
                    Label("Debts", systemImage: "dollarsign.square")
                }
                
                NavigationLink(destination: TransactionsListFilter(isDebt:false), tag: SectionSelected.loans, selection: $sectionSelected) {
                    Label("Loans", systemImage: "dollarsign.square.fill")
                }
                
                NavigationLink(destination: Text("Settings"), tag: SectionSelected.settings, selection: $sectionSelected) {
                    Label("Settings", systemImage: "gear")
                } 
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("DebtMe")
            .frame(minWidth: 150, idealWidth: 250, maxWidth: 350)
           /* .toolbar{
                #if os(iOS)
                ToolbarItem(placement:.principal){
                    Text("DebtMe")
                }
                #elseif os(macOS)
                //Toggle Sidebar Button
                ToolbarItem(placement: .navigation){
                    
                    toogleSideBarButton()
                }
                #endif
            }
            */
            
            Text("Detail view")
                .frame(minWidth: 400)
            
            
            Text("Detail view")
                .frame(idealWidth: 400)
            
            
            Text("Detail view")
                .frame(idealWidth: 400)
        }*/
    }
    
   
}

struct toogleSideBarButton: View {
    var body: some View {
            Button(action: toggleSidebar, label: {
                Image(systemName: "sidebar.left")
            })
    }
}

// Toggle Sidebar Function
func toggleSidebar() {
    #if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    #endif
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView(sectionSelected: .constant(.contacts))
    }
}
