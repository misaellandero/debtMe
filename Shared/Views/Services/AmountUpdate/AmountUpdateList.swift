//
//  AmountUpdateList.swift
//  debtMe
//
//  Created by Misael Landero on 17/06/24.
//

import SwiftUI
import CoreData

struct AmountUpdateList: View {
    @ObservedObject var service : Services
    var showsUpdateButton = true
    var onUpdateAmount: () -> Void
    
    var body: some View {
        #if os(macOS)
        VStack(alignment: .leading, spacing: 12) {
            List {
                Section("History") {
                    if service.amountUpdatesArray.isEmpty {
                        Text("No amount updates")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(service.amountUpdatesArray) { amountUpdate in
                            VStack(alignment: .leading) {
                                Text(amountUpdate.wrappedUpdateDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(.secondary)
                                Text(amountUpdate.amount.toCurrencyString())
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if showsUpdateButton {
                Button {
                    onUpdateAmount()
                } label: {
                    Label("Update Amount", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .appSheetPrimaryButtonStyle()
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #else
        Group {
            Section("History") {
                if showsUpdateButton {
                    Button {
                        onUpdateAmount()
                    } label: {
                        Label("Update Amount", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .appSheetPrimaryButtonStyle()
                }
            }

            ForEach(service.amountUpdatesArray) { amountUpdate in
                VStack(alignment: .leading) {
                    Text(amountUpdate.wrappedUpdateDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.secondary)
                    Text(amountUpdate.amount.toCurrencyString())
                }
            }
        }
        #endif
    }
}

struct AmountUpdateEditorSheet: View {
    @ObservedObject var service: Services

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    @State private var amountIsFocused = false
    @State private var amountText = ""

    private var amount: Double {
        parseAmount(amountText) ?? 0
    }

    private func formattedAmountInput(for value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "0.00"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    AppAmountEntryField(amountText: $amountText, isFocused: $amountIsFocused)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("History")
                            .font(.headline)

                        if service.amountUpdatesArray.isEmpty {
                            Text("No amount updates")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        } else {
                            ForEach(service.amountUpdatesArray) { amountUpdate in
                                Button {
                                    select(amountUpdate)
                                } label: {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(amountUpdate.wrappedUpdateDate.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text(amountUpdate.amount.toCurrencyString())
                                                .font(.headline)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding()
                                    .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Update Amount")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                    .buttonStyle(.appToolbarCancel)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveAmountUpdate()
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                    .appSheetPrimaryButtonStyle()
                }
            }
            .appSheetBottomConfirmationAction(edition: true, action: saveAmountUpdate)
        }
        .macOSFixedSheet(width: 480, height: 560)
        .onAppear {
            if amountText.isEmpty {
                setAmount(service.amount)
            }
        }
    }

    private func select(_ amountUpdate: AmountUpdate) {
        setAmount(amountUpdate.amount)
        amountIsFocused = true
    }

    private func setAmount(_ value: Double) {
        amountText = formattedAmountInput(for: value)
    }

    private func parseAmount(_ value: String) -> Double? {
        Double(value.replacingOccurrences(of: ",", with: "."))
    }

    private func saveAmountUpdate() {
        service.amount = amount

        let amountUpdate = AmountUpdate(context: moc)
        amountUpdate.id = UUID()
        amountUpdate.amount = amount
        amountUpdate.updateDate = Date()
        amountUpdate.service = service
        try? self.moc.save()

        dismiss()
    }
}
