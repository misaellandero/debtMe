//
//  HomeCalendarDateProvider.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import Foundation

enum HomeCalendarDateProvider {
    static func selectedDateRange(
        for referenceDate: Date,
        period: CalendarPeriod,
        nextIncomeDayOfMonth: Int,
        fromToday: Bool = false,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> DateInterval {
        let range: DateInterval
        switch period {
        case .day:
            let start = calendar.startOfDay(for: referenceDate)
            let end = calendar.date(byAdding: .day, value: 1, to: start)?.addingTimeInterval(-1) ?? referenceDate
            range = DateInterval(start: start, end: end)
        case .week:
            range = calendar.dateInterval(of: .weekOfYear, for: referenceDate) ?? DateInterval(start: referenceDate, end: referenceDate)
        case .fortnight:
            range = fortnightRange(for: referenceDate, calendar: calendar)
        case .month:
            range = calendar.dateInterval(of: .month, for: referenceDate) ?? DateInterval(start: referenceDate, end: referenceDate)
        case .year:
            range = calendar.dateInterval(of: .year, for: referenceDate) ?? DateInterval(start: referenceDate, end: referenceDate)
        case .untilNextIncome:
            range = untilNextIncomeRange(from: now, incomeDayOfMonth: nextIncomeDayOfMonth, calendar: calendar)
        }

        return adjustedRange(range, period: period, fromToday: fromToday, now: now, calendar: calendar)
    }

    static func headerTitle(for referenceDate: Date, period: CalendarPeriod, range: DateInterval) -> String {
        switch period {
        case .month:
            return referenceDate.formatted(.dateTime.month(.wide).year())
        case .year:
            return referenceDate.formatted(.dateTime.year())
        case .untilNextIncome:
            return "Until Next Income"
        default:
            return dateRangeLabel(for: range)
        }
    }

    static func dateRangeLabel(for range: DateInterval) -> String {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: range.start, to: range.end)
    }

    static func weekDates(for referenceDate: Date, calendar: Calendar = .current) -> [Date] {
        let interval = calendar.dateInterval(of: .weekOfYear, for: referenceDate) ?? DateInterval(start: referenceDate, end: referenceDate)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }
    }

    static func monthGridDates(for referenceDate: Date, calendar: Calendar = .current) -> [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: referenceDate),
              let daysRange = calendar.range(of: .day, in: .month, for: interval.start) else {
            return []
        }
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let leadingEmpty = (firstWeekday - calendar.firstWeekday + 7) % 7
        let padding = (0..<leadingEmpty).map { _ in Optional<Date>.none }
        let dates = daysRange.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: interval.start)
        }
        let totalCells = padding.count + dates.count
        let trailingEmpty = (7 - totalCells % 7) % 7
        return padding + dates + (0..<trailingEmpty).map { _ in Optional<Date>.none }
    }

    static func yearMonthStarts(for referenceDate: Date, calendar: Calendar = .current) -> [Date] {
        guard let interval = calendar.dateInterval(of: .year, for: referenceDate) else { return [] }
        return (0..<12).compactMap { calendar.date(byAdding: .month, value: $0, to: interval.start) }
    }

    static func weekdaySymbols(calendar: Calendar = .current) -> [String] {
        let symbols = calendar.weekdaySymbols
        let startIndex = max(0, calendar.firstWeekday - 1)
        return Array(symbols[startIndex...] + symbols[..<startIndex])
    }

    static func dates(in range: DateInterval, calendar: Calendar = .current) -> [Date] {
        var current = calendar.startOfDay(for: range.start)
        let end = calendar.startOfDay(for: range.end)
        var out: [Date] = []
        while current <= end {
            out.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current.addingTimeInterval(86_400)
        }
        return out
    }

    static func shiftedFortnightDate(from referenceDate: Date, direction: Int, calendar: Calendar = .current) -> Date {
        let comps = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        let year = comps.year ?? calendar.component(.year, from: referenceDate)
        let month = comps.month ?? calendar.component(.month, from: referenceDate)
        let day = comps.day ?? calendar.component(.day, from: referenceDate)
        let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? referenceDate
        let isFirstHalf = day <= 15

        if direction > 0 {
            if isFirstHalf {
                return calendar.date(from: DateComponents(year: year, month: month, day: 16)) ?? referenceDate
            }

            let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? referenceDate
            let nextComps = calendar.dateComponents([.year, .month], from: nextMonthStart)
            return calendar.date(from: DateComponents(year: nextComps.year, month: nextComps.month, day: 1)) ?? referenceDate
        }

        if isFirstHalf {
            let prevMonthStart = calendar.date(byAdding: .month, value: -1, to: monthStart) ?? referenceDate
            let prevComps = calendar.dateComponents([.year, .month], from: prevMonthStart)
            let daysInPrevMonth = calendar.range(of: .day, in: .month, for: prevMonthStart)?.count ?? 30
            let startDay = min(16, daysInPrevMonth)
            return calendar.date(from: DateComponents(year: prevComps.year, month: prevComps.month, day: startDay)) ?? referenceDate
        }

        return calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? referenceDate
    }

    private static func fortnightRange(for date: Date, calendar: Calendar) -> DateInterval {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let year = comps.year ?? calendar.component(.year, from: date)
        let month = comps.month ?? calendar.component(.month, from: date)
        let day = comps.day ?? calendar.component(.day, from: date)
        let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? date
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30

        if day <= 15 {
            let endDay = min(15, daysInMonth)
            let end = calendar.date(from: DateComponents(year: year, month: month, day: endDay)) ?? monthStart
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end))?.addingTimeInterval(-1) ?? end
            return DateInterval(start: calendar.startOfDay(for: monthStart), end: endOfDay)
        }

        let start = calendar.date(from: DateComponents(year: year, month: month, day: 16)) ?? monthStart
        let end = calendar.date(from: DateComponents(year: year, month: month, day: daysInMonth)) ?? monthStart
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end))?.addingTimeInterval(-1) ?? end
        return DateInterval(start: calendar.startOfDay(for: start), end: endOfDay)
    }

    private static func untilNextIncomeRange(from now: Date, incomeDayOfMonth: Int, calendar: Calendar) -> DateInterval {
        let start = calendar.startOfDay(for: now)
        let nextIncomeDate = nextIncomeDate(from: start, incomeDayOfMonth: incomeDayOfMonth, calendar: calendar)
        let nextIncomeDayStart = calendar.startOfDay(for: nextIncomeDate)
        let end = calendar.date(byAdding: .day, value: 1, to: nextIncomeDayStart)?.addingTimeInterval(-1) ?? nextIncomeDayStart
        return DateInterval(start: start, end: max(start, end))
    }

    private static func adjustedRange(
        _ range: DateInterval,
        period: CalendarPeriod,
        fromToday: Bool,
        now: Date,
        calendar: Calendar
    ) -> DateInterval {
        guard fromToday, period != .day, period != .untilNextIncome else {
            return range
        }

        let today = calendar.startOfDay(for: now)
        let rangeStart = calendar.startOfDay(for: range.start)
        let rangeEnd = calendar.startOfDay(for: range.end)
        guard today >= rangeStart, today <= rangeEnd else {
            return range
        }

        return DateInterval(start: today, end: max(today, range.end))
    }

    private static func nextIncomeDate(from now: Date, incomeDayOfMonth: Int, calendar: Calendar) -> Date {
        let start = calendar.startOfDay(for: now)
        let clampedIncomeDay = max(1, min(31, incomeDayOfMonth))

        func dateForIncomeDay(in monthStart: Date) -> Date {
            let year = calendar.component(.year, from: monthStart)
            let month = calendar.component(.month, from: monthStart)
            let safeDay = min(clampedIncomeDay, calendar.range(of: .day, in: .month, for: monthStart)?.count ?? clampedIncomeDay)
            return calendar.date(from: DateComponents(year: year, month: month, day: safeDay)) ?? monthStart
        }

        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: start)) ?? start
        let candidate = dateForIncomeDay(in: currentMonthStart)
        if candidate > start {
            return candidate
        }

        let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: currentMonthStart) ?? currentMonthStart
        return dateForIncomeDay(in: nextMonthStart)
    }
}
