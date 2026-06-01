//
//  ServicesList.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI
import CoreData
#if canImport(Charts)
import Charts
#endif

enum ServicesViewMode: String, CaseIterable {
    case list = "List"
    case calendar = "Calendar"
}

enum CalendarPeriod: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case fortnight = "Fortnight"
    case month = "Month"
    case year = "Year"
    case untilNextIncome = "Until Next Income"
}

struct ServicesList: View {
  
    @State var showNewBill = false
    
    @FetchRequest(entity: ContactLabel.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ContactLabel.name, ascending: true)]) var labels: FetchedResults<ContactLabel>
    
    @FetchRequest(entity: Services.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Services.name, ascending: true)]) var services: FetchedResults<Services>
    
    @State private var cachedOccurrences: [ServiceOccurrence] = []

    // Computed property to calculate the total amount
    var totalExpenses: Double {
        cachedOccurrences.filter { $0.service.expense }.reduce(0) { $0 + $1.service.amount }
    }
    var totalIncome: Double {
        cachedOccurrences.filter { !$0.service.expense }.reduce(0) { $0 + $1.service.amount }
    }
    
    var balance: Double{
        totalIncome - totalExpenses
    }

    var periodIncome: Double {
        totalIncome
    }

    var periodExpenses: Double {
        totalExpenses
    }

    var allServices: [Services] {
        services.sorted { $0.wrappedName < $1.wrappedName }
    }

    var allExpenseServices: [Services] {
        allServices.filter { $0.expense }
    }

    var allIncomeServices: [Services] {
        allServices.filter { !$0.expense }
    }

    struct ExpenseChartPoint: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
        let category: String
    }

    
    @State var selectedTag = "All"
    
    @State var searchQuery = ""
    
    @State var startDate = Date()
    
    @State var endDate =  Date()

    @AppStorage("servicesViewMode") var viewMode: ServicesViewMode = .calendar

    @AppStorage("servicesCalendarPeriod") var calendarPeriod: CalendarPeriod = .month

    @AppStorage("servicesReferenceDate") private var referenceDateTimestamp: Double = Date().timeIntervalSince1970

    @AppStorage("servicesNextIncomeDayOfMonth") private var nextIncomeDayOfMonth: Int = 15

    @State private var previousCalendarPeriod: CalendarPeriod = .month
    @State private var previousViewMode: ServicesViewMode = .list

    @State private var showDetailSheet = false
    @State private var detailRange: DateInterval?
    @State private var detailTitle = ""
    @State private var showAllEntriesSheet = false
    #if os(macOS)
    @State private var inspectorDate: Date?
    @State private var showInspector = false
    @State private var macOSSelectedService: Services?
    #endif
    private let largeValueThreshold = 100_000.0
    
    @State var sortedMode : sortModeServices = .amountDes
    
    var filteredServices : [Services] {
        let sortedServices: [Services]
        
        switch sortedMode {
        case .alfabethAsc :
            sortedServices = services.sorted{
                $0.name ?? "" < $1.name ?? ""
            }
        case .alfabethDes:
            sortedServices = services.sorted{
                $0.name ?? "" > $1.name ?? ""
            }
        case .amountAsc:
            sortedServices = services.sorted{
                $0.wrappedAmount  < $1.wrappedAmount
            }
        case .amountDes:
            sortedServices = services.sorted{
                $0.wrappedAmount > $1.wrappedAmount
            }
        }
        
        let filteredByTag: [Services]
         
         if selectedTag == "All" {
             // No tag selected, use all contacts
             filteredByTag = sortedServices
         } else {
             // Filter contacts based on the selected tag
             filteredByTag = sortedServices.filter { service in
                 service.label?.wrappedName == selectedTag
             }
         }
        
        if searchQuery.isEmpty {
            return filteredByTag
        } else {
            // Further filter contacts based on the search query
            return filteredByTag.filter { contact in
                contact.name?.localizedCaseInsensitiveContains(searchQuery) == true
            }
        }
        
    }

    var selectedDateRange: DateInterval {
        let calendar = Calendar.current
        switch calendarPeriod {
        case .day:
            let start = Calendar.current.startOfDay(for: referenceDate)
            let end = Calendar.current.date(byAdding: .day, value: 1, to: start)?.addingTimeInterval(-1) ?? referenceDate
            return DateInterval(start: start, end: end)
        case .week:
            return calendar.dateInterval(of: .weekOfYear, for: referenceDate) ?? DateInterval(start: referenceDate, end: referenceDate)
        case .fortnight:
            return fortnightRange(for: referenceDate, calendar: calendar)
        case .month:
            return calendar.dateInterval(of: .month, for: referenceDate) ?? DateInterval(start: referenceDate, end: referenceDate)
        case .year:
            return calendar.dateInterval(of: .year, for: referenceDate) ?? DateInterval(start: referenceDate, end: referenceDate)
        case .untilNextIncome:
            return untilNextIncomeRange(from: Date(), incomeDayOfMonth: nextIncomeDayOfMonth, calendar: calendar)
        }
    }

    private var nextIncomeDate: Date {
        nextIncomeDate(from: Date(), incomeDayOfMonth: nextIncomeDayOfMonth, calendar: .current)
    }

    private var nextIncomeLabel: String {
        nextIncomeDate.formatted(.dateTime.day().month(.abbreviated).year())
    }

    private func nextIncomeDate(from now: Date, incomeDayOfMonth: Int, calendar: Calendar) -> Date {
        let start = calendar.startOfDay(for: now)
        let clampedIncomeDay = max(1, min(31, incomeDayOfMonth))

        func dateForIncomeDay(in monthStart: Date) -> Date {
            let year = calendar.component(.year, from: monthStart)
            let month = calendar.component(.month, from: monthStart)
            let safeDay: Int
            if let daysRange = calendar.range(of: .day, in: .month, for: monthStart) {
                safeDay = min(clampedIncomeDay, daysRange.count)
            } else {
                safeDay = clampedIncomeDay
            }
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

    private func untilNextIncomeRange(from now: Date, incomeDayOfMonth: Int, calendar: Calendar) -> DateInterval {
        let start = calendar.startOfDay(for: now)
        let nextIncomeDate = nextIncomeDate(from: start, incomeDayOfMonth: incomeDayOfMonth, calendar: calendar)

        let end = calendar.date(byAdding: .day, value: -1, to: nextIncomeDate) ?? start
        return DateInterval(start: start, end: max(start, end))
    }

    private func fortnightRange(for date: Date, calendar: Calendar) -> DateInterval {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let year = comps.year ?? calendar.component(.year, from: date)
        let month = comps.month ?? calendar.component(.month, from: date)
        let day = comps.day ?? calendar.component(.day, from: date)

        let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? date
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30

        if day <= 15 {
            let start = monthStart
            let endDay = min(15, daysInMonth)
            let end = calendar.date(from: DateComponents(year: year, month: month, day: endDay)) ?? monthStart
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end))?.addingTimeInterval(-1) ?? end
            return DateInterval(start: calendar.startOfDay(for: start), end: endOfDay)
        } else {
            let start = calendar.date(from: DateComponents(year: year, month: month, day: 16)) ?? monthStart
            let end = calendar.date(from: DateComponents(year: year, month: month, day: daysInMonth)) ?? monthStart
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end))?.addingTimeInterval(-1) ?? end
            return DateInterval(start: calendar.startOfDay(for: start), end: endOfDay)
        }
    }

    var referenceDate: Date {
        Date(timeIntervalSince1970: referenceDateTimestamp)
    }

    var referenceDateBinding: Binding<Date> {
        Binding(
            get: { referenceDate },
            set: { referenceDateTimestamp = $0.timeIntervalSince1970 }
        )
    }

    var dateRangeLabel: String {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: selectedDateRange.start, to: selectedDateRange.end)
    }


    var expenseTotalsByDay: [Date: Double] {
        let calendar = Calendar.current
        return cachedOccurrences.reduce(into: [:]) { partial, occurrence in
            guard occurrence.service.expense else { return }
            let day = calendar.startOfDay(for: occurrence.date)
            partial[day, default: 0] += occurrence.service.amount
        }
    }

    var incomeTotalsByDay: [Date: Double] {
        let calendar = Calendar.current
        return cachedOccurrences.reduce(into: [:]) { partial, occurrence in
            guard !occurrence.service.expense else { return }
            let day = calendar.startOfDay(for: occurrence.date)
            partial[day, default: 0] += occurrence.service.amount
        }
    }

    var expenseTotalsByMonth: [Date: Double] {
        let calendar = Calendar.current
        return cachedOccurrences.reduce(into: [:]) { partial, occurrence in
            guard occurrence.service.expense else { return }
            let components = calendar.dateComponents([.year, .month], from: occurrence.date)
            let month = calendar.date(from: components) ?? occurrence.date
            partial[month, default: 0] += occurrence.service.amount
        }
    }

    var incomeTotalsByMonth: [Date: Double] {
        let calendar = Calendar.current
        return cachedOccurrences.reduce(into: [:]) { partial, occurrence in
            guard !occurrence.service.expense else { return }
            let components = calendar.dateComponents([.year, .month], from: occurrence.date)
            let month = calendar.date(from: components) ?? occurrence.date
            partial[month, default: 0] += occurrence.service.amount
        }
    }

    var weekDates: [Date] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .weekOfYear, for: referenceDate) ?? DateInterval(start: referenceDate, end: referenceDate)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }
    }

    var monthGridDates: [Date?] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: referenceDate),
              let daysRange = calendar.range(of: .day, in: .month, for: interval.start) else {
            return []
        }
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let leadingEmpty = (firstWeekday - calendar.firstWeekday + 7) % 7
        let padding = (0..<leadingEmpty).map { _ in Optional<Date>.none }
        let dates = daysRange.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: interval.start)
        }
        let totalCells = padding.count + dates.count
        let trailingEmpty = (7 - totalCells % 7) % 7
        let trailingPadding = (0..<trailingEmpty).map { _ in Optional<Date>.none }
        return padding + dates + trailingPadding
    }

    var yearMonthStarts: [Date] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .year, for: referenceDate) else { return [] }
        return (0..<12).compactMap { monthOffset in
            calendar.date(byAdding: .month, value: monthOffset, to: interval.start)
        }
    }

    var monthGridWeeksCount: Int {
        max(1, monthGridDates.count / 7)
    }

    private var calendarDayCellHeightCompact: CGFloat { 96 }
    private var calendarHeaderHeight: CGFloat { 24 }
    private var calendarCellCornerRadius: CGFloat { 12 }
    private var calendarCardCornerRadius: CGFloat { 18 }

    var monthGridHeight: CGFloat {
        let rowHeight = calendarHeaderHeight + 4 + calendarDayCellHeightCompact
        let spacing: CGFloat = 8
        let rows = CGFloat(weekdaySymbols.count)
        return rows * rowHeight + max(0, rows - 1) * spacing
    }

    private var macOSMonthCalendarHeight: CGFloat {
        let titleHeight: CGFloat = 72
        let weekdayHeaderHeight: CGFloat = 18
        let spacing: CGFloat = 8
        let rows = CGFloat(monthGridWeeksCount)
        let gridHeight = rows * calendarDayCellHeightCompact + max(0, rows - 1) * spacing
        return titleHeight + spacing + weekdayHeaderHeight + spacing + gridHeight
    }

    var yearGridHeight: CGFloat {
        let rows: CGFloat = 4
        let rowHeight: CGFloat = 76
        let spacing: CGFloat = 12
        return rows * rowHeight + (rows - 1) * spacing
    }

    var detailOccurrences: [ServiceOccurrence] {
        guard let range = detailRange else { return [] }
        return cachedOccurrences
            .filter { range.contains($0.date) }
            .sorted { $0.date < $1.date }
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("summaryServicesSelectd") var summarySelectd: summaryServicesMenu = .balance
    @AppStorage("ShowServicesSummary") var ShowSummary = true

    var weekdaySymbols: [String] {
        let calendar = Calendar.current
        let symbols = calendar.weekdaySymbols
        let startIndex = max(0, calendar.firstWeekday - 1)
        return Array(symbols[startIndex...] + symbols[..<startIndex])
    }

    var calendarView: some View {
        let monthColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
        let weekColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

        return VStack(alignment: .leading, spacing: 12) {
            if isMacOS {
                if calendarPeriod != .month {
                    calendarHeaderCard
                }
            } else {
                calendarHeaderCard
            }
            switch calendarPeriod {
            case .day:
                dayDetailCard(for: referenceDate)
            case .week:
                ForEach(weekDates, id: \.self) { date in
                    weekRow(for: date)
                }
            case .fortnight:
                LazyVGrid(columns: weekColumns, spacing: 8) {
                    ForEach(fortnightDates, id: \.self) { date in
                        dayCell(for: date, compact: true)
                    }
                }
            case .month:
                #if os(macOS)
                macOSMonthCalendar
                #else
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { row, symbol in
                        VStack(alignment: .leading, spacing: 4) {
                            weekdayHeaderCell(symbol: symbol)
                                .frame(height: calendarHeaderHeight)
                            MonthRowScroll(
                                rowIndex: row,
                                weeksCount: monthGridWeeksCount,
                                monthGridDates: monthGridDates,
                                dayColumnWidth: 60,
                                dayCellHeight: calendarDayCellHeightCompact,
                                stackedFraction: 0.8
                            ) { date in
                                dayCell(for: date, compact: true)
                            }
                        }
                    }
                }
                .frame(minHeight: monthGridHeight)
                #endif
            case .year:
                LazyVGrid(columns: monthColumns, spacing: 12) {
                    ForEach(yearMonthStarts, id: \.self) { date in
                        monthCell(for: date)
                    }
                }
                .frame(minHeight: yearGridHeight)
                .fixedSize(horizontal: false, vertical: true)
            case .untilNextIncome:
                EmptyView()
            }
        }
    }

    private var isMacOS: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }

    private var calendarHeaderTitle: String {
        switch calendarPeriod {
        case .month:
            return referenceDate.formatted(.dateTime.month(.wide).year())
        case .year:
            return referenceDate.formatted(.dateTime.year())
        case .untilNextIncome:
            return "Until Next Income"
        default:
            return dateRangeLabel
        }
    }

    private var calendarHeaderBalance: Double {
        let range = selectedDateRange
        let expenses = cachedOccurrences.filter { range.contains($0.date) && $0.service.expense }.reduce(0) { $0 + $1.service.amount }
        let incomes = cachedOccurrences.filter { range.contains($0.date) && !$0.service.expense }.reduce(0) { $0 + $1.service.amount }
        return incomes - expenses
    }

    private var calendarHeaderCard: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(calendarHeaderTitle)
                .font(.headline.weight(.semibold))
                .multilineTextAlignment(.center)
            Text(calendarHeaderBalance.toCurrencyString())
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }
        
    var body: some View {
        let listContent = List {
            #if os(macOS)
            let shouldShowSummary = ShowSummary && viewMode != .calendar
            #else
            let shouldShowSummary = ShowSummary
            #endif
            if shouldShowSummary {
                Section {
                    summaryHeader
                }
            }

            if viewMode == .list {
                ForEach(cachedOccurrences) { occurrence in
                    serviceRow(for: occurrence)
                        .listRowBackground(occurrence.service.wrappedColor)
                }
                .onDelete { offsets in
                    deleteOccurrences(at: offsets, in: cachedOccurrences)
                }
            } else {
                Section {
                    calendarView
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }

        return listContent
        .safeAreaInset(edge: .bottom, spacing: 0) {
            #if os(iOS) || os(visionOS)
            floatingDateNavigatorIOS
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            #elseif os(macOS)
            floatingDateNavigator
            #else
            EmptyView()
            #endif
        }
        .toolbar{
            #if os(macOS)
            ToolbarItem(placement: .automatic) {
                SearchTextField(searchQuery: $searchQuery)
            }
            
            #endif

            ToolbarItem(placement: .automatic) {
                Button {
                    withAnimation(.snappy) {
                        viewMode = (viewMode == .calendar) ? .list : .calendar
                    }
                } label: {
                    Label(
                        viewMode == .calendar ? "List" : "Calendar",
                        systemImage: viewMode == .calendar ? "list.bullet" : "calendar"
                    )
                    .appToolbarLabel()
                }
            }
            
            ToolbarItem(placement: .primaryAction ){
                Button(action:{
                    showNewBill.toggle()
                }){
                    Label("Add", systemImage: "plus.circle.fill")
                        .appToolbarLabel()
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }
            
            ToolbarItem(placement: .automatic) {
                Menu {
                    Picker("Vista", selection: $viewMode) {
                        ForEach(ServicesViewMode.allCases, id: \.self) { option in
                            Text(LocalizedStringKey(option.rawValue))
                                .tag(option)
                        }
                    }
                    Divider()
                    Divider()
                    Picker("Resumen", selection: $summarySelectd) {
                        ForEach(summaryServicesMenu.allCases, id:\.self ){ option in
                            Text(LocalizedStringKey(option.rawValue))
                                .tag(option)
                        }
                    }
                    Divider()
                    Button("Ver todo") {
                        showAllEntriesSheet = true
                    }
                } label: {
                    Label("Config", systemImage: "slider.horizontal.3")
                        .appToolbarLabel()
                        .foregroundColor(.gray)
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Menu {
                    Label("Sort alphabetically", systemImage: "arrow.up.and.down.text.horizontal")
                    .appToolbarLabel()
                    Button(action: {
                        sortedMode = .alfabethAsc
                    }) {
                        Label("Ascending A-Z", systemImage: "platter.filled.top.and.arrow.up.iphone")
                    }
                    Button(action: {
                        sortedMode = .alfabethDes
                    }) {
                        Label("Descending Z-A", systemImage: "platter.filled.bottom.and.arrow.down.iphone")
                    }
                    Divider()
                    
                    Label("Sort by Amount", systemImage: "arrow.up.and.down.text.horizontal")
                    
                    .appToolbarLabel()
                    Button(action: {
                        sortedMode = .amountAsc
                    }) {
                        Label("Lower First", systemImage: "platter.filled.top.and.arrow.up.iphone")
                    }
                    Button(action: {
                        sortedMode = .amountDes
                    }) {
                        Label("Higher First", systemImage: "platter.filled.bottom.and.arrow.down.iphone")
                    }
                    Divider()
                    
                    Label("Tags", systemImage: "tag")
                    
                    .appToolbarLabel()
                    Picker(selection: $selectedTag, label: Text("Filter by tag")) {
                        Text("All").tag("All")
                        ForEach(labels){ label in
                            if !label.labelForService {
                                Text(label.wrappedName).tag(label.wrappedName)
                            }
                            
                        }
                    }
                    
                } label: {
                    Label("Orden/Filtro", systemImage: "line.horizontal.3.decrease.circle.fill")
                        .appToolbarLabel()
                        .foregroundStyle(.secondary)
                }
            }
        }
        .sheet(isPresented: $showNewBill, content: {
            ServicesForm()
        })
        .sheet(isPresented: $showDetailSheet) {
            NavigationStack {
                List {
                    if detailOccurrences.isEmpty {
                        Text("Sin gastos en este periodo")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(detailOccurrences) { occurrence in
                            NavigationLink(destination: ServiceDetailView(service: occurrence.service)) {
                                ServiceRow(
                                    BgColor: occurrence.service.wrappedColor,
                                    ServiceName: occurrence.service.wrappedName,
                                    Amount: occurrence.service.amount.toCurrencyString(),
                                    frequency: occurrence.service.frecuencyString,
                                    limitDate: occurrence.date.formatted(date: .abbreviated, time: .omitted),
                                    image: occurrence.service.image,
                                    expense: occurrence.service.expense
                                )
                            }
                            .listRowBackground(occurrence.service.wrappedColor)
                        }
                    }
                }
                .navigationTitle(detailTitle)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .onAppear {
                    print("ServicesList detail sheet -> title: \(detailTitle), items: \(detailOccurrences.count)")
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAllEntriesSheet) {
            NavigationStack {
                List {
                    Section(header: Text("Income")) {
                        ForEach(allIncomeServices) { service in
                            NavigationLink(destination: ServiceDetailView(service: service)) {
                                ServiceRow(
                                    BgColor: service.wrappedColor,
                                    ServiceName: service.wrappedName,
                                    Amount: service.amount.toCurrencyString(),
                                    frequency: service.frecuencyString,
                                    limitDate: service.frequencyDate.formatted(date: .abbreviated, time: .omitted),
                                    image: service.image,
                                    expense: service.expense
                                )
                            }
                            .listRowBackground(service.wrappedColor)
                        }
                    }
                    Section(header: Text("Expenses")) {
                        ForEach(allExpenseServices) { service in
                            NavigationLink(destination: ServiceDetailView(service: service)) {
                                ServiceRow(
                                    BgColor: service.wrappedColor,
                                    ServiceName: service.wrappedName,
                                    Amount: service.amount.toCurrencyString(),
                                    frequency: service.frecuencyString,
                                    limitDate: service.frequencyDate.formatted(date: .abbreviated, time: .omitted),
                                    image: service.image,
                                    expense: service.expense
                                )
                            }
                            .listRowBackground(service.wrappedColor)
                        }
                    }
                }
                .navigationTitle("Todos")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        #if os(iOS)
        .navigationTitle("Services")
        .searchable(text: $searchQuery)
        #endif
        #if os(macOS)
        .navigationTitle("Services")
        #endif
        .onAppear(perform: updateCachedOccurrences)
        .onChange(of: referenceDateTimestamp) { updateCachedOccurrences() }
        .onChange(of: calendarPeriod) { oldValue, newValue in
            if newValue == .untilNextIncome, oldValue != .untilNextIncome {
                previousCalendarPeriod = oldValue
                previousViewMode = viewMode
                viewMode = .list
            } else if oldValue == .untilNextIncome, newValue != .untilNextIncome {
                viewMode = previousViewMode
            }
            updateCachedOccurrences()
        }
        .onChange(of: viewMode) { updateCachedOccurrences() }
        .onChange(of: selectedTag) { updateCachedOccurrences() }
        .onChange(of: searchQuery) { updateCachedOccurrences() }
        .onChange(of: sortedMode) { updateCachedOccurrences() }
        .onChange(of: services.count) { updateCachedOccurrences() }
        #if os(macOS)
        .inspector(isPresented: $showInspector) {
            macOSInspectorContent
        }
        #endif
    }

    private func dayCell(for date: Date, compact: Bool = false) -> some View {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let isToday = calendar.isDateInToday(date)
        let dayKey = calendar.startOfDay(for: date)
        let expenseTotal = expenseTotalsByDay[dayKey] ?? 0
        let incomeTotal = incomeTotalsByDay[dayKey] ?? 0
        let balanceTotal = incomeTotal - expenseTotal
        let isLarge = max(abs(expenseTotal), abs(incomeTotal), abs(balanceTotal)) >= largeValueThreshold
        let titleFont: Font = compact ? .caption2 : .caption
        let summaryFont: Font = compact ? .caption2 : .caption
        let cellHeight: CGFloat = compact ? calendarDayCellHeightCompact : 72
        let markers = dayMarkerServices(for: date)
        let glowColor = markers.first?.wrappedColor ?? .clear
        let hasMarkers = !markers.isEmpty

        return VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text("\(day)")
                    .font(titleFont)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
                Spacer(minLength: 0)
                if isToday {
                    Text("Today")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.thinMaterial, in: Capsule())
                }
            }
            if isLarge {
                pieSummary(expenseTotal: expenseTotal, incomeTotal: incomeTotal)
            } else {
                calendarSummaryLines(expenseTotal: expenseTotal, incomeTotal: incomeTotal, balanceTotal: balanceTotal, font: summaryFont)
            }
            if !markers.isEmpty {
                dayMarkersGrid(services: markers)
            }
        }
        .frame(maxWidth: .infinity, minHeight: cellHeight, maxHeight: cellHeight, alignment: .leading)
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: calendarCellCornerRadius, style: .continuous)
                .fill(Color.secondary.opacity(0.12))

            if viewMode == .calendar, hasMarkers {
                RoundedRectangle(cornerRadius: calendarCellCornerRadius, style: .continuous)
                    .fill(glowColor.opacity(0.14))
                    .blur(radius: 14)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: calendarCellCornerRadius, style: .continuous)
                .stroke(
                    isToday ? Color.accentColor.opacity(0.9) : (viewMode == .calendar && hasMarkers ? glowColor.opacity(0.75) : .clear),
                    lineWidth: isToday ? 2 : 1.5
                )
        )
        .shadow(color: viewMode == .calendar && hasMarkers ? glowColor.opacity(0.25) : .clear, radius: 10, x: 0, y: 3)
        .contentShape(RoundedRectangle(cornerRadius: calendarCellCornerRadius, style: .continuous))
        .onTapGesture {
            #if os(macOS)
            inspectorDate = date
            showInspector = true
            #else
            openDetail(range: calendar.dateInterval(of: .day, for: date), title: date.formatted(date: .abbreviated, time: .omitted))
            #endif
        }
    }

    private func dayDetailCard(for date: Date) -> some View {
        let calendar = Calendar.current
        let range = calendar.dateInterval(of: .day, for: date)
        let occurrences = cachedOccurrences
            .filter { range?.contains($0.date) == true }
            .sorted { $0.date < $1.date }

        let incomes = occurrences.filter { !$0.service.expense }
        let expenses = occurrences.filter { $0.service.expense }

        let dayKey = calendar.startOfDay(for: date)
        let expenseTotal = expenseTotalsByDay[dayKey] ?? 0
        let incomeTotal = incomeTotalsByDay[dayKey] ?? 0
        let balanceTotal = incomeTotal - expenseTotal

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(date.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                    .font(.headline.weight(.semibold))
                Spacer()
                Text(balanceTotal.toCurrencyString())
                    .font(.title2.weight(.bold))
            }

            VStack(alignment: .leading, spacing: 6) {
                if !incomes.isEmpty {
                    Text("Income")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach(incomes.prefix(4)) { occ in
                        HStack(spacing: 8) {
                            dayMarker(for: occ.service, size: 18)
                            Text(occ.service.wrappedName)
                                .lineLimit(1)
                            Spacer()
                            Text(occ.service.amount.toCurrencyString())
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.blue)
                        }
                        .font(.callout)
                    }
                }

                if !expenses.isEmpty {
                    Text("Expenses")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.top, incomes.isEmpty ? 0 : 6)
                    ForEach(expenses.prefix(4)) { occ in
                        HStack(spacing: 8) {
                            dayMarker(for: occ.service, size: 18)
                            Text(occ.service.wrappedName)
                                .lineLimit(1)
                            Spacer()
                            Text("-" + occ.service.amount.toCurrencyString())
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.red)
                        }
                        .font(.callout)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: calendarCardCornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: calendarCardCornerRadius, style: .continuous))
        .onTapGesture {
            #if os(macOS)
            inspectorDate = date
            macOSSelectedService = nil
            showInspector = true
            #else
            openDetail(range: range, title: date.formatted(date: .abbreviated, time: .omitted))
            #endif
        }
    }

    private func monthCell(for date: Date) -> some View {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let monthStart = calendar.date(from: components) ?? date
        let expenseTotal = expenseTotalsByMonth[monthStart] ?? 0
        let incomeTotal = incomeTotalsByMonth[monthStart] ?? 0
        let balanceTotal = incomeTotal - expenseTotal
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        return VStack(alignment: .leading, spacing: 6) {
            Text(formatter.string(from: monthStart))
                .font(.caption2)
                .fontWeight(.semibold)
            monthSummary(expenseTotal: expenseTotal, incomeTotal: incomeTotal, balanceTotal: balanceTotal)
        }
        .frame(maxWidth: .infinity, minHeight: 76, maxHeight: 76, alignment: .leading)
        .padding(8)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: calendarCellCornerRadius, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            openDetail(range: calendar.dateInterval(of: .month, for: monthStart), title: formatter.string(from: monthStart))
        }
    }

    @ViewBuilder
    private func calendarSummaryLines(expenseTotal: Double, incomeTotal: Double, balanceTotal: Double, font: Font) -> some View {
        if viewMode == .calendar {
            if incomeTotal > 0 {
                Text(incomeTotal.toCompactCurrencyString())
                    .font(font)
                    .foregroundColor(.blue)
            } else {
                Text(" ")
                    .font(font)
                    .foregroundStyle(.clear)
            }
            if expenseTotal > 0 {
                Text("-" + expenseTotal.toCompactCurrencyString())
                    .font(font)
                    .foregroundColor(.red)
            } else {
                Text(" ")
                    .font(font)
                    .foregroundStyle(.clear)
            }
        } else {
            switch summarySelectd {
            case .expense:
                if expenseTotal > 0 {
                    Text("-" + expenseTotal.toCompactCurrencyString())
                        .font(font)
                        .foregroundColor(.red)
                } else {
                    Text(" ")
                        .font(font)
                        .foregroundStyle(.clear)
                }
            case .income:
                if incomeTotal > 0 {
                    Text(incomeTotal.toCompactCurrencyString())
                        .font(font)
                        .foregroundColor(.blue)
                } else {
                    Text(" ")
                        .font(font)
                        .foregroundStyle(.clear)
                }
            case .balance:
                if balanceTotal != 0 {
                    Text(balanceTotal.toCompactCurrencyString())
                        .font(font)
                        .foregroundStyle(balanceTotal >= 0 ? Color.primary : Color.red)
                } else {
                    Text(" ")
                        .font(font)
                        .foregroundStyle(.clear)
                }
            case .all:
                if incomeTotal > 0 {
                    Text(incomeTotal.toCompactCurrencyString())
                        .font(font)
                        .foregroundColor(.blue)
                } else {
                    Text(" ")
                        .font(font)
                        .foregroundStyle(.clear)
                }
                if expenseTotal > 0 {
                    Text("-" + expenseTotal.toCompactCurrencyString())
                        .font(font)
                        .foregroundColor(.red)
                } else {
                    Text(" ")
                        .font(font)
                        .foregroundStyle(.clear)
                }
            }
        }
    }

    private func weekRow(for date: Date) -> some View {
        let calendar = Calendar.current
        let dayKey = calendar.startOfDay(for: date)
        let expenseTotal = expenseTotalsByDay[dayKey] ?? 0
        let incomeTotal = incomeTotalsByDay[dayKey] ?? 0
        let balanceTotal = incomeTotal - expenseTotal
        let isLarge = max(abs(expenseTotal), abs(incomeTotal), abs(balanceTotal)) >= largeValueThreshold
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        let markers = dayMarkerServices(for: date)
        let glowColor = markers.first?.wrappedColor ?? .clear
        let hasMarkers = !markers.isEmpty

        return HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(formatter.string(from: date))
                    .font(.footnote)
                    .fontWeight(.semibold)
                if isLarge {
                    pieSummary(expenseTotal: expenseTotal, incomeTotal: incomeTotal)
                } else {
                    calendarSummaryLines(expenseTotal: expenseTotal, incomeTotal: incomeTotal, balanceTotal: balanceTotal, font: .footnote)
                }
                if hasMarkers {
                    dayMarkersGrid(services: markers)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72, alignment: .leading)
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: calendarCellCornerRadius, style: .continuous)
                .fill(Color.secondary.opacity(0.08))

            if viewMode == .calendar, hasMarkers {
                RoundedRectangle(cornerRadius: calendarCellCornerRadius, style: .continuous)
                    .fill(glowColor.opacity(0.14))
                    .blur(radius: 14)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: calendarCellCornerRadius, style: .continuous)
                .stroke(viewMode == .calendar && hasMarkers ? glowColor.opacity(0.75) : .clear, lineWidth: 1.5)
        )
        .shadow(color: viewMode == .calendar && hasMarkers ? glowColor.opacity(0.25) : .clear, radius: 10, x: 0, y: 3)
        .clipShape(RoundedRectangle(cornerRadius: calendarCellCornerRadius, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            openDetail(range: calendar.dateInterval(of: .day, for: date), title: formatter.string(from: date))
        }
    }

    private func openDetail(range: DateInterval?, title: String) {
        if let range {
            detailRange = range
            detailTitle = title
            showDetailSheet = true
        }
    }

    private func pieSummary(expenseTotal: Double, incomeTotal: Double) -> some View {
        let expenseValue = max(expenseTotal, 0)
        let incomeValue = max(incomeTotal, 0)
        return PieChartView(values: [expenseValue, incomeValue], colors: [.red, .blue])
            .frame(width: 30, height: 30)
            .overlay(
                Circle()
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
            .accessibilityLabel(Text("Pie chart"))
    }

    @ViewBuilder
    private func monthSummary(expenseTotal: Double, incomeTotal: Double, balanceTotal: Double) -> some View {
        let expenseValue = max(expenseTotal, 0)
        let incomeValue = max(incomeTotal, 0)
        let total = expenseValue + incomeValue

        if total > 0 {
            HStack(alignment: .center, spacing: 6) {
                pieSummary(expenseTotal: expenseValue, incomeTotal: incomeValue)
                VStack(alignment: .leading, spacing: 2) {
                    monthLegendRow(
                        label: "Income",
                        amount: incomeValue,
                        percent: incomeValue / total,
                        color: .blue
                    )
                    monthLegendRow(
                        label: "Expenses",
                        amount: expenseValue,
                        percent: expenseValue / total,
                        color: .red
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            calendarSummaryLines(expenseTotal: expenseTotal, incomeTotal: incomeTotal, balanceTotal: balanceTotal, font: .caption2)
        }
    }

    private func monthLegendRow(label: String, amount: Double, percent: Double, color: Color) -> some View {
        let percentText = String(format: "%.0f%%", percent * 100)
        return HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(LocalizedStringKey(label))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(amount.toCompactCurrencyString())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(percentText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(.secondary)
        }
        .font(.caption2)
    }

    var summaryHeader: some View {
        let isNextIncomeRange = calendarPeriod == .untilNextIncome
        let summaryTitle = isNextIncomeRange ? "Due Before Next Income" : "Balance"
        let summaryAmount = isNextIncomeRange ? (periodExpenses - periodIncome) : balance

        return VStack(alignment: .leading, spacing: 12) {
            Text(summaryTitle)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(summaryAmount.toCurrencyString())
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(summaryAmount >= 0 ? Color.primary : Color.red)
            expenseChart
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)
                        Text(LocalizedStringKey("Income"))
                        Spacer()
                        Text(periodIncome.toCompactCurrencyString())
                    }
                    HStack {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                        Text(LocalizedStringKey("Expenses"))
                        Spacer()
                        Text("-" + periodExpenses.toCompactCurrencyString())
                    }
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    var expenseChart: some View {
        #if os(macOS)
        EmptyView()
        #else
        #if canImport(Charts)
        if #available(iOS 16.0, macOS 13.0, visionOS 1.0, *) {
            Chart(expenseChartData) { point in
                if point.category == "Profit" {
                    LineMark(
                        x: .value("Period", point.label),
                        y: .value("Profit", point.value)
                    )
                    .foregroundStyle(.orange)
                    .interpolationMethod(.catmullRom)
                } else {
                    BarMark(
                        x: .value("Period", point.label),
                        y: .value("Expenses", point.value)
                    )
                    .foregroundStyle(point.category == "Income" ? .blue : .red)
                    .position(by: .value("Category", point.category))
                    .cornerRadius(4)
                }
            }
            .frame(height: 160)
            .chartYScale(domain: 0...max(1, expenseChartMax))
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 6))
            }
        } else {
            EmptyView()
        }
        #else
        EmptyView()
        #endif
        #endif
    }

    var expenseChartData: [ExpenseChartPoint] {
        let calendar = Calendar.current
        let expenses = cachedOccurrences.filter { $0.service.expense }
        let incomes = cachedOccurrences.filter { !$0.service.expense }

        switch calendarPeriod {
        case .day:
            let day = calendar.startOfDay(for: referenceDate)
            let expenseTotal = expenses.filter { calendar.isDate($0.date, inSameDayAs: day) }.reduce(0) { $0 + $1.service.amount }
            let incomeTotal = incomes.filter { calendar.isDate($0.date, inSameDayAs: day) }.reduce(0) { $0 + $1.service.amount }
            let profitTotal = incomeTotal - expenseTotal
            return [
                ExpenseChartPoint(label: "Today", value: expenseTotal, category: "Expenses"),
                ExpenseChartPoint(label: "Today", value: incomeTotal, category: "Income"),
                ExpenseChartPoint(label: "Today", value: profitTotal, category: "Profit")
            ]
        case .week:
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return weekDates.map { date in
                let key = calendar.startOfDay(for: date)
                let expenseTotal = expenseTotalsByDay[key] ?? 0
                let incomeTotal = incomeTotalsByDay[key] ?? 0
                let profitTotal = incomeTotal - expenseTotal
                return [
                    ExpenseChartPoint(label: formatter.string(from: date), value: expenseTotal, category: "Expenses"),
                    ExpenseChartPoint(label: formatter.string(from: date), value: incomeTotal, category: "Income"),
                    ExpenseChartPoint(label: formatter.string(from: date), value: profitTotal, category: "Profit")
                ]
            }
            .flatMap { $0 }
        case .fortnight:
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            return fortnightDates.map { date in
                let key = calendar.startOfDay(for: date)
                let expenseTotal = expenseTotalsByDay[key] ?? 0
                let incomeTotal = incomeTotalsByDay[key] ?? 0
                let profitTotal = incomeTotal - expenseTotal
                return [
                    ExpenseChartPoint(label: formatter.string(from: date), value: expenseTotal, category: "Expenses"),
                    ExpenseChartPoint(label: formatter.string(from: date), value: incomeTotal, category: "Income"),
                    ExpenseChartPoint(label: formatter.string(from: date), value: profitTotal, category: "Profit")
                ]
            }
            .flatMap { $0 }
        case .month:
            var expenseTotals: [Int: Double] = [:]
            var incomeTotals: [Int: Double] = [:]
            for occurrence in expenses {
                let week = calendar.component(.weekOfMonth, from: occurrence.date)
                expenseTotals[week, default: 0] += occurrence.service.amount
            }
            for occurrence in incomes {
                let week = calendar.component(.weekOfMonth, from: occurrence.date)
                incomeTotals[week, default: 0] += occurrence.service.amount
            }
            let maxWeek = max(expenseTotals.keys.max() ?? 1, incomeTotals.keys.max() ?? 1)
            let weeks = (1...maxWeek)
            return weeks.flatMap { week -> [ExpenseChartPoint] in
                let incomeTotal = incomeTotals[week, default: 0]
                let expenseTotal = expenseTotals[week, default: 0]
                let profitTotal = incomeTotal - expenseTotal
                return [
                    ExpenseChartPoint(label: "S\(week)", value: expenseTotal, category: "Expenses"),
                    ExpenseChartPoint(label: "S\(week)", value: incomeTotal, category: "Income"),
                    ExpenseChartPoint(label: "S\(week)", value: profitTotal, category: "Profit")
                ]
            }
        case .year:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            var expenseTotals: [Int: Double] = [:]
            var incomeTotals: [Int: Double] = [:]
            for occurrence in expenses {
                let month = calendar.component(.month, from: occurrence.date)
                expenseTotals[month, default: 0] += occurrence.service.amount
            }
            for occurrence in incomes {
                let month = calendar.component(.month, from: occurrence.date)
                incomeTotals[month, default: 0] += occurrence.service.amount
            }
            return (1...12).flatMap { month in
                let monthDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: referenceDate), month: month, day: 1)) ?? referenceDate
                let label = formatter.string(from: monthDate)
                let incomeTotal = incomeTotals[month, default: 0]
                let expenseTotal = expenseTotals[month, default: 0]
                let profitTotal = incomeTotal - expenseTotal
                return [
                    ExpenseChartPoint(label: label, value: expenseTotal, category: "Expenses"),
                    ExpenseChartPoint(label: label, value: incomeTotal, category: "Income"),
                    ExpenseChartPoint(label: label, value: profitTotal, category: "Profit")
                ]
            }
        case .untilNextIncome:
            let expenseTotal = expenses.reduce(0) { $0 + $1.service.amount }
            let incomeTotal = incomes.reduce(0) { $0 + $1.service.amount }
            let profitTotal = incomeTotal - expenseTotal
            return [
                ExpenseChartPoint(label: "Period", value: expenseTotal, category: "Expenses"),
                ExpenseChartPoint(label: "Period", value: incomeTotal, category: "Income"),
                ExpenseChartPoint(label: "Period", value: profitTotal, category: "Profit")
            ]
        }
    }

    private var fortnightDates: [Date] {
        let calendar = Calendar.current
        let range = selectedDateRange
        var current = calendar.startOfDay(for: range.start)
        let end = calendar.startOfDay(for: range.end)
        var out: [Date] = []
        while current <= end {
            out.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current.addingTimeInterval(86_400)
        }
        return out
    }

    var expenseChartMax: Double {
        let maxValue = expenseChartData.map { abs($0.value) }.max() ?? 1
        return maxValue
    }

    private func shiftReferenceDate(by direction: Int) {
        let calendar = Calendar.current
        let component: Calendar.Component
        switch calendarPeriod {
        case .day:
            component = .day
        case .week:
            component = .weekOfYear
        case .fortnight:
            shiftReferenceDateByFortnight(direction: direction, calendar: calendar)
            return
        case .month:
            component = .month
        case .year:
            component = .year
        case .untilNextIncome:
            component = .month
        }
        if let next = calendar.date(byAdding: component, value: direction, to: referenceDate) {
            referenceDateTimestamp = next.timeIntervalSince1970
        }
    }

    private var isShowingToday: Bool {
        selectedDateRange.contains(Date())
    }

    private func jumpToToday() {
        referenceDateTimestamp = Date().timeIntervalSince1970
    }

    private func shiftReferenceDateByFortnight(direction: Int, calendar: Calendar) {
        let comps = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        let year = comps.year ?? calendar.component(.year, from: referenceDate)
        let month = comps.month ?? calendar.component(.month, from: referenceDate)
        let day = comps.day ?? calendar.component(.day, from: referenceDate)

        let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? referenceDate
        let isFirstHalf = day <= 15

        let newDate: Date
        if direction > 0 {
            if isFirstHalf {
                newDate = calendar.date(from: DateComponents(year: year, month: month, day: 16)) ?? referenceDate
            } else {
                let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? referenceDate
                let nextComps = calendar.dateComponents([.year, .month], from: nextMonthStart)
                newDate = calendar.date(from: DateComponents(year: nextComps.year, month: nextComps.month, day: 1)) ?? referenceDate
            }
        } else {
            if isFirstHalf {
                let prevMonthStart = calendar.date(byAdding: .month, value: -1, to: monthStart) ?? referenceDate
                let prevComps = calendar.dateComponents([.year, .month], from: prevMonthStart)
                let daysInPrevMonth = calendar.range(of: .day, in: .month, for: prevMonthStart)?.count ?? 30
                let startDay = min(16, daysInPrevMonth)
                newDate = calendar.date(from: DateComponents(year: prevComps.year, month: prevComps.month, day: startDay)) ?? referenceDate
            } else {
                newDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? referenceDate
            }
        }

        referenceDateTimestamp = newDate.timeIntervalSince1970
    }

    #if os(macOS)
    var floatingDateNavigator: some View {
        HStack(spacing: 8) {
            Picker("Period", selection: $calendarPeriod) {
                ForEach(CalendarPeriod.allCases, id: \.self) { option in
                    Text(LocalizedStringKey(option.rawValue))
                        .tag(option)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)

            if calendarPeriod == .untilNextIncome {
                Button {
                    calendarPeriod = previousCalendarPeriod
                    viewMode = previousViewMode
                } label: {
                    Image(systemName: "arrow.uturn.left")
                }
                .buttonStyle(.plain)

                Text("Next income \(nextIncomeLabel)")
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule())
            } else {
                Button {
                    shiftReferenceDate(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)

                Button {
                    jumpToToday()
                } label: {
                    Text("Today")
                }
                .buttonStyle(.plain)
                .disabled(isShowingToday)

                Text(dateRangeLabel)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Button {
                    shiftReferenceDate(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.bottom, 12)
        .shadow(radius: 6, y: 2)
    }
    #endif

    #if os(iOS) || os(visionOS)
    var floatingDateNavigatorIOS: some View {
        return GlassEffectContainer {
            HStack {
                Picker("Period", selection: $calendarPeriod) {
                    ForEach(CalendarPeriod.allCases, id: \.self) { option in
                        Text(LocalizedStringKey(option.rawValue))
                            .tag(option)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .layoutPriority(1)
                .glassEffect(.regular.interactive(), in: .capsule)

                if calendarPeriod == .untilNextIncome {
                    Button {
                        calendarPeriod = previousCalendarPeriod
                        viewMode = previousViewMode
                    } label: {
                        Image(systemName: "arrow.uturn.left")
                            .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .glassEffect(.regular.interactive(), in: .capsule)

                    Text("Next income \(nextIncomeLabel)")
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .glassEffect(.regular.interactive(), in: .capsule)
                } else {
                    Button {
                        shiftReferenceDate(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .glassEffect(.regular.interactive(), in: .capsule)

                    Button {
                        jumpToToday()
                    } label: {
                        Text("Today")
                            .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .disabled(isShowingToday)
                    .glassEffect(.regular.interactive(), in: .capsule)

                    Text(dateRangeLabel)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .glassEffect(.regular.interactive(), in: .capsule)

                    Button {
                        shiftReferenceDate(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .glassEffect(.regular.interactive(), in: .capsule)
                }
            }
        }
    }
    #endif

    private func updateCachedOccurrences() {
        let range = selectedDateRange
        cachedOccurrences = filteredServices
            .flatMap { $0.occurrences(in: range, calendar: .current) }
            .sorted { $0.date < $1.date }
    }

    private func deleteOccurrences(at offsets: IndexSet, in occurrences: [ServiceOccurrence]) {
        var deletedIds = Set<NSManagedObjectID>()
        for index in offsets {
            let service = occurrences[index].service
            if deletedIds.insert(service.objectID).inserted {
                viewContext.delete(service)
            }
        }
        do {
            try viewContext.save()
        } catch {
            // Handle the error appropriately in a real app
            print("Error saving context after delete: \(error.localizedDescription)")
        }
    }

    private func weekdayHeaderCell(symbol: String) -> some View {
        Text(symbol)
            .font(.caption2)
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 8)
            .frame(minHeight: calendarHeaderHeight, alignment: .leading)
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: calendarCellCornerRadius, style: .continuous))
    }

    #if os(macOS)
    var macOSMonthCalendar: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
        let monthTitle = referenceDate.formatted(.dateTime.month(.wide).year())
        let calendar = Calendar.current
        let monthRange = calendar.dateInterval(of: .month, for: referenceDate)
        let monthOccurrences = monthRange.map { range in
            cachedOccurrences.filter { range.contains($0.date) }
        } ?? []
        let monthIncome = monthOccurrences.filter { !$0.service.expense }.reduce(0) { $0 + $1.service.amount }
        let monthExpense = monthOccurrences.filter { $0.service.expense }.reduce(0) { $0 + $1.service.amount }
        let monthBalance = monthIncome - monthExpense

        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .center, spacing: 6) {
                Text(monthTitle)
                    .font(.headline.weight(.semibold))
                Text(monthBalance.toCurrencyString())
                    .font(.largeTitle.weight(.bold))
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(monthGridDates.enumerated()), id: \.offset) { _, date in
                    if let date {
                        macOSDayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: calendarDayCellHeightCompact)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: calendarCardCornerRadius, style: .continuous))
        .frame(minHeight: macOSMonthCalendarHeight)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func macOSDayCell(for date: Date) -> some View {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let isToday = calendar.isDateInToday(date)
        let markers = dayMarkerServices(for: date)
        let glowColor = markers.first?.wrappedColor ?? .clear
        let hasMarkers = !markers.isEmpty

        return VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text("\(day)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
                if isToday {
                    Text("Today")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.thinMaterial, in: Capsule())
                }
            }
            if hasMarkers {
                macOSDayMarkersGrid(services: markers)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: calendarDayCellHeightCompact, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: calendarCellCornerRadius, style: .continuous)
                .fill(Color.secondary.opacity(0.08))

            if hasMarkers {
                RoundedRectangle(cornerRadius: calendarCellCornerRadius, style: .continuous)
                    .fill(glowColor.opacity(0.18))
                    .blur(radius: 14)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: calendarCellCornerRadius, style: .continuous)
                .stroke(
                    isToday ? Color.accentColor.opacity(0.9) : (hasMarkers ? glowColor.opacity(0.75) : .clear),
                    lineWidth: isToday ? 2 : 1.5
                )
        )
        .shadow(color: hasMarkers ? glowColor.opacity(0.45) : .clear, radius: 10, x: 0, y: 3)
        .contentShape(RoundedRectangle(cornerRadius: calendarCellCornerRadius, style: .continuous))
        .onTapGesture {
            inspectorDate = date
            macOSSelectedService = nil
            showInspector = true
        }
    }
    #endif

    @ViewBuilder
    private func serviceRow(for occurrence: ServiceOccurrence) -> some View {
        #if os(macOS)
        Button {
            macOSSelectedService = occurrence.service
            showInspector = true
        } label: {
            ServiceRow(
                BgColor: occurrence.service.wrappedColor,
                ServiceName: occurrence.service.wrappedName,
                Amount: occurrence.service.amount.toCurrencyString(),
                frequency: occurrence.service.frecuencyString,
                limitDate: occurrence.date.formatted(date: .abbreviated, time: .omitted),
                image: occurrence.service.image,
                expense: occurrence.service.expense,
                useAdaptiveText: true
            )
        }
        .buttonStyle(.plain)
        #else
        NavigationLink(destination: ServiceDetailView(service: occurrence.service) ) {
            ServiceRow(
                BgColor: occurrence.service.wrappedColor,
                ServiceName: occurrence.service.wrappedName,
                Amount: occurrence.service.amount.toCurrencyString(),
                frequency: occurrence.service.frecuencyString,
                limitDate: occurrence.date.formatted(date: .abbreviated, time: .omitted),
                image: occurrence.service.image,
                expense: occurrence.service.expense
            )
        }
        #endif
    }

    private struct RowScrollMetrics: Equatable {
        let offset: CGFloat
        let contentWidth: CGFloat
    }

    private struct RowScrollMetricsKey: PreferenceKey {
        static var defaultValue = RowScrollMetrics(offset: 0, contentWidth: 0)
        static func reduce(value: inout RowScrollMetrics, nextValue: () -> RowScrollMetrics) {
            value = nextValue()
        }
    }

    private struct MonthRowScroll<DayCell: View>: View {
        let rowIndex: Int
        let weeksCount: Int
        let monthGridDates: [Date?]
        let dayColumnWidth: CGFloat
        let dayCellHeight: CGFloat
        let stackedFraction: CGFloat
        let dayCell: (Date) -> DayCell

        @State private var offset: CGFloat = 0
        @State private var contentWidth: CGFloat = 0
        @State private var containerWidth: CGFloat = 0

        private var isAtEnd: Bool {
            let overflow = max(0, contentWidth - containerWidth)
            guard overflow > 0 else { return false }
            let threshold = dayColumnWidth * 0.8
            return -offset >= overflow - threshold
        }

        var body: some View {
            GeometryReader { proxy in
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        let stackedSpacing = -dayColumnWidth * stackedFraction
                        let spacing = isAtEnd ? stackedSpacing : 8
                        HStack(spacing: spacing) {
                            ForEach(0..<weeksCount, id: \.self) { column in
                                let index = column * 7 + rowIndex
                                if index < monthGridDates.count, let date = monthGridDates[index] {
                                    dayCell(date)
                                        .frame(width: dayColumnWidth)
                                        .id(column)
                                } else {
                                    Color.clear
                                        .frame(width: dayColumnWidth, height: dayCellHeight)
                                        .id(column)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, dayColumnWidth * stackedFraction)
                        .background(
                            GeometryReader { contentProxy in
                                Color.clear
                                    .preference(
                                        key: RowScrollMetricsKey.self,
                                        value: RowScrollMetrics(
                                            offset: contentProxy.frame(in: .named("MonthRowScroll\(rowIndex)")).minX,
                                            contentWidth: contentProxy.size.width
                                        )
                                    )
                            }
                        )
                        .frame(height: dayCellHeight + 16)
                        .fixedSize(horizontal: true, vertical: true)
                        .padding(.trailing, 4)
                    }
                    .coordinateSpace(name: "MonthRowScroll\(rowIndex)")
                    .onPreferenceChange(RowScrollMetricsKey.self) { metrics in
                        offset = metrics.offset
                        contentWidth = metrics.contentWidth
                    }
                    .onAppear {
                        containerWidth = proxy.size.width
                        if weeksCount > 0 {
                            scrollProxy.scrollTo(weeksCount - 1, anchor: .trailing)
                        }
                    }
                    .onChange(of: proxy.size.width) { newValue in
                        containerWidth = newValue
                    }
                }
            }
            .frame(height: dayCellHeight + 16)
        }
    }

    private func dayMarkerServices(for date: Date) -> [Services] {
        let calendar = Calendar.current
        let occurrencesForDay = cachedOccurrences
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted {
                let leftAmount = abs($0.service.amount)
                let rightAmount = abs($1.service.amount)
                if leftAmount != rightAmount { return leftAmount > rightAmount }

                let leftName = $0.service.wrappedName.localizedCaseInsensitiveCompare($1.service.wrappedName)
                if leftName != .orderedSame { return leftName == .orderedAscending }

                return $0.service.objectID.uriRepresentation().absoluteString < $1.service.objectID.uriRepresentation().absoluteString
            }

        var seen = Set<NSManagedObjectID>()
        var result: [Services] = []
        result.reserveCapacity(6)

        for occurrence in occurrencesForDay {
            let service = occurrence.service
            guard seen.insert(service.objectID).inserted else { continue }
            result.append(service)
            if result.count == 6 { break }
        }

        return result
    }

    @ViewBuilder
    private func dayMarkersGrid(services: [Services]) -> some View {
        let columns = Array(repeating: GridItem(.fixed(14), spacing: 4), count: 3)
        LazyVGrid(columns: columns, alignment: .leading, spacing: 4) {
            ForEach(services, id: \.objectID) { service in
                dayMarker(for: service, size: 14)
            }
        }
    }

    @ViewBuilder
    private func macOSDayMarkersGrid(services: [Services]) -> some View {
        let columns = Array(repeating: GridItem(.fixed(22), spacing: 6), count: 3)
        LazyVGrid(columns: columns, alignment: .center, spacing: 6) {
            ForEach(services, id: \.objectID) { service in
                dayMarker(for: service, size: 22)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    #if os(macOS)
    @ViewBuilder
    var macOSInspectorContent: some View {
        if let selectedService = macOSSelectedService {
            NavigationStack {
                ServiceDetailView(service: selectedService)
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button {
                                macOSSelectedService = nil
                            } label: {
                                Label("Back", systemImage: "chevron.left")
                            }
                        }
                    }
            }
        } else {
            let calendar = Calendar.current
            let date = inspectorDate ?? referenceDate
            let occurrences = cachedOccurrences
                .filter { calendar.isDate($0.date, inSameDayAs: date) }
                .sorted { $0.date < $1.date }
            let incomeTotal = occurrences.filter { !$0.service.expense }.reduce(0) { $0 + $1.service.amount }
            let expenseTotal = occurrences.filter { $0.service.expense }.reduce(0) { $0 + $1.service.amount }
            let dayBalance = incomeTotal - expenseTotal

            VStack(alignment: .leading, spacing: 12) {
                Text(date.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                    .font(.headline)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Day balance")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(dayBalance.toCurrencyString())
                        .font(.title2.weight(.bold))
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Income")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(incomeTotal.toCurrencyString())
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Expenses")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text("-" + expenseTotal.toCurrencyString())
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.red)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                if occurrences.isEmpty {
                    Text("No services due")
                } else {
                    ForEach(occurrences) { occurrence in
                        Button {
                            macOSSelectedService = occurrence.service
                            showInspector = true
                        } label: {
                            ServiceRow(
                                BgColor: occurrence.service.wrappedColor,
                                ServiceName: occurrence.service.wrappedName,
                                Amount: occurrence.service.amount.toCurrencyString(),
                                frequency: occurrence.service.frecuencyString,
                                limitDate: occurrence.date.formatted(date: .abbreviated, time: .omitted),
                                image: occurrence.service.image,
                                expense: occurrence.service.expense,
                                useAdaptiveText: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
    #endif

    @ViewBuilder
    private func dayMarker(for service: Services, size: CGFloat) -> some View {
        let cornerRadius = max(8, size * 0.32)
        ServiceIconView(photoData: service.image, backgroundColor: service.wrappedColor, cornerRadius: cornerRadius)
            .frame(width: size, height: size)
            .shadow(color: service.wrappedColor.opacity(0.45), radius: max(2, size * 0.35))
    }
}

private struct PieChartView: View {
    let values: [Double]
    let colors: [Color]

    var body: some View {
        let total = values.reduce(0, +)
        return ZStack {
            ForEach(values.indices, id: \.self) { index in
                let startAngle = angle(at: index, total: total)
                let endAngle = angle(at: index + 1, total: total)
                PieSlice(startAngle: startAngle, endAngle: endAngle)
                    .fill(colors[index % colors.count])
            }
        }
    }

    private func angle(at index: Int, total: Double) -> Angle {
        let slice = values.prefix(index).reduce(0, +)
        let ratio = total == 0 ? 0 : slice / total
        return .degrees(ratio * 360.0 - 90.0)
    }
}

private struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationStack{
        ServicesList()
    }
}
