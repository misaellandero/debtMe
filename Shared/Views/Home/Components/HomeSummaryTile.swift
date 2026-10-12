//
//  HomeSummaryTile.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import SwiftUI

struct HomeSummaryTile: View {
    let title: LocalizedStringKey
    let amount: Double
    let systemImage: String
    let tint: Color
    var isCompact = false

    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 4 : 8) {
            Label(title, systemImage: systemImage)
                .font(AppTypography.brandHeadline)
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(amount.toCurrencyString())
                .font(isCompact ? AppTypography.headline : AppTypography.title)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(isCompact ? 8 : 12)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(tint.opacity(0.2), lineWidth: 1)
        )
    }
}
