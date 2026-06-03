//
//  HomeCalendarMarker.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import SwiftUI

struct HomeCalendarMarker: View {
    let item: HomeCalendarItem
    let size: CGFloat
    var namespace: Namespace.ID?
    var isMatchedSource = false

    var body: some View {
        marker
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
            .modifier(HomeCalendarMarkerGeometry(id: item.id, namespace: namespace, isSource: isMatchedSource))
            .zIndex(isMatchedSource ? 2 : 1)
    }

    @ViewBuilder
    private var marker: some View {
        if let service = item.service {
            ServiceIconView(
                photoData: service.image,
                backgroundColor: service.wrappedColor,
                cornerRadius: size * 0.28
            )
        } else if let transaction = item.transaction {
            ContactAvatarView(
                imageData: transaction.contact?.avatarImage,
                emoji: transaction.contact?.wrappedEmoji ?? "🙂",
                size: size,
                cornerRadius: size * 0.28
            )
        } else {
            Image(systemName: item.isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .foregroundStyle(item.tint)
        }
    }
}

private struct HomeCalendarMarkerGeometry: ViewModifier {
    let id: String
    let namespace: Namespace.ID?
    let isSource: Bool

    func body(content: Content) -> some View {
        if let namespace {
            content.matchedGeometryEffect(id: "home-item-\(id)", in: namespace, properties: [.position, .size], anchor: .center, isSource: isSource)
        } else {
            content
        }
    }
}
