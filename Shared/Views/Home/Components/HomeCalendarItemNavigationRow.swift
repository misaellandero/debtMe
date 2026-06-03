//
//  HomeCalendarItemNavigationRow.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import SwiftUI

struct HomeCalendarItemNavigationRow: View {
    let item: HomeCalendarItem
    var namespace: Namespace.ID?
    var onMacSelect: (() -> Void)?

    var body: some View {
        #if os(macOS)
        Button {
            onMacSelect?()
        } label: {
            HomeCalendarItemRow(item: item, namespace: namespace)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        #else
        Group {
            if let service = item.service {
                NavigationLink(destination: ServiceDetailView(service: service)) {
                    HomeCalendarItemRow(item: item, namespace: namespace)
                }
            } else if let transaction = item.transaction {
                NavigationLink(destination: PaymentsTransactionsList(transaction: transaction)) {
                    HomeCalendarItemRow(item: item, namespace: namespace)
                }
            } else {
                HomeCalendarItemRow(item: item, namespace: namespace)
            }
        }
        #endif
    }
}
