//
//  ServiceDetailView.swift
//  debtMe
//
//  Created by Misael Landero on 16/06/24.
//

import SwiftUI

struct ServiceDetailView: View {
    @ObservedObject var service : Services
    var showsNavigationChrome = true
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    @State var showEdit = false
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
                ServiceInspectorCard(
                    service: service,
                    onEdit: onEdit,
                    onDelete: onDelete
                )
            }
            
            VStack(spacing: 10) {
                Button {
                    toggleCurrentOccurrencePaid()
                } label: {
                    Label(
                        paidActionTitle,
                        systemImage: currentOccurrenceIsPaid ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .tint(currentOccurrenceIsPaid ? .orange : .green)
                .buttonStyle(GlassProminentButtonStyle())

                Button {
                    if let onEdit { onEdit() } else { showEdit.toggle() }
                } label: {
                    Label("Edit", systemImage: AppIcons.edit)
                        .appToolbarLabel()
                        .labelStyle(.titleAndIcon)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.accentColor)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .center)

            AmountUpdateList(service: service)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle(showsNavigationChrome ? service.wrappedName : "")
        .toolbar { if showsNavigationChrome { editToolbarItem } }
        .sheet(isPresented: $showEdit, content: {
            ServicesForm(edition:true, service: service)
        })
        .onAppear(perform: refreshCurrentOccurrence)
        .onChange(of: service.frequencyDate) { _ in refreshCurrentOccurrence() }
        .onChange(of: service.amount) { _ in refreshCurrentOccurrence() }
        #else
        List{
            serviceSummarySection
            
            Section {
                VStack(spacing: 10) {
                    Button {
                        toggleCurrentOccurrencePaid()
                    } label: {
                        Label(
                            paidActionTitle,
                            systemImage: currentOccurrenceIsPaid ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(.white)
                    .tint(currentOccurrenceIsPaid ? .orange : .green)
                    .buttonStyle(GlassProminentButtonStyle())

                    Button {
                        showEdit.toggle()
                    } label: {
                        Label("Edit", systemImage: AppIcons.edit)
                            .appToolbarLabel()
                            .labelStyle(.titleAndIcon)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            AmountUpdateList(service: service)
        }
        .navigationTitle(service.wrappedName)
        .toolbar{
            editToolbarItem
        }
        .sheet(isPresented: $showEdit, content: {
            ServicesForm(edition:true, service: service)
        })
        .onAppear(perform: refreshCurrentOccurrence)
        .onChange(of: service.frequencyDate) { _ in refreshCurrentOccurrence() }
        .onChange(of: service.amount) { _ in refreshCurrentOccurrence() }
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

    private var editToolbarItem: some ToolbarContent {
        ToolbarItem(placement:.primaryAction){
            Button(action:{
                showEdit.toggle()
            }){
                Label("Edit", systemImage: AppIcons.edit)
                    .appToolbarLabel()
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(Color.accentColor)
            }
        }
    }
}

#if os(macOS)
private struct ServiceInspectorCard: View {
    @ObservedObject var service: Services
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?

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

            HStack(spacing: 10) {
                Button {
                    onEdit?()
                } label: {
                    Label("Edit", systemImage: AppIcons.edit)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)

                Button(role: .destructive) {
                    onDelete?()
                } label: {
                    Label("Delete", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 1.0, green: 0.12, blue: 0.08))
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
