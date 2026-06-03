//
//  HomeDetailSheet.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import SwiftUI

struct HomeDetailSheet: View {
    let title: String
    let items: [HomeCalendarItem]

    var body: some View {
        NavigationStack {
            List {
                if items.isEmpty {
                    Text("No scheduled items in this period")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(items) { item in
                        HomeCalendarItemNavigationRow(item: item)
                    }
                }
            }
            .navigationTitle(title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
