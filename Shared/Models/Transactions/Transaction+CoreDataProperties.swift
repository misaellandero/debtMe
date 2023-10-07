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
    @NSManaged public var notes: String?
    @NSManaged public var id: UUID?
    @NSManaged public var settled: Bool
    @NSManaged public var contact: Contact?
    @NSManaged public var payments: NSSet?
    
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
    public var wrappedNotes: String {
        notes ?? ""
    }
    
    
    // MARK: - Wrapped Dates
    
    //Transaction Creation Date
    public var wrappedDateCreation : Date {
        dateCreation ?? Date()
    }
    
    //Transaction Settled Date
    public var wrappedDateSettled: Date {
        if let lastPaymentDate = paymentsArray.first?.wrappedDateCreation {
            return lastPaymentDate
        } else {
            return dateSettled ?? Date()
        }
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
    
    // MARK: - Computed properties
    
    //Transaction contact name
    public var contactName : String {
       
        return contact?.wrappedName ?? "Unknown"
    }
    
    //Paymenys
    public var totalPayments : Double {
        let sum = paymentsArray
            .map { $0.amount }
            .reduce(0, +)
        return sum
    }
    
    //Balance
    public var totalBalance : Double {
        let sum = paymentsArray
            .map { $0.amount }
            .reduce(0, +)
        let balance = amount - sum
        
        if balance <= 0 {
            settled = true
        }
        
        return balance
    }
    
    
    // MARK: - Array Payments
    public var paymentsArray: [Payment] {
        let set = payments as? Set<Payment> ?? []
        
        return set.sorted {
            $0.wrappedDateCreation > $1.wrappedDateCreation
        }
    }
}
 
// MARK: Generated accessors for payments
extension Transaction {

    @objc(addPaymentsObject:)
    @NSManaged public func addToPayments(_ value: Payment)

    @objc(removePaymentsObject:)
    @NSManaged public func removeFromPayments(_ value: Payment)

    @objc(addPayments:)
    @NSManaged public func addToPayments(_ values: NSSet)

    @objc(removePayments:)
    @NSManaged public func removeFromPayments(_ values: NSSet)

}

extension Transaction : Identifiable {

}
