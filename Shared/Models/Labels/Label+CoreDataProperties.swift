//
//  Label+CoreDataProperties.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//
//

import Foundation
import CoreData


extension Label {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Label> {
        return NSFetchRequest<Label>(entityName: "Label")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var color: Int16
    @NSManaged public var contacts: NSSet?

}

// MARK: Generated accessors for contacts
extension Label {

    @objc(addContactsObject:)
    @NSManaged public func addToContacts(_ value: Contacto)

    @objc(removeContactsObject:)
    @NSManaged public func removeFromContacts(_ value: Contacto)

    @objc(addContacts:)
    @NSManaged public func addToContacts(_ values: NSSet)

    @objc(removeContacts:)
    @NSManaged public func removeFromContacts(_ values: NSSet)

}

extension Label : Identifiable {

}
