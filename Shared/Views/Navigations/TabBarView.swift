//
//  TabBarView.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct TabBarView: View {
    // MARK: - current section selected
    @State var sectionSelected = SectionSelected.contacts
    
    var body: some View {
        
        ZStack{
            switch sectionSelected {
            case .contacts:
                NavigationView{
                    ContactsList()
                }
            case .debts:
                NavigationView{
                    Text("debts")
                }
            case .loans:
                NavigationView{
                    Text("lons")
                }
            case .settings:
                NavigationView{
                    Text("settings")
                }
            case .budget:
                NavigationView{
                    Text("Budget")
                }
            }
            
            
            ButtomBar(sectionSelected: $sectionSelected)
        }
        /*TabView(selection: $sectionSelected){
            // MARK: - Contacts
            NavigationView{
                ContactsList()
            }
            .tag(SectionSelected.contacts)
            // MARK: - Debts
            Text("Debts")
                /*.tabItem {
                    Label("Debts", systemImage: "dollarsign.square")
                }*/
                .tag(SectionSelected.debts)
            // MARK: - Loans
            Text("Loans")
                /*.tabItem {
                    Label("Loans", systemImage: "dollarsign.square.fill")
                }*/
                .tag(SectionSelected.loans)
            // MARK: - Settings
            Text("Settings")
                /*.tabItem {
                    Label("Settings", systemImage: "gear")
                }*/
                .tag(SectionSelected.settings)
        }*/
        
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView( )
    }
}
