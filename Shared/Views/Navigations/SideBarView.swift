//
//  SideBarView.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

#if os(macOS)
struct SideBarView: View {
    // MARK: - current section selected 
    @Binding var sectionSelected: SectionSelected
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    var body: some View {
       
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $sectionSelected) {
                Label(
                    title: { Text("DebtMe")
                        .appBrandTitle() },
                    icon: {  Image(.pig)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30) }
                )
                .labelStyle(.titleAndIcon)

                Label("Home", systemImage: "house.fill")
                    .appToolbarLabel()
                    .tag(SectionSelected.home)
               
                Label("People", systemImage: "person.2.fill")
                    .appToolbarLabel()
                    .tag(SectionSelected.contacts)

                Label("Services", systemImage: "chart.bar.doc.horizontal")
                    .appToolbarLabel()
                    .tag(SectionSelected.loans)
                
                Label("Settings", systemImage: "gear")
                    .appToolbarLabel()
                    .tag(SectionSelected.settings)
                
            }
            .navigationSplitViewColumnWidth(min: 150, ideal: 200, max: .infinity)
             
          } detail: {
              NavigationStack {
                  Group {
                      switch sectionSelected {
                      case .home:
                          HomeView()
                      case .contacts:
                          ContactsList()
                      case .loans:
                          ServicesList()
                      case .settings:
                          SettingsList()
                      case .debts, .budget, .bills:
                          EmptyView()
                      }
                  }
              }
              .navigationSplitViewColumnWidth(min: 250, ideal: 500, max: .infinity)
          }
          .navigationSplitViewStyle(.balanced)
        
    }
    
   
}

struct toogleSideBarButton: View {
    var body: some View {
            Button(action: toggleSidebar, label: {
                Image(systemName: "sidebar.left")
                    .appToolbarLabel()
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

#else
struct SideBarView: View {
    @Binding var sectionSelected: SectionSelected

    var body: some View {
        EmptyView()
    }
}
#endif
