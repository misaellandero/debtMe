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
    @NSManaged public var dateCreation: Date?
    @NSManaged public var dateSettled: Date?
    @NSManaged public var debt: Bool
    @NSManaged public var des: String?
    @NSManaged public var id: UUID?
    @NSManaged public var settled: Bool
    @NSManaged public var contact: Contact?
    
    // MARK: - Wrapped vars
    
    // Wrapped id
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    // Wrapped des
    public var wrappedDes: String {
        des ?? "No details provided"
    }
    
    
    // MARK: - Wrapped Dates
    
    //Transaction Creation Date
    public var wrappedDateCreation : Date {
        dateCreation ?? Date()
    }
    //Transaction Settled Date
    public var wrappedDateSettled : Date {
        dateSettled ?? Date()
    }
    
    // MARK: - Formated Dates
    //Transaction Creation Date formated
    public var transactionCreationDateFormated : String {
        //DateFormatter extension
        return DateFormatter.mediumDateTimeFormatter.string(from: wrappedDateCreation)
    }
    
    //Transaction Settled Date formated
    public var transactionSettledDateFormated : String {
        //DateFormatter extension
        return DateFormatter.mediumDateTimeFormatter.string(from: wrappedDateSettled)
    }
    
    
     
}

extension Transaction : Identifiable {

}
