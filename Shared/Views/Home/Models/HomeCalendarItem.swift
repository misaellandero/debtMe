//
//  HomeCalendarItem.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import SwiftUI

struct HomeCalendarItem: Identifiable {
    let id: String
    let date: Date
    let title: String
    let subtitle: String
    let amount: Double
    let isIncome: Bool
    let tint: Color
    let service: Services?
    let transaction: Transaction?

    init(occurrence: ServiceOccurrence) {
        let service = occurrence.service
        id = "service-\(occurrence.id)"
        date = occurrence.date
        title = service.wrappedName
        subtitle = "Service"
        amount = service.amount
        isIncome = !service.expense
        tint = service.wrappedColor
        self.service = service
        transaction = nil
    }

    init(transaction: Transaction, date: Date) {
        id = "transaction-\(transaction.objectID.uriRepresentation().absoluteString)"
        self.date = date
        title = transaction.contactName
        subtitle = transaction.debt ? "They owe me" : "I owe them"
        amount = max(0, transaction.amount - transaction.totalPayments)
        isIncome = transaction.debt
        tint = transaction.debt ? .blue : .red
        service = nil
        self.transaction = transaction
    }
}
