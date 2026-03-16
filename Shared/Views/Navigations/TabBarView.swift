//
//  TabBarView.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct TabBarView: View {
    // MARK: - current section selected
    @State var sectionSelected = SectionSelected.contacts
    @AppStorage("servicesViewMode") private var servicesViewMode: ServicesViewMode = .list
    @AppStorage("servicesCalendarPeriod") private var servicesCalendarPeriod: CalendarPeriod = .month
    @AppStorage("servicesReferenceDate") private var servicesReferenceDateTimestamp: Double = Date().timeIntervalSince1970
    
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
        case .month:
            return calendar.dateInterval(of: .month, for: servicesReferenceDate) ?? DateInterval(start: servicesReferenceDate, end: servicesReferenceDate)
        case .year:
            return calendar.dateInterval(of: .year, for: servicesReferenceDate) ?? DateInterval(start: servicesReferenceDate, end: servicesReferenceDate)
        }
    }
    
    var body: some View {
        let content = TabView(selection: $sectionSelected){
            // MARK: - Contacts
            NavigationView{
                ContactsList()
            }
            .tabItem {
                Label("Contacts", systemImage: "person.2.fill")
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
            
            NavigationView{
                ServicesList()
            }
            .tabItem {
                Label("Bills", systemImage: "chart.bar.doc.horizontal")
            }
            .tag(SectionSelected.loans)
            
            // MARK: - Settings
            NavigationView{
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
                    .font(Font.system(.title, design: .rounded).weight(.black)) },
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
