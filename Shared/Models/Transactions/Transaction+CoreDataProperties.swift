//
//  Transaction+CoreDataProperties.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var amount: Double
    @NSManaged public var date: Date?
    @NSManaged public var debt: Bool
    @NSManaged public var des: String?
    @NSManaged public var id: UUID?
    @NSManaged public var settled: Bool
    @NSManaged public var contact: Contacto?

}

extension Transaction : Identifiable {

}
