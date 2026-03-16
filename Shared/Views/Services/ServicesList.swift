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
    case month = "Month"
    case year = "Year"
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

    @AppStorage("servicesViewMode") var viewMode: ServicesViewMode = .list

    @AppStorage("servicesCalendarPeriod") var calendarPeriod: CalendarPeriod = .month

    @AppStorage("servicesReferenceDate") private var referenceDateTimestamp: Double = Date().timeIntervalSince1970

    @State private var showDetailSheet = false
    @State private var detailRange: DateInterval?
    @State private var detailTitle = ""
    @State private var showAllEntriesSheet = false
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
        case .month:
            return calendar.dateInterval(of: .month, for: referenceDate) ?? DateInterval(start: referenceDate, end: referenceDate)
        case .year:
            return calendar.dateInterval(of: .year, for: referenceDate) ?? DateInterval(start: referenceDate, end: referenceDate)
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

    var monthGridHeight: CGFloat {
        let rowHeight = calendarHeaderHeight + 4 + calendarDayCellHeightCompact
        let spacing: CGFloat = 8
        let rows = CGFloat(weekdaySymbols.count)
        return rows * rowHeight + max(0, rows - 1) * spacing
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

        return VStack(alignment: .leading, spacing: 12) {
            switch calendarPeriod {
            case .day:
                dayCell(for: referenceDate, compact: false)
            case .week:
                ForEach(weekDates, id: \.self) { date in
                    weekRow(for: date)
                }
            case .month:
                let monthTitle = referenceDate.formatted(.dateTime.month(.wide).year())
                VStack(alignment: .leading, spacing: 8) {
                    Text(monthTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
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
            case .year:
                LazyVGrid(columns: monthColumns, spacing: 12) {
                    ForEach(yearMonthStarts, id: \.self) { date in
                        monthCell(for: date)
                    }
                }
                .frame(minHeight: yearGridHeight)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
        
    var body: some View {
        ZStack(alignment: .bottom) {
            List{
            if ShowSummary {
                Section {
                    summaryHeader
                }
            }
            
            if viewMode == .list {
                ForEach(cachedOccurrences) { occurrence in
                    NavigationLink(destination: ServiceDetailView(service: occurrence.service) ) {
                        ServiceRow(BgColor: occurrence.service.wrappedColor, ServiceName: occurrence.service.wrappedName, Amount: occurrence.service.amount.toCurrencyString(), frequency: occurrence.service.frecuencyString, limitDate: occurrence.date.formatted(date: .abbreviated, time: .omitted), image: occurrence.service.image, expense: occurrence.service.expense)
                    }
                    .listRowBackground(occurrence.service.wrappedColor)
                }
                .onDelete { offsets in
                    deleteOccurrences(at: offsets, in: cachedOccurrences)
                }
            } else {
                Section {
                    calendarView
                }
            }
        }
            .layoutPriority(1)
        }
        #if os(iOS)
        .safeAreaInset(edge: .bottom) {
            if viewMode == .calendar {
                floatingDateNavigatorIOS
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
        }
        #endif
        .toolbar{
            #if os(macOS)
            ToolbarItem(placement: .automatic) {
                SearchTextField(searchQuery: $searchQuery)
            }
            
            #endif
            
            ToolbarItem(placement: .primaryAction ){
                Button(action:{
                    showNewBill.toggle()
                }){
                    Label("Add", systemImage: "plus.circle.fill") .font(Font.system(.headline, design: .rounded).weight(.black))
                }
                .buttonStyle(BorderedProminentButtonStyle())
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
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                        .foregroundColor(.gray)
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Menu {
                    Label("Sort alphabetically", systemImage: "arrow.up.and.down.text.horizontal")
                    .font(Font.system(.headline, design: .rounded).weight(.black))
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
                    
                    .font(Font.system(.headline, design: .rounded).weight(.black))
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
                    
                    .font(Font.system(.headline, design: .rounded).weight(.black))
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
                        .font(Font.system(.headline, design: .rounded).weight(.black))
                        .foregroundColor(.gray)
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
        .navigationTitle("Bills")
        .searchable(text: $searchQuery)
        #endif
        #if os(macOS)
        .navigationTitle("Bills")
        #endif
        .onAppear(perform: updateCachedOccurrences)
        .onChange(of: referenceDateTimestamp) { updateCachedOccurrences() }
        .onChange(of: calendarPeriod) { updateCachedOccurrences() }
        .onChange(of: viewMode) { updateCachedOccurrences() }
        .onChange(of: selectedTag) { updateCachedOccurrences() }
        .onChange(of: searchQuery) { updateCachedOccurrences() }
        .onChange(of: sortedMode) { updateCachedOccurrences() }
        .onChange(of: services.count) { updateCachedOccurrences() }
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

        return VStack(alignment: .leading, spacing: 4) {
            Text("\(day)")
                .font(titleFont)
                .fontWeight(.semibold)
                .foregroundStyle(isToday ? Color.accentColor : Color.primary)
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
        .background(Color.secondary.opacity(0.12), in: Capsule())
        .contentShape(Capsule())
        .onTapGesture {
            openDetail(range: calendar.dateInterval(of: .day, for: date), title: date.formatted(date: .abbreviated, time: .omitted))
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
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
            }
        }
        .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72, alignment: .leading)
        .padding(8)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Balance")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(balance.toCurrencyString())
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(balance >= 0 ? Color.primary : Color.red)
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
        #if canImport(Charts)
        if #available(iOS 16.0, macOS 13.0, visionOS 1.0, *) {
            Chart(expenseChartData) { point in
                if point.category == "Profit" {
                    LineMark(
                        x: .value("Periodo", point.label),
                        y: .value("Profit", point.value)
                    )
                    .foregroundStyle(.orange)
                    .interpolationMethod(.catmullRom)
                } else {
                    BarMark(
                        x: .value("Periodo", point.label),
                        y: .value("Gastos", point.value)
                    )
                    .foregroundStyle(point.category == "Income" ? .blue : .red)
                    .position(by: .value("Categoria", point.category))
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
                ExpenseChartPoint(label: "Hoy", value: expenseTotal, category: "Expenses"),
                ExpenseChartPoint(label: "Hoy", value: incomeTotal, category: "Income"),
                ExpenseChartPoint(label: "Hoy", value: profitTotal, category: "Profit")
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
        }
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
        case .month:
            component = .month
        case .year:
            component = .year
        }
        if let next = calendar.date(byAdding: component, value: direction, to: referenceDate) {
            referenceDateTimestamp = next.timeIntervalSince1970
        }
    }

    #if os(macOS)
    var floatingDateNavigator: some View {
        HStack(spacing: 8) {
            Picker("Periodo", selection: $calendarPeriod) {
                ForEach(CalendarPeriod.allCases, id: \.self) { option in
                    Text(LocalizedStringKey(option.rawValue))
                        .tag(option)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)

            Button {
                shiftReferenceDate(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.plain)

            DatePicker(
                "",
                selection: referenceDateBinding,
                displayedComponents: .date
            )
            .labelsHidden()
            .datePickerStyle(.compact)

            Button {
                shiftReferenceDate(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.bottom, 12)
        .shadow(radius: 6, y: 2)
    }
    #endif

    #if os(iOS)
    var floatingDateNavigatorIOS: some View {
        return GlassEffectContainer {
            HStack {
                Picker("Periodo", selection: $calendarPeriod) {
                    ForEach(CalendarPeriod.allCases, id: \.self) { option in
                        Text(LocalizedStringKey(option.rawValue))
                            .tag(option)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .layoutPriority(1)
                .glassEffect(.regular.interactive(), in: .capsule)

                Button {
                    shiftReferenceDate(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .glassEffect(.regular.interactive(), in: .capsule)

                DatePicker(
                    "",
                    selection: referenceDateBinding,
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .font(.subheadline)
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
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 8)
            .frame(minHeight: calendarHeaderHeight, alignment: .leading)
            .background(Color.accentColor, in: Capsule())
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
        let servicesForDay = cachedOccurrences
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .map { $0.service }
        var unique: [NSManagedObjectID: Services] = [:]
        for service in servicesForDay {
            unique[service.objectID] = service
        }
        return Array(unique.values).prefix(6).map { $0 }
    }

    @ViewBuilder
    private func dayMarkersGrid(services: [Services]) -> some View {
        let columns = Array(repeating: GridItem(.fixed(14), spacing: 4), count: 3)
        LazyVGrid(columns: columns, alignment: .leading, spacing: 4) {
            ForEach(services, id: \.objectID) { service in
                dayMarker(for: service)
            }
        }
    }

    @ViewBuilder
    private func dayMarker(for service: Services) -> some View {
        if let imageData = service.image {
            #if os(iOS)
            if let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 14, height: 14)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(service.wrappedColor)
                    .frame(width: 14, height: 14)
            }
            #else
            if let image = NSImage(data: imageData) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 14, height: 14)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(service.wrappedColor)
                    .frame(width: 14, height: 14)
            }
            #endif
        } else {
            Circle()
                .fill(service.wrappedColor)
                .frame(width: 14, height: 14)
        }
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
