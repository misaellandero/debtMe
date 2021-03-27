//
//  ContentView.swift
//  Shared
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI
import CoreData

// MARK: - Navigation Options
enum SectionSelected {
    case contacts, debts, loans, settings
}

struct ContentView: View {
    
    // MARK: - Screen Size for determining ipad or iphone screen
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    // MARK: - current section selected 
    @State var sectionSelected : SectionSelected? = .contacts
  
    var body: some View {
            Group{
                #if os(iOS)
                if horizontalSizeClass == .compact {
                    TabBarView(sectionSelected : $sectionSelected)
                } else {
                    SideBarView(sectionSelected : $sectionSelected)
                }
                #elseif os(macOS)
                SideBarView(sectionSelected : $sectionSelected)
                #endif
            }
       
    }
}
