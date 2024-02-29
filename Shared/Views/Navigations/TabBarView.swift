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
        TabView(selection: $sectionSelected){
            // MARK: - Contacts
            NavigationView{
                ContactsList()
            }
            .tabItem {
                Label("Contacts", systemImage: "person.2.fill")
            }
            .tag(SectionSelected.contacts)
            /* // MARK: - Debts
            NavigationView{
                TransactionsListFilter(isDebt:true)
            }
            .tabItem {
                Label("Debts", systemImage: "dollarsign.square")
            }
            .tag(SectionSelected.debts)
            
           // MARK: - Loans
            NavigationView{
                TransactionsListFilter(isDebt:false)
            }
            .tabItem {
                Label("Loans", systemImage: "dollarsign.square.fill")
            }
            .tag(SectionSelected.loans)
             */
            // MARK: - Bills
            NavigationView{
                BillsList()
            }
            .tabItem {
                Label("Bills", systemImage: "chart.bar.doc.horizontal")
            }
            .tag(SectionSelected.loans)
            
            // MARK: - Settings
            NavigationView{
                SettingsList()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(SectionSelected.settings)
            
        }
        .font(Font.system(.body, design: .rounded))
        
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView( )
    }
}
