//
//  Contacto+CoreDataProperties.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//
//

import Foundation
import CoreData


extension Contacto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contacto> {
        return NSFetchRequest<Contacto>(entityName: "Contacto")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var emoji: String?
    @NSManaged public var label: Label?
    @NSManaged public var transactions: NSSet?

}

// MARK: Generated accessors for transactions
extension Contacto {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}

extension Contacto : Identifiable {

}
