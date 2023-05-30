//
//  Contact+CoreDataProperties.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 26/03/21.
//
//

import Foundation
import CoreData
import SwiftUI

extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var label: ContactLabel?
    @NSManaged public var transactions: NSSet?
    
    // MARK: - Wrapped vars
    
    // Wrapped id
    public var wrappedId: UUID {
        id ?? UUID()
    }
    // Wrapped name
    public var wrappedName: String {
        name ?? "Unknown"
    }
    // Wrapped emoji
    public var wrappedEmoji: String {
        emoji ?? "🙂"
    }
    
    // WrappedLabelName
    public var WrappedLabelName: String {
        label?.wrappedName ?? "No name"
    }
    
    // WrappedLabelColor
    public var WrappedLabelColor : Color {
        let index = label?.color ?? 0
        return AppColorsModel.colors[Int(index)].color
    }
    
    // MARK: - Array transactions
    public var transactionsArray: [Transaction] {
        let set = transactions as? Set<Transaction> ?? []
        
        return set.sorted {
            $0.wrappedDateCreation > $1.wrappedDateCreation
        }
    }
    
    
    // MARK: - Computed properties
    //Have a label
    public var haveALabel : Bool {
        if label != nil {
            return true
        }
        return false
    }
     
    
    //How much money do they owe us
    public var totalDebut : Double {
        let sum = transactionsArray
            //Not pay and they own us
            .filter { $0.settled == false && $0.debt == true }
            .map { $0.totalBalance }
            .reduce(0, +)
        
        return sum
    }
    
    //How much money do we owe them
    public var totalOwn : Double {
        let sum = transactionsArray
            //Not pay and they own us
            .filter { $0.settled == false && $0.debt == false }
            .map { $0.totalBalance }
            .reduce(0, +)
        return sum
    }
    
    public var balance : Double {
        let sum = totalDebut - totalOwn
        return sum
    }

}

// MARK: Generated accessors for transactions
extension Contact {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}

extension Contact : Identifiable {

}
