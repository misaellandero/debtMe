//
//  Persistence.swift
//  Shared
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import CoreData
public class PersistentCloudKitContainer: ObservableObject {
    private static let appGroupIdentifier = "group.mx.landercorp.debtMe"
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "debtMe")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No descriptions found")
        }

        if let sharedStoreURL = sharedStoreURL {
            #if BETA_DEMO_DATA
            removeStore(at: sharedStoreURL)
            #else
            migrateDefaultStoreIfNeeded(to: sharedStoreURL, containerName: "debtMe")
            #endif
            description.url = sharedStoreURL
        }
        
        description.setOption(true as NSObject, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

            #if BETA_DEMO_DATA
            DemoDataSeeder.resetAndSeed(in: container.viewContext)
            #endif
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
         
        return container
    }() 

    private var sharedStoreURL: URL? {
        guard let storeDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier) else {
            return nil
        }

        #if BETA_DEMO_DATA
        return storeDirectory.appendingPathComponent("debtMe-beta-demo.sqlite")
        #else
        return storeDirectory.appendingPathComponent("debtMe.sqlite")
        #endif
    }

    private func removeStore(at url: URL) {
        let fileManager = FileManager.default
        storeSidecarURLs(for: url).forEach { storeURL in
            if fileManager.fileExists(atPath: storeURL.path) {
                try? fileManager.removeItem(at: storeURL)
            }
        }
    }

    private func migrateDefaultStoreIfNeeded(to sharedStoreURL: URL, containerName: String) {
        let fileManager = FileManager.default
        guard !fileManager.fileExists(atPath: sharedStoreURL.path),
              let defaultStoreURL = NSPersistentContainer.defaultDirectoryURL()
                .appendingPathComponent("\(containerName).sqlite") as URL?,
              fileManager.fileExists(atPath: defaultStoreURL.path) else {
            return
        }

        storeSidecarURLs(for: defaultStoreURL).forEach { sourceURL in
            let targetURL = sharedStoreURL.deletingLastPathComponent().appendingPathComponent(sourceURL.lastPathComponent)
            if fileManager.fileExists(atPath: sourceURL.path) {
                try? fileManager.copyItem(at: sourceURL, to: targetURL)
            }
        }
    }

    private func storeSidecarURLs(for url: URL) -> [URL] {
        [
            url,
            URL(fileURLWithPath: url.path + "-shm"),
            URL(fileURLWithPath: url.path + "-wal")
        ]
    }
}
