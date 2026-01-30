//
//  ServicesList.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI
import CoreData

struct ServicesList: View {
  
    @State var showNewBill = false

    enum ServicesViewMode: String, CaseIterable {
        case list = "List"
        case calendar = "Calendar"
    }

    enum CalendarPeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    @FetchRequest(entity: ContactLabel.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ContactLabel.name, ascending: true)]) var labels: FetchedResults<ContactLabel>
    
    @FetchRequest(entity: Services.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Services.name, ascending: true)]) var services: FetchedResults<Services>
    
    // Computed property to calculate the total amount
    var totalExpenses: Double {
        filteredOccurrences.filter { $0.service.expense }.reduce(0) { $0 + $1.service.amount }
    }
    var totalIncome: Double {
        filteredOccurrences.filter { !$0.service.expense }.reduce(0) { $0 + $1.service.amount }
    }
    
    var balance: Double{
        totalIncome - totalExpenses
    }
    
    @State var selectedTag = "All"
    
    @State var searchQuery = ""
    
    @State var startDate = Date()
    
    @State var endDate =  Date()

    @State var viewMode: ServicesViewMode = .list

    @State var calendarPeriod: CalendarPeriod = .month

    @State var referenceDate = Date()
    
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
        if viewMode == .list {
            let start = min(startDate, endDate)
            let end = max(startDate, endDate)
            return DateInterval(start: start, end: end)
        }

        switch calendarPeriod {
        case .week:
            return calendar.dateInterval(of: .weekOfYear, for: referenceDate) ?? DateInterval(start: referenceDate, end: referenceDate)
        case .month:
            return calendar.dateInterval(of: .month, for: referenceDate) ?? DateInterval(start: referenceDate, end: referenceDate)
        case .year:
            return calendar.dateInterval(of: .year, for: referenceDate) ?? DateInterval(start: referenceDate, end: referenceDate)
        }
    }

    var dateRangeLabel: String {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: selectedDateRange.start, to: selectedDateRange.end)
    }

    var filteredOccurrences: [ServiceOccurrence] {
        let range = selectedDateRange
        let occurrences = filteredServices.flatMap { $0.occurrences(in: range, calendar: .current) }
        return occurrences.sorted { $0.date < $1.date }
    }

    var expenseTotalsByDay: [Date: Double] {
        let calendar = Calendar.current
        return filteredOccurrences.reduce(into: [:]) { partial, occurrence in
            guard occurrence.service.expense else { return }
            let day = calendar.startOfDay(for: occurrence.date)
            partial[day, default: 0] += occurrence.service.amount
        }
    }

    var expenseTotalsByMonth: [Date: Double] {
        let calendar = Calendar.current
        return filteredOccurrences.reduce(into: [:]) { partial, occurrence in
            guard occurrence.service.expense else { return }
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
    
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("summaryServicesSelectd") var summarySelectd: summaryServicesMenu = .balance
    @AppStorage("ShowServicesSummary") var ShowSummary = true

    var weekdaySymbols: [String] {
        let calendar = Calendar.current
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let startIndex = max(0, calendar.firstWeekday - 1)
        return Array(symbols[startIndex...] + symbols[..<startIndex])
    }

    var calendarView: some View {
        let dayColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
        let monthColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

        return VStack(alignment: .leading, spacing: 12) {
            switch calendarPeriod {
            case .week:
                HStack {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                LazyVGrid(columns: dayColumns, spacing: 8) {
                    ForEach(weekDates, id: \.self) { date in
                        dayCell(for: date)
                    }
                }
            case .month:
                HStack {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                LazyVGrid(columns: dayColumns, spacing: 8) {
                    ForEach(Array(monthGridDates.enumerated()), id: \.offset) { _, date in
                        if let date {
                            dayCell(for: date)
                        } else {
                            Color.clear
                                .frame(height: 44)
                        }
                    }
                }
            case .year:
                LazyVGrid(columns: monthColumns, spacing: 12) {
                    ForEach(yearMonthStarts, id: \.self) { date in
                        monthCell(for: date)
                    }
                }
            }
        }
    }
        
    var body: some View {
        List{
            Section(content: {
                Picker("View", selection: $viewMode) {
                    ForEach(ServicesViewMode.allCases, id: \.self) { option in
                        Text(LocalizedStringKey(option.rawValue))
                            .tag(option)
                    }
                }
                #if os(visionOS)
                .pickerStyle(MenuPickerStyle())
                #else
                .pickerStyle(SegmentedPickerStyle())
                #endif

                if viewMode == .list {
                    DatePicker("Start Date", selection: $startDate)

                    DatePicker("End Date", selection: $endDate)
                } else {
                    Picker("Period", selection: $calendarPeriod) {
                        ForEach(CalendarPeriod.allCases, id: \.self) { option in
                            Text(LocalizedStringKey(option.rawValue))
                                .tag(option)
                        }
                    }
                    #if os(visionOS)
                    .pickerStyle(MenuPickerStyle())
                    #else
                    .pickerStyle(SegmentedPickerStyle())
                    #endif

                    DatePicker("Reference Date", selection: $referenceDate, displayedComponents: .date)
                    Text(dateRangeLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

            }, header: {
                Label("Date frame", systemImage: "calendar")
            })
            
            if ShowSummary {
                Section(){
                    Group{
                        switch summarySelectd {
                        case .balance:
                            VStack(alignment: .leading){
                                Text("Balance")
                                    .font(.caption)
                                Text(balance.toCurrencyString())
                                    .foregroundStyle(balance >= 0 ? Color.primary : Color.red)
                                
                            }
                        case .expense:
                            VStack(alignment: .leading){
                                Text(LocalizedStringKey("Expenses"))
                                    .font(.caption)
                                Text("-" + totalExpenses.toCurrencyString())
                                    .foregroundColor(.red)
                                
                            }
                        case .income:
                            VStack(alignment: .leading){
                                Text(LocalizedStringKey("Income"))
                                    .font(.caption)
                                    
                                Text(totalIncome.toCurrencyString())
                                    .foregroundColor(.blue)
                                
                            }
                        case .all:
                            VStack(alignment: .leading){
                                Text(LocalizedStringKey("Income"))
                                    .font(.caption)
                                    
                                Text(totalIncome.toCurrencyString())
                                    .foregroundColor(.blue)
                                
                            }
                            VStack(alignment: .leading){
                                Text(LocalizedStringKey("Expenses"))
                                    .font(.caption)
                                Text("-" + totalExpenses.toCurrencyString())
                                    .foregroundColor(.red)
                                
                            }
                            VStack(alignment: .leading){
                                Text("Balance")
                                    .font(.caption)
                                Text(balance.toCurrencyString())
                                    .foregroundStyle(balance >= 0 ? Color.primary : Color.red)
                                
                            }
                        }
                    }
                    .bold()
                    .font(.largeTitle)
                    
                    Picker("Summary", selection: $summarySelectd) {
                        ForEach(summaryServicesMenu.allCases, id:\.self ){ option in
                            Text(LocalizedStringKey(option.rawValue))
                                .tag(option)
                        }
                    }
                    #if os(visionOS)
                    .pickerStyle(MenuPickerStyle())
                    #else
                    .pickerStyle(SegmentedPickerStyle())
                    #endif
                }
            }
            
            if viewMode == .list {
                ForEach(filteredOccurrences) { occurrence in
                    NavigationLink(destination: ServiceDetailView(service: occurrence.service) ) {
                        ServiceRow(BgColor: occurrence.service.wrappedColor, ServiceName: occurrence.service.wrappedName, Amount: occurrence.service.amount.toCurrencyString(), frequency: occurrence.service.frecuencyString, limitDate: occurrence.date.formatted(date: .abbreviated, time: .omitted), image: occurrence.service.image, expense: occurrence.service.expense)
                    }
                    .listRowBackground(occurrence.service.wrappedColor)
                }
                .onDelete { offsets in
                    deleteOccurrences(at: offsets, in: filteredOccurrences)
                }
            } else {
                Section {
                    calendarView
                }
            }
        }
        .toolbar{
            
            #if os(macOS)
            ToolbarItem(placement: .navigation ){
                Text("\(Image(systemName: "chart.bar.doc.horizontal")) Bills")
                    .font(Font.system(.headline, design: .rounded).weight(.black))
            }
            ToolbarItem(placement: .navigation ){
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
                    Label("Filter", systemImage: "line.horizontal.3.decrease.circle.fill")   .font(Font.system(.headline, design: .rounded).weight(.black))
                        .foregroundColor(.gray)
                }
            }
        }
        .sheet(isPresented: $showNewBill, content: {
            ServicesForm()
        })
        #if os(iOS)
        .navigationTitle("Bills")
        .searchable(text: $searchQuery)
    #endif
    }

    private func dayCell(for date: Date) -> some View {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let isToday = calendar.isDateInToday(date)
        let total = expenseTotalsByDay[calendar.startOfDay(for: date)] ?? 0

        return VStack(alignment: .leading, spacing: 4) {
            Text("\(day)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isToday ? Color.accentColor : Color.primary)
            if total > 0 {
                Text("-" + total.toCurrencyString())
                    .font(.caption2)
                    .foregroundColor(.red)
            } else {
                Text(" ")
                    .font(.caption2)
                    .foregroundStyle(.clear)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .padding(6)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func monthCell(for date: Date) -> some View {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let monthStart = calendar.date(from: components) ?? date
        let total = expenseTotalsByMonth[monthStart] ?? 0
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        return VStack(alignment: .leading, spacing: 6) {
            Text(formatter.string(from: monthStart))
                .font(.caption)
                .fontWeight(.semibold)
            if total > 0 {
                Text("-" + total.toCurrencyString())
                    .font(.caption2)
                    .foregroundColor(.red)
            } else {
                Text(" ")
                    .font(.caption2)
                    .foregroundStyle(.clear)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
        .padding(8)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
}

#Preview {
    NavigationStack{
        ServicesList()
    }
}
