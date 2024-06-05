//
//  Services+CoreDataProperties.swift
//  debtMe
//
//  Created by Misael Landero on 21/02/24.
//
//

import Foundation
import CoreData
import SwiftUI

extension Services {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Services> {
        return NSFetchRequest<Services>(entityName: "Services")
    }

    @NSManaged public var amount: Double
    @NSManaged public var des: String?
    @NSManaged public var expense: Bool
    @NSManaged public var frequency: Int16
    @NSManaged public var frequency_date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var color: Int16
    @NSManaged public var label: ContactLabel?
    
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
    
    // Wrapped color
    public var wrappedColor: Color {
        AppColorsModel.colors[Int(color)].color
    }
    
    //Wrapped Frecuency Date
    public var frequencyDate : Date {
        frequency_date ??  Date()
    }
    
    // MARK: - Computed properties

    //Days and months
    var frequencyDay: Int {
        let date = frequencyDate
        let calendar = Calendar.current
        return calendar.component(.day, from: date)
    }
    var frequencyMonth: Int {
        let date = frequencyDate
        let calendar = Calendar.current
        return calendar.component(.month, from: date)
    }
    
    
    var dayName: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // "EEEE" gives full name of the day (e.g., Monday)
        return dateFormatter.string(from: frequencyDate)
        
    }
    
    var monthName: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM" // "MMMM" gives full name of the month (e.g., February)
        return dateFormatter.string(from: frequencyDate)
    }
    
    //Frecuency String
    public var frecuencyString : String {
        switch frequency {
        case 0 ://"Daily":
            return NSLocalizedString("Daily Fee", comment: "")
        case 1,2 : //"Weekly","Biweekly":
            return NSLocalizedString(ServicesModel.frequency[Int(frequency)], comment: "") + NSLocalizedString(" Fee each ", comment: "") +  (dayName ?? "")
        case 3,4,5:   //"Monthly", "Quarterly", "Semester":
            return NSLocalizedString(ServicesModel.frequency[Int(frequency)], comment: "") + NSLocalizedString(" Fee each ", comment: "") +  String(frequencyDay)
        default:
            return "Daily Fee"
        }
    }
    
    //Have a label
    public var haveALabel : Bool {
        if label != nil {
            return true
        }
        return false
    }

}

extension Services : Identifiable {

}
