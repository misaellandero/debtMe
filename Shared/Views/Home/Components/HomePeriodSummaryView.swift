//
//  HomePeriodSummaryView.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import SwiftUI

struct HomePeriodSummaryView: View {
    let title: String
    let incomeTotal: Double
    let expenseTotal: Double
    let balanceTotal: Double
    var isCompact = false

    var body: some View {
        VStack(alignment: .center, spacing: isCompact ? 8 : 12) {
            Text(title)
                .font((isCompact ? Font.subheadline : .headline).weight(.semibold))
                .multilineTextAlignment(.center)

            Text(balanceTotal.toCurrencyString())
                .font((isCompact ? Font.title2 : .largeTitle).weight(.bold))
                .foregroundStyle(balanceTotal >= 0 ? Color.primary : Color.red)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            HStack(spacing: 12) {
                HomeSummaryTile(
                    title: "Incoming",
                    amount: incomeTotal,
                    systemImage: "arrow.down.circle.fill",
                    tint: .blue,
                    isCompact: isCompact
                )

                HomeSummaryTile(
                    title: "Outgoing",
                    amount: expenseTotal,
                    systemImage: "arrow.up.circle.fill",
                    tint: .red,
                    isCompact: isCompact
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isCompact ? 2 : 6)
    }
}
