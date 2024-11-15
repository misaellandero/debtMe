//
//  ContactLabel+CoreDataProperties.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 26/03/21.
//
//

import Foundation
import CoreData
import SwiftUI

extension ContactLabel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactLabel> {
        return NSFetchRequest<ContactLabel>(entityName: "ContactLabel")
    }

    @NSManaged public var color: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var contacts: NSSet?
    @NSManaged public var services: NSSet?
    @NSManaged public var labelForService: Bool
    // MARK: - Wrapped vars
    
    // Wrapped id
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    // Wrapped name
    public var wrappedName: String {
        name ?? "Friend"
    }
    
    // MARK: - Array contacts
    public var contactsArray: [Contact] {
        let set = contacts as? Set<Contact> ?? []
        
        return set.sorted {
            $0.wrappedName > $1.wrappedName
        }
    }
    
    // MARK: - Computed properties
    
    //Label color
    public var labelColor : Color {
        //Color
        let index = Int(color)
        return AppColorsModel.colors[index].color
    }
}

// MARK: Generated accessors for contacts
extension ContactLabel {

    @objc(addContactsObject:)
    @NSManaged public func addToContacts(_ value: Contact)

    @objc(removeContactsObject:)
    @NSManaged public func removeFromContacts(_ value: Contact)

    @objc(addContacts:)
    @NSManaged public func addToContacts(_ values: NSSet)

    @objc(removeContacts:)
    @NSManaged public func removeFromContacts(_ values: NSSet)

}

// MARK: Generated accessors for services
extension ContactLabel {

    @objc(addServicesObject:)
    @NSManaged public func addToServices(_ value: Services)

    @objc(removeServicesObject:)
    @NSManaged public func removeFromServices(_ value: Services)

    @objc(addServices:)
    @NSManaged public func addToServices(_ values: NSSet)

    @objc(removeServices:)
    @NSManaged public func removeFromAervices(_ values: NSSet)

}


extension ContactLabel : Identifiable {

}
