//
//  TabBarView.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

	struct TabBarView: View {
	    // MARK: - current section selected
	    @State var sectionSelected = SectionSelected.home
	    @AppStorage("servicesViewMode") private var servicesViewMode: ServicesViewMode = .calendar
	    @AppStorage("servicesCalendarPeriod") private var servicesCalendarPeriod: CalendarPeriod = .month
	    @AppStorage("servicesReferenceDate") private var servicesReferenceDateTimestamp: Double = Date().timeIntervalSince1970
	    @AppStorage("servicesNextIncomeDayOfMonth") private var servicesNextIncomeDayOfMonth: Int = 15
    
    var servicesReferenceDate: Date {
        Date(timeIntervalSince1970: servicesReferenceDateTimestamp)
    }

    var servicesReferenceDateBinding: Binding<Date> {
        Binding(
            get: { servicesReferenceDate },
            set: { servicesReferenceDateTimestamp = $0.timeIntervalSince1970 }
        )
    }
    
    var servicesDateRangeLabel: String {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: servicesSelectedDateRange.start, to: servicesSelectedDateRange.end)
    }
    
	    var servicesSelectedDateRange: DateInterval {
	        let calendar = Calendar.current
	        switch servicesCalendarPeriod {
	        case .day:
	            let start = calendar.startOfDay(for: servicesReferenceDate)
	            let end = calendar.date(byAdding: .day, value: 1, to: start)?.addingTimeInterval(-1) ?? servicesReferenceDate
	            return DateInterval(start: start, end: end)
	        case .week:
	            return calendar.dateInterval(of: .weekOfYear, for: servicesReferenceDate) ?? DateInterval(start: servicesReferenceDate, end: servicesReferenceDate)
	        case .fortnight:
	            return fortnightRange(for: servicesReferenceDate, calendar: calendar)
	        case .month:
	            return calendar.dateInterval(of: .month, for: servicesReferenceDate) ?? DateInterval(start: servicesReferenceDate, end: servicesReferenceDate)
	        case .year:
	            return calendar.dateInterval(of: .year, for: servicesReferenceDate) ?? DateInterval(start: servicesReferenceDate, end: servicesReferenceDate)
	        case .untilNextIncome:
	            return untilNextIncomeRange(from: Date(), incomeDayOfMonth: servicesNextIncomeDayOfMonth, calendar: calendar)
	        }
	    }

	    private func fortnightRange(for date: Date, calendar: Calendar) -> DateInterval {
	        let comps = calendar.dateComponents([.year, .month, .day], from: date)
	        let year = comps.year ?? calendar.component(.year, from: date)
	        let month = comps.month ?? calendar.component(.month, from: date)
	        let day = comps.day ?? calendar.component(.day, from: date)

	        let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? date
	        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30

	        if day <= 15 {
	            let start = calendar.startOfDay(for: monthStart)
	            let endDay = min(15, daysInMonth)
	            let endDate = calendar.date(from: DateComponents(year: year, month: month, day: endDay)) ?? monthStart
	            let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))?.addingTimeInterval(-1) ?? endDate
	            return DateInterval(start: start, end: end)
	        } else {
	            let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 16)) ?? monthStart
	            let start = calendar.startOfDay(for: startDate)
	            let endDate = calendar.date(from: DateComponents(year: year, month: month, day: daysInMonth)) ?? monthStart
	            let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))?.addingTimeInterval(-1) ?? endDate
	            return DateInterval(start: start, end: end)
	        }
	    }

	    private func untilNextIncomeRange(from now: Date, incomeDayOfMonth: Int, calendar: Calendar) -> DateInterval {
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

	        let nextIncomeDate: Date
	        if candidate > start {
	            nextIncomeDate = candidate
	        } else {
	            let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: currentMonthStart) ?? currentMonthStart
	            nextIncomeDate = dateForIncomeDay(in: nextMonthStart)
	        }

	        let end = calendar.date(byAdding: .day, value: -1, to: nextIncomeDate) ?? start
	        return DateInterval(start: start, end: max(start, end))
	    }
    
    var body: some View {
        let content = TabView(selection: $sectionSelected){
            // MARK: - Home
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(SectionSelected.home)

            // MARK: - Contacts
            NavigationStack {
                ContactsList()
            }
            .tabItem {
                Label("People", systemImage: "person.2.fill")
            }
            .tag(SectionSelected.contacts)
            /* // MARK: - Debts
            NavigationView{
                TransactionsListFilter(isDebt:true)
            }
            .tabItem {
                Label("Debts", systemImage: "dollarsign.square")
            }
            .tag(SectionSelected.debts)
            
           // MARK: - Loans
            NavigationView{
                TransactionsListFilter(isDebt:false)
            }
            .tabItem {
                Label("Loans", systemImage: "dollarsign.square.fill")
            }
            .tag(SectionSelected.loans)
             */
            // MARK: - Services
            
            NavigationStack {
                ServicesList()
            }
            .tabItem {
                Label("Services", systemImage: "chart.bar.doc.horizontal")
            }
            .tag(SectionSelected.loans)
            
            // MARK: - Settings
            NavigationStack {
                SettingsList()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(SectionSelected.settings)
            
        }
        .font(Font.system(.body, design: .rounded))
        .tabViewStyle(.sidebarAdaptable)
        .tabViewSidebarHeader {
            Label(
                title: { Text("DebtMe")
                    .appBrandTitle() },
                icon: {  Image(.pig)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30) }
            )
            .labelStyle(.titleAndIcon)
        }
        content
    }

    // Date navigator moved to ServicesList overlay.
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView( )
    }
}
