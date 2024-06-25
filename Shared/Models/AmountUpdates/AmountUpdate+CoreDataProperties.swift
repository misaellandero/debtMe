//
//  AmountUpdate+CoreDataProperties.swift
//  debtMe
//
//  Created by Misael Landero on 17/06/24.
//
//

import Foundation
import CoreData


extension AmountUpdate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AmountUpdate> {
        return NSFetchRequest<AmountUpdate>(entityName: "AmountUpdate")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var amount: Double
    @NSManaged public var updateDate: Date?
    @NSManaged public var service: Services?

    var wrappedUpdateDate : Date {
        updateDate ??  Date()
    }
}

extension AmountUpdate : Identifiable {

}
