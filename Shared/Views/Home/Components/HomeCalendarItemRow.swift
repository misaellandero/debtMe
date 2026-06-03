//
//  HomeCalendarItemRow.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import SwiftUI

struct HomeCalendarItemRow: View {
    let item: HomeCalendarItem
    var namespace: Namespace.ID?
    var usesServiceBackground = false

    var body: some View {
        let isPaid = item.currentIsPaid

        HStack(spacing: 12) {
            HomeCalendarMarker(item: item, size: 44, namespace: namespace, isMatchedSource: true)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(1)
                    .strikethrough(isPaid, color: usesServiceBackground ? .white.opacity(0.8) : .secondary)

                Label(item.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(usesServiceBackground ? Color.white.opacity(0.78) : Color.secondary)
                    .lineLimit(1)

                Text(item.subtitle)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(usesServiceBackground ? Color.white.opacity(0.78) : Color.secondary)
                    .lineLimit(1)

                if isPaid {
                    Text("Paid")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(usesServiceBackground ? Color.white : Color.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background((usesServiceBackground ? Color.white.opacity(0.18) : Color.green.opacity(0.12)), in: Capsule())
                }
            }

            Spacer(minLength: 8)

            Text((item.isIncome ? "" : "-") + item.amount.toCurrencyString())
                .font(.headline.weight(.bold))
                .foregroundStyle(usesServiceBackground ? Color.white : (item.isIncome ? .blue : .red))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(usesServiceBackground ? Color.white : Color.primary)
        .opacity(isPaid ? 0.68 : 1)
        .padding(.vertical, 6)
    }
}
