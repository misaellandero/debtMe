//
//  Services+CoreDataProperties.swift
//  debtMe
//
//  Created by Misael Landero on 21/02/24.
//
//

import Foundation
import CoreData


extension Services {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Services> {
        return NSFetchRequest<Services>(entityName: "Services")
    }

    @NSManaged public var amount: Double
    @NSManaged public var des: String?
    @NSManaged public var expense: Bool
    @NSManaged public var frequency: Int16
    @NSManaged public var frequency_date: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    
    // MARK: - Wrapped vars
    
    // Wrapped id
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    // Wrapped des
    public var wrappedDes: String {
        des ?? "No details provided"
    }
    
    // Wrapped des
    public var wrappedName: String {
        name ?? "No name"
    }
    

}

extension Services : Identifiable {

}
