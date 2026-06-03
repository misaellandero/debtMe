//
//  HomeEmptyStateView.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import SwiftUI

struct HomeEmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(.pig)
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 84)
            Text("No scheduled items")
                .font(.headline)
            Text("Services and people transactions with dates will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }
}
