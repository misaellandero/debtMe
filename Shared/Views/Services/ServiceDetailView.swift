//
//  ServiceDetailView.swift
//  debtMe
//
//  Created by Misael Landero on 16/06/24.
//

import SwiftUI

private enum ServiceDetailModal: Identifiable {
    case edit
    case amountUpdate

    var id: String {
        switch self {
        case .edit: "edit"
        case .amountUpdate: "amountUpdate"
        }
    }
}

struct ServiceDetailView: View {
    @ObservedObject var service : Services
    var showsNavigationChrome = true
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    @State private var activeModal: ServiceDetailModal?
    @Environment(\.dismiss) private var dismiss

    @State private var currentOccurrenceIsPaid: Bool = false
    @State private var currentOccurrenceID: String?

    private func refreshCurrentOccurrence() {
        // Determine the most relevant occurrence for this service (today or next upcoming)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // Build a generous range around today (past month to next month) to find a relevant occurrence
        let start = calendar.date(byAdding: .month, value: -1, to: today) ?? today
        let end = calendar.date(byAdding: .month, value: 1, to: today) ?? today
        let range = DateInterval(start: start, end: end)

        let occurrences = service.occurrences(in: range, calendar: .current).sorted { $0.date < $1.date }

        // Prefer today's occurrence; otherwise nearest future; otherwise latest past
        let todayOcc = occurrences.first { calendar.isDate($0.date, inSameDayAs: today) }
        let futureOcc = occurrences.first { $0.date >= today }
        let selected = todayOcc ?? futureOcc ?? occurrences.last

        currentOccurrenceID = selected?.id
        currentOccurrenceIsPaid = selected?.isPaid ?? false
    }

    private func toggleCurrentOccurrencePaid() {
        guard let id = currentOccurrenceID else { return }
        ServiceOccurrencePaymentStore.toggle(id)
        currentOccurrenceIsPaid.toggle()
    }

    private var paidActionTitle: LocalizedStringKey {
        if currentOccurrenceIsPaid {
            return service.expense ? "Mark unpaid" : "Mark unspent"
        }
        return service.expense ? "Mark paid" : "Mark spent"
    }

    var body: some View {
        #if os(macOS)
        VStack(spacing: 8) {
            if showsNavigationChrome {
                List {
                    serviceSummarySection
                }
                .listStyle(.plain)
                .frame(minHeight: 110, maxHeight: 190)
            } else {
                ServiceInspectorCard(service: service)
            }

            serviceActions
                .padding(.horizontal)

            serviceManagementActions
                .padding(.horizontal)

            AmountUpdateList(service: service, showsUpdateButton: false, onUpdateAmount: showAmountUpdateEditor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle(showsNavigationChrome ? service.wrappedName : "")
        .toolbar { if showsNavigationChrome { editToolbarItem } }
        .sheet(item: $activeModal, content: modalContent)
        .onAppear(perform: refreshCurrentOccurrence)
        .onReceive(NotificationCenter.default.publisher(for: ServiceOccurrencePaymentStore.didChangeNotification)) { _ in
            refreshCurrentOccurrence()
        }
        .onChange(of: service.frequencyDate) { _, _ in refreshCurrentOccurrence() }
        .onChange(of: service.amount) { _, _ in refreshCurrentOccurrence() }
        #else
        List{
            serviceSummarySection
            
            Section {
                serviceActions
            }
            
            AmountUpdateList(service: service, showsUpdateButton: false, onUpdateAmount: showAmountUpdateEditor)
        }
        .navigationTitle(service.wrappedName)
        .toolbar{
            editToolbarItem
        }
        .sheet(item: $activeModal, content: modalContent)
        .onAppear(perform: refreshCurrentOccurrence)
        .onReceive(NotificationCenter.default.publisher(for: ServiceOccurrencePaymentStore.didChangeNotification)) { _ in
            refreshCurrentOccurrence()
        }
        .onChange(of: service.frequencyDate) { _, _ in refreshCurrentOccurrence() }
        .onChange(of: service.amount) { _, _ in refreshCurrentOccurrence() }
        #endif
    }

    private var serviceSummarySection: some View {
        Section{
            ServiceRow(BgColor: service.wrappedColor, ServiceName: service.wrappedName, Amount: service.amount.toCurrencyString(), frequency: service.frecuencyString, limitDate: service.frequencyDate.formatted(date: .abbreviated, time: .omitted), image: service.image, expense: service.expense)
            Text(service.wrappedDes)
                .multilineTextAlignment(.leading)
        }
        .listRowBackground(service.wrappedColor)
    }

    private var serviceActions: some View {
        VStack(spacing: 12) {
            paidActionButton
            updateAmountActionButton
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }

    private var paidActionButton: some View {
        Button {
            toggleCurrentOccurrencePaid()
        } label: {
            Label(
                paidActionTitle,
                systemImage: currentOccurrenceIsPaid ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill"
            )
        }
        .buttonStyle(AppActionButtonStyle(tint: currentOccurrenceIsPaid ? .orange : .green))
    }

    private var updateAmountActionButton: some View {
        Button {
            showAmountUpdateEditor()
        } label: {
            Label("Update Amount", systemImage: "plus")
        }
        .buttonStyle(AppActionButtonStyle(tint: AppTheme.actionTint))
    }

    private func showAmountUpdateEditor() {
        activeModal = .amountUpdate
    }

    @ViewBuilder
    private func modalContent(_ modal: ServiceDetailModal) -> some View {
        switch modal {
        case .edit:
            ServicesForm(edition: true, service: service)
        case .amountUpdate:
            AmountUpdateEditorSheet(service: service)
        }
    }

    @ViewBuilder
    private var serviceManagementActions: some View {
        if let onDelete {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .buttonStyle(.appAction(tint: AppTheme.destructiveTint))
            .frame(maxWidth: .infinity)
        }
    }

    private var editToolbarItem: some ToolbarContent {
        ToolbarItem(placement:.primaryAction){
            Button(action:{
                if let onEdit { onEdit() } else { activeModal = .edit }
            }){
                Image(systemName: AppIcons.edit)
                    .accessibilityLabel(Text("Edit"))
            }
            .appGlassControlButtonStyle()
        }
    }
}

#if os(macOS)
private struct ServiceInspectorCard: View {
    @ObservedObject var service: Services

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ServiceRow(
                BgColor: service.wrappedColor,
                ServiceName: service.wrappedName,
                Amount: service.amount.toCurrencyString(),
                frequency: service.frecuencyString,
                limitDate: service.frequencyDate.formatted(date: .abbreviated, time: .omitted),
                image: service.image,
                expense: service.expense,
                useAdaptiveText: true
            )

            if !service.wrappedDes.isEmpty {
                Text(service.wrappedDes)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(14)
        .background(service.wrappedColor.opacity(0.92), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(service.wrappedColor.opacity(0.35), lineWidth: 1)
        )
        .padding(.horizontal, 12)
    }
}
#endif
