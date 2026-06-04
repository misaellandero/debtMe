//
//  HomeDetailSheet.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import SwiftUI

struct HomeDetailSheet: View {
    let title: String
    let items: [HomeCalendarItem]
    @State private var paidStateVersion = 0

    var body: some View {
        NavigationStack {
            List {
                if items.isEmpty {
                    Text("No scheduled items in this period")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(items) { item in
                        HomeCalendarItemNavigationRow(item: item)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                if item.paidOccurrenceID != nil {
                                    Button {
                                        togglePaid(item)
                                    } label: {
                                        Label(item.currentIsPaid ? "Mark unpaid" : (item.isIncome ? "Mark spent" : "Mark paid"), systemImage: item.currentIsPaid ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                                    }
                                    .tint(item.currentIsPaid ? .orange : .green)
                                }
                            }
                    }

                    Text("Swipe right on a service to mark only that day as paid. Swipe it again to mark it unpaid.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .animation(.smooth, value: paidStateVersion)
            .navigationTitle(title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func togglePaid(_ item: HomeCalendarItem) {
        guard let paidOccurrenceID = item.paidOccurrenceID else { return }
        ServiceOccurrencePaymentStore.toggle(paidOccurrenceID)
        paidStateVersion += 1
    }
}

