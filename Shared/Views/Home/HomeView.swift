//
//  HomeView.swift
//  debtMe
//
//  Created by Codex on 01/06/26.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @FetchRequest(
        entity: Services.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Services.name, ascending: true)]
    ) private var services: FetchedResults<Services>

    @FetchRequest(
        entity: Transaction.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Transaction.estimatedPaymentDate, ascending: true),
            NSSortDescriptor(keyPath: \Transaction.dateCreation, ascending: false)
        ],
        predicate: NSPredicate(format: "settled == NO AND estimatedPaymentDate != nil")
    ) private var scheduledTransactions: FetchedResults<Transaction>

    @AppStorage("homeViewMode") private var viewMode: ServicesViewMode = .calendar
    @AppStorage("homeCalendarPeriod") private var calendarPeriod: CalendarPeriod = .month
    @AppStorage("homeReferenceDate") private var referenceDateTimestamp: Double = Date().timeIntervalSince1970
    @AppStorage("homeNextIncomeDayOfMonth") private var nextIncomeDayOfMonth: Int = 15
    @AppStorage("homeCalendarFromToday") private var calendarFromToday = false

    @State private var detailRange: DateInterval?
    @State private var detailTitle = ""
    @State private var paidStateVersion = 0
    #if os(iOS)
    @State private var detailSelection: HomeDetailSelection?
    #endif
    #if os(macOS)
    @State private var showInspector = false
    @State private var macOSSelectedService: Services?
    @State private var macOSSelectedTransaction: Transaction?
    #endif

    @Namespace private var namespace

    private var referenceDate: Date {
        Date(timeIntervalSince1970: referenceDateTimestamp)
    }

    private var selectedDateRange: DateInterval {
        HomeCalendarDateProvider.selectedDateRange(
            for: referenceDate,
            period: calendarPeriod,
            nextIncomeDayOfMonth: nextIncomeDayOfMonth,
            fromToday: calendarFromToday
        )
    }

    private var periodItems: [HomeCalendarItem] {
        let range = selectedDateRange
        let serviceItems = services.flatMap { service in
            service.occurrences(in: range, calendar: .current).map(HomeCalendarItem.init)
        }

        let transactionItems = scheduledTransactions.compactMap { transaction -> HomeCalendarItem? in
            guard let date = transaction.estimatedPaymentDate, contains(date, in: range) else { return nil }
            return HomeCalendarItem(transaction: transaction, date: date)
        }

        return (serviceItems + transactionItems).sorted {
            if $0.date != $1.date { return $0.date < $1.date }
            return $0.title.localizedStandardCompare($1.title) == .orderedAscending
        }
    }

    private var incomeTotal: Double {
        periodItems.filter { $0.isIncome && !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }

    private var expenseTotal: Double {
        periodItems.filter { !$0.isIncome && !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }

    private var balanceTotal: Double {
        incomeTotal - expenseTotal
    }

    private var detailItems: [HomeCalendarItem] {
        guard let detailRange else { return [] }
        return periodItems.filter { contains($0.date, in: detailRange) }
    }

    private var calendarHeaderTitle: String {
        HomeCalendarDateProvider.headerTitle(for: referenceDate, period: calendarPeriod, range: selectedDateRange)
    }

    private var weekDates: [Date] {
        HomeCalendarDateProvider.weekDates(for: referenceDate)
    }

    private var fortnightDates: [Date] {
        HomeCalendarDateProvider.dates(in: selectedDateRange)
    }

    private var monthGridDates: [Date?] {
        HomeCalendarDateProvider.monthGridDates(for: referenceDate)
    }

    private var yearMonthStarts: [Date] {
        HomeCalendarDateProvider.yearMonthStarts(for: referenceDate)
    }

    private var weekdaySymbols: [String] {
        HomeCalendarDateProvider.weekdaySymbols()
    }

    private var dateRangeLabel: String {
        HomeCalendarDateProvider.dateRangeLabel(for: selectedDateRange)
    }

    private var isShowingToday: Bool {
        selectedDateRange.contains(Date())
    }

    var body: some View {
        homeContent
            .animation(.smooth, value: viewMode)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                HomeDateNavigator(
                    viewMode: $viewMode,
                    calendarPeriod: $calendarPeriod,
                    fromToday: $calendarFromToday,
                    dateRangeLabel: dateRangeLabel,
                    isShowingToday: isShowingToday,
                    namespace: namespace,
                    onPrevious: { shiftReferenceDate(by: -1) },
                    onToday: jumpToToday,
                    onNext: { shiftReferenceDate(by: 1) }
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            #if os(iOS)
            .sheet(item: $detailSelection) { selection in
                HomeDetailSheet(title: selection.title, items: selection.items)
            }
            #endif
            #if os(macOS)
            .inspector(isPresented: $showInspector) {
                HomeInspectorView(
                    title: detailTitle.isEmpty ? calendarHeaderTitle : detailTitle,
                    items: detailItems,
                    selectedService: $macOSSelectedService,
                    selectedTransaction: $macOSSelectedTransaction
                )
            }
            #endif
            .navigationTitle("Home")
            .onReceive(NotificationCenter.default.publisher(for: ServiceOccurrencePaymentStore.didChangeNotification)) { _ in
                paidStateVersion += 1
            }
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HomeDateNavigatorTopControls(
                        viewMode: $viewMode,
                        calendarPeriod: $calendarPeriod,
                        fromToday: $calendarFromToday,
                        namespace: namespace
                    )
                }
            }
            #endif
    }

    @ViewBuilder
    private var homeContent: some View {
        ZStack {
            if viewMode == .list {
                listContent
                    .id("home-list")
                    .transition(.opacity)
                    .zIndex(1)
            }

            if viewMode == .calendar {
                calendarContent
                    .id("home-calendar")
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var listContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HomePeriodSummaryView(
                    title: calendarHeaderTitle,
                    incomeTotal: incomeTotal,
                    expenseTotal: expenseTotal,
                    balanceTotal: balanceTotal
                )
                .padding(.horizontal, 8)

                HomeListSection(items: periodItems, namespace: namespace, onSelect: openListItem, onTogglePaid: togglePaid)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 96)
        }
        .scrollContentBackground(.hidden)
        .animation(.smooth, value: periodItems.map(\.id))
        .animation(.smooth, value: paidStateVersion)
    }

    private var calendarContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeCalendarView(
                    calendarPeriod: calendarPeriod,
                    referenceDate: referenceDate,
                    headerTitle: calendarHeaderTitle,
                    incomeTotal: incomeTotal,
                    expenseTotal: expenseTotal,
                    balanceTotal: balanceTotal,
                    weekDates: weekDates,
                    fortnightDates: fortnightDates,
                    monthGridDates: monthGridDates,
                    yearMonthStarts: yearMonthStarts,
                    weekdaySymbols: weekdaySymbols,
                    periodItems: periodItems,
                    namespace: namespace,
                    onOpenDetail: openDetail
                )
                .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 96)
        }
        .scrollContentBackground(.hidden)
        .animation(.smooth, value: periodItems.map(\.id))
    }

    private func openDetail(range: DateInterval?, title: String) {
        guard let range else { return }
        detailRange = range
        detailTitle = title
        #if os(macOS)
        macOSSelectedService = nil
        macOSSelectedTransaction = nil
        showInspector = true
        #else
        detailSelection = HomeDetailSelection(title: title, range: range, items: items(in: range))
        #endif
    }

    private func openListItem(_ item: HomeCalendarItem) {
        detailRange = Calendar.current.dateInterval(of: .day, for: item.date)
        detailTitle = item.date.formatted(date: .abbreviated, time: .omitted)
        #if os(macOS)
        macOSSelectedService = item.service
        macOSSelectedTransaction = item.transaction
        showInspector = true
        #else
        if let range = detailRange {
            detailSelection = HomeDetailSelection(title: detailTitle, range: range, items: items(in: range))
        }
        #endif
    }

    private func togglePaid(_ item: HomeCalendarItem) {
        guard let paidOccurrenceID = item.paidOccurrenceID else { return }
        ServiceOccurrencePaymentStore.toggle(paidOccurrenceID)
        paidStateVersion += 1
    }

    private func shiftReferenceDate(by direction: Int) {
        if calendarPeriod == .fortnight {
            referenceDateTimestamp = HomeCalendarDateProvider.shiftedFortnightDate(
                from: referenceDate,
                direction: direction
            ).timeIntervalSince1970
            return
        }

        let component: Calendar.Component
        switch calendarPeriod {
        case .day:
            component = .day
        case .week:
            component = .weekOfYear
        case .fortnight:
            component = .day
        case .month, .untilNextIncome:
            component = .month
        case .year:
            component = .year
        }

        if let next = Calendar.current.date(byAdding: component, value: direction, to: referenceDate) {
            referenceDateTimestamp = next.timeIntervalSince1970
        }
    }

    private func jumpToToday() {
        referenceDateTimestamp = Date().timeIntervalSince1970
    }

    private func contains(_ date: Date, in range: DateInterval) -> Bool {
        date >= range.start && date < range.end
    }

    private func items(in range: DateInterval) -> [HomeCalendarItem] {
        periodItems.filter { contains($0.date, in: range) }
    }
}

#if os(iOS)
private struct HomeDetailSelection: Identifiable {
    let id: String
    let title: String
    let items: [HomeCalendarItem]

    init(title: String, range: DateInterval, items: [HomeCalendarItem]) {
        self.id = "\(range.start.timeIntervalSinceReferenceDate)-\(range.end.timeIntervalSinceReferenceDate)-\(items.map(\.id).hashValue)"
        self.title = title
        self.items = items
    }
}
#endif

private struct HomeListSection: View {
    let items: [HomeCalendarItem]
    let namespace: Namespace.ID
    let onSelect: (HomeCalendarItem) -> Void
    let onTogglePaid: (HomeCalendarItem) -> Void

    var body: some View {
        if items.isEmpty {
            HomeEmptyStateView()
                .frame(maxWidth: .infinity)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Scheduled")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)

                ForEach(items) { item in
                    HomeCalendarItemNavigationRow(item: item, namespace: namespace, usesServiceBackground: item.service != nil, onMacSelect: { onSelect(item) })
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(rowBackground(for: item), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(rowStroke(for: item), lineWidth: 1)
                        )
                        .transition(.opacity)
                        .modifier(HomePaidSwipeModifier(item: item, onTogglePaid: onTogglePaid))
                }

                Text("Swipe right on a service to mark only that day as paid. Swipe it again to mark it unpaid.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
            }
        }
    }

    private func rowBackground(for item: HomeCalendarItem) -> Color {
        if item.service != nil {
            return item.tint
        }

        return item.tint.opacity(0.12)
    }

    private func rowStroke(for item: HomeCalendarItem) -> Color {
        if item.service != nil {
            return item.tint.opacity(0.55)
        }

        return item.tint.opacity(0.18)
    }
}

private struct HomePaidSwipeModifier: ViewModifier {
    let item: HomeCalendarItem
    let onTogglePaid: (HomeCalendarItem) -> Void
    @State private var horizontalOffset: CGFloat = 0

    func body(content: Content) -> some View {
        if item.paidOccurrenceID == nil {
            content
        } else {
            content
                .offset(x: max(0, min(horizontalOffset, 82)))
                .background(alignment: .leading) {
                    Label(item.currentIsPaid ? "Mark unpaid" : "Mark paid", systemImage: item.currentIsPaid ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .frame(maxHeight: .infinity)
                        .background((item.currentIsPaid ? Color.orange : Color.green), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .opacity(horizontalOffset > 12 ? 1 : 0)
                }
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            guard abs(value.translation.width) > abs(value.translation.height) else { return }
                            horizontalOffset = max(0, value.translation.width)
                        }
                        .onEnded { value in
                            if value.translation.width > 70 {
                                onTogglePaid(item)
                            }
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                                horizontalOffset = 0
                            }
                        }
                )
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
