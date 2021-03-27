//
//  debtMeApp.swift
//  Shared
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

@main
struct debtMeApp: App {
    //Coreda Data
    let persistenceController = PersistenceController.shared
    // User preference settings
    let userPreferences = UserPreferences()
    
    
    
    var body: some Scene {
        WindowGroup {
              ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(userPreferences)
        }
    }
}
