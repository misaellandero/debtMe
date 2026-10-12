//
//  AppAmountEntryField.swift
//  debtMe
//
//  Shared amount entry control used by forms that capture money values.
//

import SwiftUI

struct AppAmountEntryField: View {
    var title: LocalizedStringKey = "Amount"
    @Binding var amountText: String
    @Binding var isFocused: Bool
    @FocusState private var amountIsFocused: Bool

    init(
        title: LocalizedStringKey = "Amount",
        amountText: Binding<String>,
        isFocused: Binding<Bool> = .constant(false)
    ) {
        self.title = title
        self._amountText = amountText
        self._isFocused = isFocused
    }

    private var currencySymbol: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        return formatter.currencySymbol ?? "$"
    }

    private var sanitizedAmountBinding: Binding<String> {
        Binding(
            get: { amountText },
            set: { newValue in
                amountText = sanitizedAmountText(newValue)
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(currencySymbol)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.secondary)

                amountTextField
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.plain)
                    .focused($amountIsFocused)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.actionTint.opacity(amountIsFocused ? 0.7 : 0.18), lineWidth: 1.5)
            )
        }
        .onAppear {
            amountIsFocused = isFocused
        }
        .onChange(of: amountIsFocused) { _, newValue in
            isFocused = newValue
        }
        .onChange(of: isFocused) { _, newValue in
            amountIsFocused = newValue
        }
    }

    @ViewBuilder
    private var amountTextField: some View {
        #if os(iOS)
        TextField("0.00", text: sanitizedAmountBinding)
            .font(.system(size: 44, weight: .bold, design: .rounded))
            .keyboardType(.decimalPad)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        amountIsFocused = false
                    }
                    .font(.body)
                }
            }
        #else
        TextField("0.00", text: sanitizedAmountBinding)
            .font(.system(size: 44, weight: .bold, design: .rounded))
        #endif
    }

    private func sanitizedAmountText(_ value: String) -> String {
        var sanitized = ""
        var hasDecimalSeparator = false
        var fractionDigitCount = 0

        for character in value {
            if character.isNumber {
                if hasDecimalSeparator {
                    guard fractionDigitCount < 2 else { continue }
                    fractionDigitCount += 1
                }
                sanitized.append(character)
            } else if character == "." || character == "," {
                guard !hasDecimalSeparator else { continue }
                hasDecimalSeparator = true
                sanitized.append(".")
            }
        }

        return sanitized
    }
}

#Preview {
    @Previewable @State var amount = "199.00"

    AppAmountEntryField(amountText: $amount)
        .padding()
}
