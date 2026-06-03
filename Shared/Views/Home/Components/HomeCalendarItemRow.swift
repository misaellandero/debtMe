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

    var body: some View {
        let usesServiceBackground = item.service != nil

        HStack(spacing: 12) {
            HomeCalendarMarker(item: item, size: 44, namespace: namespace, isMatchedSource: true)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(1)

                Label(item.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(usesServiceBackground ? Color.white.opacity(0.78) : Color.secondary)
                    .lineLimit(1)

                Text(item.subtitle)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(usesServiceBackground ? Color.white.opacity(0.78) : Color.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text((item.isIncome ? "" : "-") + item.amount.toCurrencyString())
                .font(.headline.weight(.bold))
                .foregroundStyle(usesServiceBackground ? Color.white : (item.isIncome ? .blue : .red))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(usesServiceBackground ? Color.white : Color.primary)
        .padding(.vertical, 6)
    }
}
