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
    @NSManaged public var business_day_adjustment: Int16
    @NSManaged public var des: String?
    @NSManaged public var expense: Bool
    @NSManaged public var frequency: Int16
    @NSManaged public var frequency_date: Date?
    @NSManaged public var recurrence_end_date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var color: Int16
    @NSManaged public var label: ContactLabel?
    @NSManaged public var amountUpdates: NSSet?
    
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

    public var recurrenceEndDate: Date? {
        recurrence_end_date
    }
    
    //Wrapped Amount
    public var wrappedAmount : Double {
        if expense {
            return -amount
        } else {
            return amount
        }
    }

    public enum BusinessDayAdjustment: Int16, CaseIterable {
        case exact = 0
        case previousBusinessDay = 1
        case nextBusinessDay = 2
    }

    public var businessDayAdjustment: BusinessDayAdjustment {
        get { BusinessDayAdjustment(rawValue: business_day_adjustment) ?? .exact }
        set { business_day_adjustment = newValue.rawValue }
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
        case 1 : //"Weekly":
            return NSLocalizedString(ServicesModel.frequency[Int(frequency)], comment: "") + NSLocalizedString(" Fee each ", comment: "") +  (dayName ?? "")
        case 2 : //"Biweekly":
            return NSLocalizedString(ServicesModel.frequency[Int(frequency)], comment: "") + NSLocalizedString(" Fee on 15 and last day", comment: "")
        case 3,4,5:   //"Monthly", "Quarterly", "Semester":
            return NSLocalizedString(ServicesModel.frequency[Int(frequency)], comment: "") + NSLocalizedString(" Fee each ", comment: "") +  String(frequencyDay)
        case 6: //"Yearly":
            return NSLocalizedString(ServicesModel.frequency[Int(frequency)], comment: "") + NSLocalizedString(" Fee each ", comment: "") + NSLocalizedString("\(frequencyDay)", comment: "") + NSLocalizedString(" of ", comment: "") + NSLocalizedString("\(monthName ?? "")", comment: "")
        case 7: //One time payment
            return NSLocalizedString(ServicesModel.frequency[Int(frequency)], comment: "") + NSLocalizedString(" Fee ", comment: "") + String(frequencyDate.formatted(date: .abbreviated, time: .omitted))
        case 8: //Last day of month
            return NSLocalizedString(ServicesModel.frequency[Int(frequency)], comment: "") + NSLocalizedString(" Fee", comment: "")
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
    
    var today : Date {
        Date()
    }
    
    //TODO : Do the calculations
    //Pay Before calculation
    public var payBefore : Date {
        let calendar = Calendar.current
        
        switch frequency {
        case 0 ://"Daily"
            return today//Today
        case 1: //"Weekly"
            return Date()
        case 2: //"Biweekly"
            return Date()
        case 3: //"Monthly"
            return Date()
        case 4: //"Quarterly"
            return Date()
            case 5: //"Semester"
            return Date()
        case 6: //"Yearly"
            return Date()
        case 7: //One time payment
            return frequencyDate
        default: //"Daily"
            return Date() //Today
        }
    }
    
    //Pay Before string
    public var payBeforeString : String {
        payBefore.formatted(date: .abbreviated, time: .omitted)
    }
    // MARK: - Array AmountUpdates
    public var amountUpdatesArray: [AmountUpdate] {
        let set = amountUpdates as? Set<AmountUpdate> ?? []
        
        return set.sorted {
            $0.wrappedUpdateDate > $1.wrappedUpdateDate
        }
    }

}

// MARK: Generated accessors for amountUpdates
extension Services {

    @objc(addAmountUpdatesObject:)
    @NSManaged public func addToAmountUpdates(_ value: AmountUpdate)

    @objc(removeAmountUpdatesObject:)
    @NSManaged public func removeFromAmountUpdates(_ value: AmountUpdate)

    @objc(addAmountUpdates:)
    @NSManaged public func addToAmountUpdates(_ values: NSSet)

    @objc(removeAmountUpdates:)
    @NSManaged public func removeFromAmountUpdates(_ values: NSSet)

}

extension Services : Identifiable {

}

struct ServiceOccurrence: Identifiable {
    let id: String
    let service: Services
    let date: Date
}

extension Services {
    func occurrences(in range: DateInterval, calendar: Calendar = .current) -> [ServiceOccurrence] {
        let start = calendar.startOfDay(for: range.start)
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: range.end) ?? range.end
        var effectiveEnd = end
        if let recurrenceEndDate {
            let endLimit = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: recurrenceEndDate) ?? recurrenceEndDate
            if endLimit < start {
                return []
            }
            effectiveEnd = min(end, endLimit)
        }
        if effectiveEnd < start {
            return []
        }
        let normalizedRange = DateInterval(start: start, end: effectiveEnd)
        let anchor = calendar.startOfDay(for: frequencyDate)
        let anchorDay = calendar.component(.day, from: anchor)
        let anchorMonth = calendar.component(.month, from: anchor)
        let anchorYear = calendar.component(.year, from: anchor)

        if end < anchor {
            return []
        }

        switch frequency {
        case 0:
            return dailyOccurrences(in: normalizedRange, anchor: anchor, calendar: calendar)
        case 1:
            return weeklyOccurrences(in: normalizedRange, anchor: anchor, weekInterval: 1, calendar: calendar)
        case 2:
            return semiMonthlyOccurrences(in: normalizedRange, anchor: anchor, calendar: calendar)
        case 3:
            return monthlyOccurrences(in: normalizedRange, anchor: anchor, anchorDay: anchorDay, anchorMonth: anchorMonth, anchorYear: anchorYear, monthInterval: 1, calendar: calendar)
        case 4:
            return monthlyOccurrences(in: normalizedRange, anchor: anchor, anchorDay: anchorDay, anchorMonth: anchorMonth, anchorYear: anchorYear, monthInterval: 3, calendar: calendar)
        case 5:
            return monthlyOccurrences(in: normalizedRange, anchor: anchor, anchorDay: anchorDay, anchorMonth: anchorMonth, anchorYear: anchorYear, monthInterval: 6, calendar: calendar)
        case 6:
            return monthlyOccurrences(in: normalizedRange, anchor: anchor, anchorDay: anchorDay, anchorMonth: anchorMonth, anchorYear: anchorYear, monthInterval: 12, calendar: calendar)
        case 7:
            let adjusted = adjustedForBusinessDay(anchor, calendar: calendar)
            if normalizedRange.contains(adjusted) {
                return [ServiceOccurrence(id: occurrenceId(for: adjusted), service: self, date: adjusted)]
            }
            return []
        case 8:
            return lastDayOfMonthOccurrences(in: normalizedRange, anchor: anchor, calendar: calendar)
        default:
            return dailyOccurrences(in: normalizedRange, anchor: anchor, calendar: calendar)
        }
    }

    private func dailyOccurrences(in range: DateInterval, anchor: Date, calendar: Calendar) -> [ServiceOccurrence] {
        var dates: [ServiceOccurrence] = []
        var current = max(range.start, anchor)
        while current <= range.end {
            dates.append(ServiceOccurrence(id: occurrenceId(for: current), service: self, date: current))
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return dates
    }

    private func weeklyOccurrences(in range: DateInterval, anchor: Date, weekInterval: Int, calendar: Calendar) -> [ServiceOccurrence] {
        let weekday = calendar.component(.weekday, from: anchor)
        let searchStart = max(range.start, anchor)
        var dates: [ServiceOccurrence] = []
        var current = nextWeekday(onOrAfter: searchStart, weekday: weekday, calendar: calendar)
        let intervalDays = weekInterval * 7

        while current <= range.end {
            let diffDays = calendar.dateComponents([.day], from: anchor, to: current).day ?? 0
            if diffDays >= 0 && diffDays % intervalDays == 0 {
                let adjusted = adjustedForBusinessDay(current, calendar: calendar)
                if range.contains(adjusted) {
                    dates.append(ServiceOccurrence(id: occurrenceId(for: adjusted), service: self, date: adjusted))
                }
                guard let next = calendar.date(byAdding: .day, value: intervalDays, to: current) else { break }
                current = next
            } else {
                guard let next = calendar.date(byAdding: .day, value: 7, to: current) else { break }
                current = next
            }
        }

        return dates
    }

    private func semiMonthlyOccurrences(in range: DateInterval, anchor: Date, calendar: Calendar) -> [ServiceOccurrence] {
        let startMonth = calendar.date(from: DateComponents(year: calendar.component(.year, from: range.start), month: calendar.component(.month, from: range.start), day: 1)) ?? range.start
        let endMonth = calendar.date(from: DateComponents(year: calendar.component(.year, from: range.end), month: calendar.component(.month, from: range.end), day: 1)) ?? range.end
        let anchorMonthStart = calendar.date(from: DateComponents(year: calendar.component(.year, from: anchor), month: calendar.component(.month, from: anchor), day: 1)) ?? anchor

        var dates: [ServiceOccurrence] = []
        var monthCursor = startMonth

        while monthCursor <= endMonth {
            let monthDiff = calendar.dateComponents([.month], from: anchorMonthStart, to: monthCursor).month ?? 0
            if monthDiff >= 0 {
                let year = calendar.component(.year, from: monthCursor)
                let month = calendar.component(.month, from: monthCursor)
                if let midMonth = calendar.date(from: DateComponents(year: year, month: month, day: 15)),
                   midMonth >= anchor,
                   range.contains(midMonth) {
                    let adjusted = adjustedForBusinessDay(midMonth, calendar: calendar)
                    if range.contains(adjusted) {
                        dates.append(ServiceOccurrence(id: occurrenceId(for: adjusted), service: self, date: adjusted))
                    }
                }
                if let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
                   let daysRange = calendar.range(of: .day, in: .month, for: monthStart) {
                    let lastDay = daysRange.count
                    if let endMonthDate = calendar.date(from: DateComponents(year: year, month: month, day: lastDay)),
                       endMonthDate >= anchor,
                       range.contains(endMonthDate) {
                        let adjusted = adjustedForBusinessDay(endMonthDate, calendar: calendar)
                        if range.contains(adjusted) {
                            dates.append(ServiceOccurrence(id: occurrenceId(for: adjusted), service: self, date: adjusted))
                        }
                    }
                }
            }

            guard let next = calendar.date(byAdding: .month, value: 1, to: monthCursor) else { break }
            monthCursor = next
        }

        return dates.sorted { $0.date < $1.date }
    }

    private func monthlyOccurrences(in range: DateInterval, anchor: Date, anchorDay: Int, anchorMonth: Int, anchorYear: Int, monthInterval: Int, calendar: Calendar) -> [ServiceOccurrence] {
        let startMonth = calendar.date(from: DateComponents(year: calendar.component(.year, from: range.start), month: calendar.component(.month, from: range.start), day: 1)) ?? range.start
        let endMonth = calendar.date(from: DateComponents(year: calendar.component(.year, from: range.end), month: calendar.component(.month, from: range.end), day: 1)) ?? range.end
        let anchorMonthStart = calendar.date(from: DateComponents(year: anchorYear, month: anchorMonth, day: 1)) ?? anchor

        var dates: [ServiceOccurrence] = []
        var monthCursor = startMonth

        while monthCursor <= endMonth {
            let monthDiff = calendar.dateComponents([.month], from: anchorMonthStart, to: monthCursor).month ?? 0
            if monthDiff >= 0 && monthDiff % monthInterval == 0 {
                let year = calendar.component(.year, from: monthCursor)
                let month = calendar.component(.month, from: monthCursor)
                if let occurrenceDate = dateFor(year: year, month: month, day: anchorDay, calendar: calendar),
                   occurrenceDate >= anchor,
                   range.contains(occurrenceDate) {
                    let adjusted = adjustedForBusinessDay(occurrenceDate, calendar: calendar)
                    if range.contains(adjusted) {
                        dates.append(ServiceOccurrence(id: occurrenceId(for: adjusted), service: self, date: adjusted))
                    }
                }
            }

            guard let next = calendar.date(byAdding: .month, value: 1, to: monthCursor) else { break }
            monthCursor = next
        }

        return dates
    }

    private func lastDayOfMonthOccurrences(in range: DateInterval, anchor: Date, calendar: Calendar) -> [ServiceOccurrence] {
        let startMonth = calendar.date(from: DateComponents(year: calendar.component(.year, from: range.start), month: calendar.component(.month, from: range.start), day: 1)) ?? range.start
        let endMonth = calendar.date(from: DateComponents(year: calendar.component(.year, from: range.end), month: calendar.component(.month, from: range.end), day: 1)) ?? range.end
        let anchorMonthStart = calendar.date(from: DateComponents(year: calendar.component(.year, from: anchor), month: calendar.component(.month, from: anchor), day: 1)) ?? anchor

        var dates: [ServiceOccurrence] = []
        var monthCursor = startMonth

        while monthCursor <= endMonth {
            let monthDiff = calendar.dateComponents([.month], from: anchorMonthStart, to: monthCursor).month ?? 0
            if monthDiff >= 0 {
                let year = calendar.component(.year, from: monthCursor)
                let month = calendar.component(.month, from: monthCursor)
                if let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
                   let daysRange = calendar.range(of: .day, in: .month, for: monthStart) {
                    let lastDay = daysRange.count
                    if let occurrenceDate = calendar.date(from: DateComponents(year: year, month: month, day: lastDay)),
                       occurrenceDate >= anchor,
                       range.contains(occurrenceDate) {
                        let adjusted = adjustedForBusinessDay(occurrenceDate, calendar: calendar)
                        if range.contains(adjusted) {
                            dates.append(ServiceOccurrence(id: occurrenceId(for: adjusted), service: self, date: adjusted))
                        }
                    }
                }
            }

            guard let next = calendar.date(byAdding: .month, value: 1, to: monthCursor) else { break }
            monthCursor = next
        }

        return dates
    }

    private func dateFor(year: Int, month: Int, day: Int, calendar: Calendar) -> Date? {
        let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1))
        guard let monthDate = monthStart,
              let daysRange = calendar.range(of: .day, in: .month, for: monthDate) else {
            return nil
        }
        let clampedDay = min(day, daysRange.count)
        return calendar.date(from: DateComponents(year: year, month: month, day: clampedDay))
    }

    private func nextWeekday(onOrAfter date: Date, weekday: Int, calendar: Calendar) -> Date {
        if calendar.component(.weekday, from: date) == weekday {
            return date
        }
        let components = DateComponents(weekday: weekday)
        return calendar.nextDate(after: date, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents) ?? date
    }

    private func adjustedForBusinessDay(_ date: Date, calendar: Calendar) -> Date {
        switch businessDayAdjustment {
        case .exact:
            return date
        case .previousBusinessDay:
            return previousBusinessDay(from: date, calendar: calendar)
        case .nextBusinessDay:
            return nextBusinessDay(from: date, calendar: calendar)
        }
    }

    private func previousBusinessDay(from date: Date, calendar: Calendar) -> Date {
        var current = date
        while calendar.isDateInWeekend(current) {
            guard let next = calendar.date(byAdding: .day, value: -1, to: current) else { break }
            current = next
        }
        return current
    }

    private func nextBusinessDay(from date: Date, calendar: Calendar) -> Date {
        var current = date
        while calendar.isDateInWeekend(current) {
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return current
    }

    private func occurrenceId(for date: Date) -> String {
        let timestamp = date.timeIntervalSince1970
        return "\(wrappedId.uuidString)-\(timestamp)"
    }
}
