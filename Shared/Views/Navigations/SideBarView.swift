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
            List() {
                Label(
                    title: { Text("DebtMe")
                        .font(Font.system(.title, design: .rounded).weight(.black)) },
                    icon: {  Image(.pig)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30) }
                )
                .labelStyle(.titleAndIcon)
               
                NavigationLink(destination: ContactsList(), tag: SectionSelected.contacts, selection: $sectionSelected) {
                    Label("Contacts", systemImage: "person.2.fill")
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                }
                
                NavigationLink(destination: SettingsList(), tag: SectionSelected.settings, selection: $sectionSelected) {
                    Label("Settings", systemImage: "gear")
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                }
                
            }
            .navigationSplitViewColumnWidth(min: 150, ideal: 200, max: .infinity)
             
          
          } content: {
              ContactsList()
                  .navigationSplitViewColumnWidth(min: 250, ideal: 500, max: .infinity)
          } detail: {
              EmptyPaymentView(empty: true)
                  .navigationSplitViewColumnWidth(min: 250, ideal: 500, max: .infinity)
          }
         
        
    }
    
   
}

struct toogleSideBarButton: View {
    var body: some View {
            Button(action: toggleSidebar, label: {
                Image(systemName: "sidebar.left")
                    .font(Font.system(.headline, design: .rounded).weight(.black))
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
