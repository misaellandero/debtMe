//
//  HomeDetailSheet.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import SwiftUI

struct HomeDetailSheet: View {
    let dateSubtitle: String
    let items: [HomeCalendarItem]
    @State private var paidStateVersion = 0

    private var income: Double {
        items.filter { $0.isIncome && !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }

    private var expenses: Double {
        items.filter { !$0.isIncome && !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }

    private var balance: Double {
        income - expenses
    }

    var body: some View {
        NavigationStack {
            List {
                balanceSummarySection

                if items.isEmpty {
                    Section {
                        Text("No services or people transactions are scheduled for this day.")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Section {
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
                    }

                    Section {
                        Text("Swipe right on an item to mark only this date as paid or spent. Swipe again to undo.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .animation(.smooth, value: paidStateVersion)
            .navigationTitle("Scheduled")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var balanceSummarySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text(dateSubtitle)
                    .font(.headline)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Day balance")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(balance.toCurrencyString())
                        .font(.title2.weight(.bold))
                        .foregroundStyle(balance >= 0 ? Color.primary : Color.red)
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Income")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(income.toCurrencyString())
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Expenses")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text("-" + expenses.toCurrencyString())
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.red)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.vertical, 4)
        }
    }

    private func togglePaid(_ item: HomeCalendarItem) {
        guard let paidOccurrenceID = item.paidOccurrenceID else { return }
        ServiceOccurrencePaymentStore.toggle(paidOccurrenceID)
        paidStateVersion += 1
    }
}
