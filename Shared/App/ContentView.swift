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
    @State var sectionSelected : SectionSelected? = .debts
    
    
    var body: some View {
        NavigationView {
            #if os(iOS)
            if horizontalSizeClass == .compact {
                Text("Hola soy un iPhone")
            } else {
                Text("Hola soy un iPad")
            }
            #elseif os(macOS)
            SideBarView(sectionSelected : $sectionSelected)
            #endif
        }
    }
}
