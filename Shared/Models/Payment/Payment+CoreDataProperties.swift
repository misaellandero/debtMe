//
//  Payment+CoreDataProperties.swift
//  debtMe
//
//  Created by Misael Landero on 12/02/23.
//
//

import Foundation
import CoreData

extension Payment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Payment> {
        return NSFetchRequest<Payment>(entityName: "Payment")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var notes: String?
    @NSManaged public var amount: Double
    @NSManaged public var date: Date?
    @NSManaged public var transaction: Transaction?
    @NSManaged public var image: Data?
    
    // MARK: - Wrapped vars
    
    // Wrapped id
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    // Wrapped des
    public var wrappedNotes: String {
        notes ?? "No notes provided"
    }
    
    // MARK: - Wrapped Dates
    
    //Payment Creation Date
    public var wrappedDateCreation : Date {
        date ?? Date()
    }
    
    // MARK: - Formated Dates
    //Payment Date formated
    public var creationDateFormated : String {
        //DateFormatter extension
        return DateFormatter.mediumDateTimeFormatter.string(from: wrappedDateCreation)
    }
    
    // MARK: - Computed properties 
     
}

extension Payment : Identifiable {

}
