//
//  HomeInspectorView.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import SwiftUI

#if os(macOS)
struct HomeInspectorView: View {
    let title: String
    let items: [HomeCalendarItem]
    @Binding var selectedService: Services?
    @Binding var selectedTransaction: Transaction?
    @State private var showServiceEdit = false
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        if let selectedService {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Button {
                        self.selectedService = nil
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                    }
                    .buttonStyle(.plain)

                    Text(selectedService.wrappedName)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()
                }
                .padding(.horizontal, 12)

                ServiceDetailView(
                    service: selectedService,
                    showsNavigationChrome: false,
                    onEdit: { showServiceEdit = true },
                    onDelete: { delete(service: selectedService) }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .sheet(isPresented: $showServiceEdit) {
                ServicesForm(edition: true, service: selectedService)
            }
        } else if let selectedTransaction {
            NavigationStack {
                PaymentsTransactionsList(transaction: selectedTransaction)
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button {
                                self.selectedTransaction = nil
                            } label: {
                                Label("Back", systemImage: "chevron.left")
                            }
                        }
                    }
            }
        } else {
            HomeInspectorSummary(
                title: title,
                items: items,
                selectedService: $selectedService,
                selectedTransaction: $selectedTransaction
            )
        }
    }

    private func delete(service: Services) {
        selectedService = nil
        viewContext.delete(service)
        do {
            try viewContext.save()
        } catch {
            print("Error deleting service from Home inspector: \(error.localizedDescription)")
        }
    }
}

private struct HomeInspectorSummary: View {
    let title: String
    let items: [HomeCalendarItem]
    @Binding var selectedService: Services?
    @Binding var selectedTransaction: Transaction?

    var body: some View {
        let income = items.filter(\.isIncome).reduce(0) { $0 + $1.amount }
        let expenses = items.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
        let balance = income - expenses

        VStack(alignment: .leading, spacing: 12) {
            Text(title)
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

            if items.isEmpty {
                Text("No scheduled items in this period")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items) { item in
                    HomeInspectorHoverRow(item: item) {
                        selectedService = item.service
                        selectedTransaction = item.transaction
                    }
                }
            }

            Spacer()
        }
        .padding()
    }
}

private struct HomeInspectorHoverRow: View {
    let item: HomeCalendarItem
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HomeCalendarItemRow(item: item)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isHovered ? Color.accentColor.opacity(0.12) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(isHovered ? Color.accentColor.opacity(0.45) : Color.clear, lineWidth: 1)
                )
                .scaleEffect(isHovered ? 1.015 : 1)
                .animation(.snappy(duration: 0.16), value: isHovered)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
#endif
