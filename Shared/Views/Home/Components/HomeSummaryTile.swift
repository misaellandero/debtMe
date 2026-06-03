//
//  HomeSummaryTile.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import SwiftUI

struct HomeSummaryTile: View {
    let title: String
    let amount: Double
    let systemImage: String
    let tint: Color
    var isCompact = false

    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 4 : 8) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(amount.toCurrencyString())
                .font((isCompact ? Font.callout : .title3).weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(isCompact ? 8 : 12)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
