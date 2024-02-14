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
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                }
                
                NavigationLink(destination: TransactionsListFilter(isDebt:true) , tag: SectionSelected.debts, selection: $sectionSelected) {
                    Label("Debts", systemImage: "dollarsign.square")
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                }
                //.disabled(true)
                
                NavigationLink(destination: TransactionsListFilter(isDebt:false), tag: SectionSelected.loans, selection: $sectionSelected) {
                    Label("Loans", systemImage: "dollarsign.square.fill")
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                }
                //.disabled(true)
                
                NavigationLink(destination: SettingsList(), tag: SectionSelected.settings, selection: $sectionSelected) {
                    Label("Settings", systemImage: "gear")
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                }
                //.disabled(true)
                
            }
            
            .toolbar{
                ToolbarItem(placement:.navigation){
                    Text("DebtMe")
                }
             }
             
          
          } content: {
              ContactsList()
                  .navigationSplitViewColumnWidth(min: 500, ideal: 700, max: .infinity)
          } detail: {
              EmptyPaymentView(empty: true)
                  .navigationSplitViewColumnWidth(min: 500, ideal: 700, max: .infinity)
          }
         
        
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
