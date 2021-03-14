//
//  Persistence.swift
//  Shared
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

     
    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "debtMe")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
