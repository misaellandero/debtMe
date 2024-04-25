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
    @StateObject var coreData = PersistentCloudKitContainer()
    // User preference settings
    let userPreferences = UserPreferences()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreData.persistentContainer.viewContext)
                .environmentObject(userPreferences)
                .navigationTitle("")
               
                    
        }
    }
}
