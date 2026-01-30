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

    enum ServicesPeriodView: String, CaseIterable {
        case list = "List"
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

    @State var periodView: ServicesPeriodView = .list
    
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
        switch periodView {
        case .list:
            let start = min(startDate, endDate)
            let end = max(startDate, endDate)
            return DateInterval(start: start, end: end)
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
        var occurrences = filteredServices.flatMap { $0.occurrences(in: range, calendar: .current) }
        if periodView != .list {
            occurrences.sort { $0.date < $1.date }
        }
        return occurrences
    }

    var groupedOccurrences: [(title: String, items: [ServiceOccurrence])] {
        let calendar = Calendar.current
        let formatter = DateFormatter()

        switch periodView {
        case .week:
            formatter.dateFormat = "EEEE, MMM d"
            let grouped = Dictionary(grouping: filteredOccurrences, by: { calendar.startOfDay(for: $0.date) })
            return grouped.keys.sorted().map { key in
                (formatter.string(from: key), grouped[key] ?? [])
            }
        case .month:
            let grouped = Dictionary(grouping: filteredOccurrences, by: { calendar.component(.weekOfMonth, from: $0.date) })
            return grouped.keys.sorted().map { key in
                ("Week \(key)", grouped[key] ?? [])
            }
        case .year:
            formatter.dateFormat = "MMMM"
            let grouped = Dictionary(grouping: filteredOccurrences, by: { calendar.component(.month, from: $0.date) })
            return grouped.keys.sorted().map { key in
                let monthDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: referenceDate), month: key, day: 1)) ?? referenceDate
                return (formatter.string(from: monthDate), grouped[key] ?? [])
            }
        case .list:
            return []
        }
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("summaryServicesSelectd") var summarySelectd: summaryServicesMenu = .balance
    @AppStorage("ShowServicesSummary") var ShowSummary = true
        
    var body: some View {
        List{
            Section(content: {
                Picker("View", selection: $periodView) {
                    ForEach(ServicesPeriodView.allCases, id: \.self) { option in
                        Text(LocalizedStringKey(option.rawValue))
                            .tag(option)
                    }
                }
                #if os(visionOS)
                .pickerStyle(MenuPickerStyle())
                #else
                .pickerStyle(SegmentedPickerStyle())
                #endif

                if periodView == .list {
                    DatePicker("Start Date", selection: $startDate)
                         
                    DatePicker("End Date", selection: $endDate)
                } else {
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
            
            if periodView == .list {
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
                ForEach(groupedOccurrences, id: \.title) { group in
                    Section(header: Text(group.title)) {
                        ForEach(group.items) { occurrence in
                            NavigationLink(destination: ServiceDetailView(service: occurrence.service) ) {
                                ServiceRow(BgColor: occurrence.service.wrappedColor, ServiceName: occurrence.service.wrappedName, Amount: occurrence.service.amount.toCurrencyString(), frequency: occurrence.service.frecuencyString, limitDate: occurrence.date.formatted(date: .abbreviated, time: .omitted), image: occurrence.service.image, expense: occurrence.service.expense)
                            }
                            .listRowBackground(occurrence.service.wrappedColor)
                        }
                        .onDelete { offsets in
                            deleteOccurrences(at: offsets, in: group.items)
                        }
                    }
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
