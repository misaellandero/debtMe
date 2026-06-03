//
//  HomeCalendarView.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import SwiftUI

struct HomeCalendarView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let calendarPeriod: CalendarPeriod
    let referenceDate: Date
    let headerTitle: String
    let incomeTotal: Double
    let expenseTotal: Double
    let balanceTotal: Double
    let weekDates: [Date]
    let fortnightDates: [Date]
    let monthGridDates: [Date?]
    let yearMonthStarts: [Date]
    let weekdaySymbols: [String]
    let periodItems: [HomeCalendarItem]
    let namespace: Namespace.ID
    let onOpenDetail: (DateInterval?, String) -> Void

    private var isCompactCalendar: Bool {
        #if os(iOS)
        horizontalSizeClass == .compact
        #else
        false
        #endif
    }

    private var calendarDayCellHeight: CGFloat {
        isCompactCalendar ? 62 : 104
    }

    private var calendarGridSpacing: CGFloat {
        isCompactCalendar ? 4 : 8
    }

    private var calendarCellCornerRadius: CGFloat {
        isCompactCalendar ? 8 : 12
    }

    private var calendarCardCornerRadius: CGFloat {
        isCompactCalendar ? 12 : 18
    }

    var body: some View {
        let monthColumns = Array(repeating: GridItem(.flexible(), spacing: isCompactCalendar ? 8 : 12), count: isCompactCalendar ? 2 : 3)
        let weekColumns = Array(repeating: GridItem(.flexible(), spacing: calendarGridSpacing), count: 7)

        VStack(alignment: .leading, spacing: isCompactCalendar ? 8 : 12) {
            HomePeriodSummaryView(
                title: headerTitle,
                incomeTotal: incomeTotal,
                expenseTotal: expenseTotal,
                balanceTotal: balanceTotal,
                isCompact: isCompactCalendar
            )

            switch calendarPeriod {
            case .day:
                HomeDayDetailCard(
                    date: referenceDate,
                    items: items(for: referenceDate),
                    cornerRadius: calendarCardCornerRadius
                )
            case .week:
                ForEach(weekDates, id: \.self) { date in
                    HomeWeekRow(
                        date: date,
                        items: items(for: date),
                        cornerRadius: calendarCellCornerRadius,
                        isCompact: isCompactCalendar,
                        namespace: namespace,
                        onOpenDetail: onOpenDetail
                    )
                }
            case .fortnight, .untilNextIncome:
                LazyVGrid(columns: weekColumns, spacing: calendarGridSpacing) {
                    ForEach(fortnightDates, id: \.self) { date in
                        dayCell(for: date)
                    }
                }
            case .month:
                VStack(alignment: .leading, spacing: calendarGridSpacing) {
                    HStack(spacing: calendarGridSpacing) {
                        ForEach(weekdaySymbols, id: \.self) { symbol in
                            Text(symbol)
                                .font(.caption2.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    LazyVGrid(columns: weekColumns, spacing: calendarGridSpacing) {
                        ForEach(Array(monthGridDates.enumerated()), id: \.offset) { _, date in
                            if let date {
                                dayCell(for: date)
                            } else {
                                Color.clear
                                    .frame(height: calendarDayCellHeight)
                            }
                        }
                    }
                }
            case .year:
                LazyVGrid(columns: monthColumns, spacing: 12) {
                    ForEach(yearMonthStarts, id: \.self) { date in
                        HomeMonthCell(
                            date: date,
                            periodItems: periodItems,
                            cornerRadius: calendarCellCornerRadius,
                            isCompact: isCompactCalendar,
                            onOpenDetail: onOpenDetail
                        )
                    }
                }
            }
        }
    }

    private func dayCell(for date: Date) -> HomeDayCell {
        HomeDayCell(
            date: date,
            items: items(for: date),
            height: calendarDayCellHeight,
            cornerRadius: calendarCellCornerRadius,
            isCompact: isCompactCalendar,
            namespace: namespace,
            onOpenDetail: onOpenDetail
        )
    }

    private func items(for date: Date) -> [HomeCalendarItem] {
        let calendar = Calendar.current
        return periodItems.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
}

private struct HomeDayCell: View {
    let date: Date
    let items: [HomeCalendarItem]
    let height: CGFloat
    let cornerRadius: CGFloat
    let isCompact: Bool
    let namespace: Namespace.ID
    let onOpenDetail: (DateInterval?, String) -> Void

    private let largeValueThreshold = 100_000.0

    var body: some View {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let isToday = calendar.isDateInToday(date)
        let income = items.filter { $0.isIncome && !$0.isPaid }.reduce(0) { $0 + $1.amount }
        let expenses = items.filter { !$0.isIncome && !$0.isPaid }.reduce(0) { $0 + $1.amount }
        let balance = income - expenses
        let isLarge = max(abs(income), abs(expenses), abs(balance)) >= largeValueThreshold
        let glowColor = items.first?.tint ?? .clear
        let hasItems = !items.isEmpty

        Button {
            onOpenDetail(calendar.dateInterval(of: .day, for: date), date.formatted(date: .abbreviated, time: .omitted))
        } label: {
            VStack(alignment: .leading, spacing: isCompact ? 2 : 4) {
                HStack(spacing: isCompact ? 4 : 8) {
                    Text("\(day)")
                        .font(.caption2.weight(.semibold))
                    Spacer(minLength: 0)
                    if isToday, isCompact {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 5, height: 5)
                    } else if isToday {
                        Text("Today")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.thinMaterial, in: Capsule())
                    }
                }

                if isCompact {
                    if hasItems {
                        Text(balance.toCompactCurrencyString())
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(balance >= 0 ? Color.blue : Color.red)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                } else if isLarge {
                    Text(balance.toCompactCurrencyString())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(balance >= 0 ? Color.blue : Color.red)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                } else {
                    HomeDaySummary(income: income, expenses: expenses)
                }

                if hasItems {
                    HomeDayMarkersGrid(
                        items: Array(items.prefix(isCompact ? 2 : 6)),
                        markerSize: isCompact ? 12 : 16,
                        columnCount: isCompact ? 2 : 3,
                        namespace: namespace
                    )
                }
            }
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .topLeading)
            .padding(isCompact ? 5 : 10)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.secondary.opacity(0.12))

                if hasItems {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(glowColor.opacity(0.14))
                        .blur(radius: 14)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(isToday ? Color.accentColor.opacity(0.9) : (hasItems ? glowColor.opacity(0.75) : .clear), lineWidth: isToday ? (isCompact ? 1.5 : 2) : 1.5)
            )
            .shadow(color: hasItems ? glowColor.opacity(0.25) : .clear, radius: isCompact ? 5 : 10, x: 0, y: 3)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct HomeWeekRow: View {
    let date: Date
    let items: [HomeCalendarItem]
    let cornerRadius: CGFloat
    let isCompact: Bool
    let namespace: Namespace.ID
    let onOpenDetail: (DateInterval?, String) -> Void

    private var title: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    var body: some View {
        let income = items.filter { $0.isIncome && !$0.isPaid }.reduce(0) { $0 + $1.amount }
        let expenses = items.filter { !$0.isIncome && !$0.isPaid }.reduce(0) { $0 + $1.amount }

        Button {
            onOpenDetail(Calendar.current.dateInterval(of: .day, for: date), title)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: isCompact ? 4 : 6) {
                    Text(title)
                        .font(.footnote.weight(.semibold))
                    HomeDaySummary(income: income, expenses: expenses)
                    if !items.isEmpty {
                        HomeDayMarkersGrid(
                            items: Array(items.prefix(isCompact ? 4 : 6)),
                            markerSize: isCompact ? 14 : 16,
                            columnCount: isCompact ? 4 : 3,
                            namespace: namespace
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: isCompact ? 64 : 78, alignment: .leading)
            .padding(isCompact ? 8 : 10)
            .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct HomeDayDetailCard: View {
    let date: Date
    let items: [HomeCalendarItem]
    let cornerRadius: CGFloat

    var body: some View {
        let income = items.filter { $0.isIncome && !$0.isPaid }.reduce(0) { $0 + $1.amount }
        let expenses = items.filter { !$0.isIncome && !$0.isPaid }.reduce(0) { $0 + $1.amount }
        let balance = income - expenses

        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(date.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                    .font(.headline.weight(.semibold))
                Spacer()
                Text(balance.toCurrencyString())
                    .font(.title2.weight(.bold))
            }

            if items.isEmpty {
                Text("No scheduled items in this day")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items.prefix(6)) { item in
                    HomeCalendarItemNavigationRow(item: item)
                }
            }
        }
        .padding(12)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

private struct HomeMonthCell: View {
    let date: Date
    let periodItems: [HomeCalendarItem]
    let cornerRadius: CGFloat
    let isCompact: Bool
    let onOpenDetail: (DateInterval?, String) -> Void

    var body: some View {
        let calendar = Calendar.current
        let range = calendar.dateInterval(of: .month, for: date)
        let items = range.map { range in periodItems.filter { $0.date >= range.start && $0.date < range.end } } ?? []
        let income = items.filter { $0.isIncome && !$0.isPaid }.reduce(0) { $0 + $1.amount }
        let expenses = items.filter { !$0.isIncome && !$0.isPaid }.reduce(0) { $0 + $1.amount }

        Button {
            onOpenDetail(range, date.formatted(.dateTime.month(.wide)))
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(date.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption2.weight(.semibold))
                HomeDaySummary(income: income, expenses: expenses)
            }
            .frame(maxWidth: .infinity, minHeight: isCompact ? 64 : 78, alignment: .leading)
            .padding(isCompact ? 6 : 8)
            .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct HomeDaySummary: View {
    let income: Double
    let expenses: Double

    var body: some View {
        Group {
            if income > 0 {
                Text(income.toCompactCurrencyString())
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .lineLimit(1)
            }
            if expenses > 0 {
                Text("-" + expenses.toCompactCurrencyString())
                    .font(.caption)
                    .foregroundStyle(.red)
                    .lineLimit(1)
            }
            if income == 0, expenses == 0 {
                Text(" ")
                    .font(.caption)
                    .foregroundStyle(.clear)
            }
        }
    }
}

private struct HomeDayMarkersGrid: View {
    let items: [HomeCalendarItem]
    var markerSize: CGFloat = 16
    var columnCount = 3
    var namespace: Namespace.ID?

    var body: some View {
        let spacing: CGFloat = markerSize <= 12 ? 2 : 4
        let columns = Array(repeating: GridItem(.fixed(markerSize), spacing: spacing), count: columnCount)

        LazyVGrid(columns: columns, alignment: .leading, spacing: spacing) {
            ForEach(items) { item in
                HomeCalendarMarker(item: item, size: markerSize, namespace: namespace)
            }
        }
    }
}
