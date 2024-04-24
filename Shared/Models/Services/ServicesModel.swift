//
//  ServicesModel.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI

struct ServicesModel {
    
    // Arrays for date selection
    static var frequency = ["Daily", "Weekly", "Biweekly", "Monthly", "Quarterly", "Semester", "Yearly"]
    static let daysOfWeek : [LocalizedStringKey] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    static let daysOfMonth = Array(1...31)
    static let months = Array(1...12)
    static let years = Array(1...31)
    
    
    
    var amout : String = ""
    
    var des : String = ""
    var expense : Bool = true
    var frecuencyIndex : Int = 0
     
    var frequencyDate : Date = Date()
    var image: Image = Image(.cromaPig)
    var name : String = ""
    var colorIndex: Int = 0
    
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




