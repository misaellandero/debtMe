//
//  ServicesModel.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI

enum ServiceLifecycleStatus: Int16, CaseIterable, Identifiable {
    case active = 0
    case canceled = 1
    case archived = 2

    var id: Int16 { rawValue }

    var localizedTitle: LocalizedStringResource {
        switch self {
        case .active: "Active"
        case .canceled: "Canceled"
        case .archived: "Archived"
        }
    }
}

struct ServicesModel {
    
    // Arrays for date selection
    static var frequency = ["Daily", "Weekly", "Biweekly", "Monthly", "Quarterly", "Semester", "Yearly", "One time", "Last day of month"]
    static var businessDayAdjustments = ["Exact date", "Previous business day", "Next business day"]
    static let daysOfWeek : [LocalizedStringKey] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    static let daysOfMonth = Array(1...31)
    static let months = Array(1...12)
    static let years = Array(1...31)

    static func frequencyKey(for index: Int) -> String {
        switch index {
        case 0: "Daily"
        case 1: "Weekly"
        case 2: "Biweekly"
        case 3: "Monthly"
        case 4: "Quarterly"
        case 5: "Semester"
        case 6: "Yearly"
        case 7: "One time"
        case 8: "Last day of month"
        default: "Select Frequency"
        }
    }

    static func frequencyTitle(for index: Int) -> LocalizedStringKey {
        LocalizedStringKey(frequencyKey(for: index))
    }

    static func localizedFrequencyTitle(for index: Int) -> String {
        switch index {
        case 0: String(localized: "Daily")
        case 1: String(localized: "Weekly")
        case 2: String(localized: "Biweekly")
        case 3: String(localized: "Monthly")
        case 4: String(localized: "Quarterly")
        case 5: String(localized: "Semester")
        case 6: String(localized: "Yearly")
        case 7: String(localized: "One time")
        case 8: String(localized: "Last day of month")
        default: String(localized: "Select Frequency")
        }
    }

    static func businessDayAdjustmentTitle(for index: Int) -> LocalizedStringResource {
        switch index {
        case 0: "Exact date"
        case 1: "Previous business day"
        case 2: "Next business day"
        default: "Exact date"
        }
    }
    
    
    
    var amout : String = ""
    var label : String = ""
    var des : String = ""
    var expense : Bool = true
    var frecuencyIndex : Int = 0
     
    var frequencyDate : Date = Date()
    var hasEndDate: Bool = false
    var endDate: Date = Date()
    var businessDayAdjustmentIndex: Int = 0
    var image: Data?
    var name : String = ""
    var colorIndex: Int = 0
    var statusIndex: Int = Int(ServiceLifecycleStatus.active.rawValue)
    
    var color : Color {
        AppColorsModel.colors[colorIndex].color
    }
    
    var amountNumber : Double {
        let namount = Double(amout) ?? 0.0
        return namount
    }
    
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
    
    
    let dateFormatter = DateFormatter()
    
    var dayName: String? {
        
            dateFormatter.dateFormat = "EEEE" // "EEEE" gives full name of the day (e.g., Monday)
            return dateFormatter.string(from: frequencyDate)
         
        }
        
        var monthName: String? {
            dateFormatter.dateFormat = "MMMM" // "MMMM" gives full name of the month (e.g., February)
            return dateFormatter.string(from: frequencyDate)
        }
}
