//
//  DemoDataSeeder.swift
//  debtMe
//
//  Created by Codex on 10/06/26.
//

import CoreData
import Foundation

enum DemoDataSeeder {
    static func resetAndSeed(in context: NSManagedObjectContext) {
        context.performAndWait {
            deleteExistingData(in: context)

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            let family = makeLabel(name: "Family", color: 1, labelForService: false, in: context)
            let friends = makeLabel(name: "Friends", color: 5, labelForService: false, in: context)
            let subscriptions = makeLabel(name: "Subscriptions", color: 2, labelForService: true, in: context)
            let income = makeLabel(name: "Income", color: 3, labelForService: true, in: context)
            let credit = makeLabel(name: "Credit", color: 4, labelForService: true, in: context)

            let alex = makeContact(name: "Alex Rivera", emoji: "🧑🏽‍💻", label: friends, in: context)
            let sofia = makeContact(name: "Sofia Chen", emoji: "👩🏻‍🎨", label: friends, in: context)
            let maya = makeContact(name: "Maya Lopez", emoji: "👩🏽‍🍳", label: family, in: context)
            let marco = makeContact(name: "Marco Silva", emoji: "🧔🏻", label: family, in: context)

            makeTransaction(
                contact: alex,
                amount: 850,
                debt: true,
                description: "Dinner split",
                notes: "Demo balance for screenshots",
                due: offset(today, by: 2, calendar: calendar),
                in: context
            )
            makeTransaction(
                contact: sofia,
                amount: 420,
                debt: true,
                description: "Concert tickets",
                notes: "Due this week",
                due: offset(today, by: 5, calendar: calendar),
                in: context
            )
            makeTransaction(
                contact: maya,
                amount: 1_250,
                debt: false,
                description: "Travel booking",
                notes: "Family trip deposit",
                due: offset(today, by: 8, calendar: calendar),
                in: context
            )
            makeTransaction(
                contact: marco,
                amount: 700,
                debt: false,
                description: "Hardware store",
                notes: "Shared expense",
                due: offset(today, by: 12, calendar: calendar),
                in: context
            )

            makeService(name: "Payroll", amount: 20_000, expense: false, frequency: 2, day: 15, color: 3, label: income, in: context)
            makeService(name: "Freelance", amount: 6_500, expense: false, frequency: 3, day: 28, color: 1, label: income, in: context)
            makeService(name: "Rent", amount: 9_800, expense: true, frequency: 3, day: 1, color: 4, label: credit, in: context)
            makeService(name: "Credit Card", amount: 4_250, expense: true, frequency: 3, day: 14, color: 0, label: credit, in: context)
            makeService(name: "Apple Music", amount: 199, expense: true, frequency: 3, day: 15, color: 6, label: subscriptions, in: context)
            makeService(name: "Gym", amount: 649, expense: true, frequency: 3, day: 20, color: 2, label: subscriptions, in: context)
            makeService(name: "Internet", amount: 899, expense: true, frequency: 3, day: 25, color: 5, label: subscriptions, in: context)

            do {
                try context.save()
            } catch {
                assertionFailure("Unable to seed demo data: \(error.localizedDescription)")
            }
        }
    }

    private static func deleteExistingData(in context: NSManagedObjectContext) {
        ["Payment", "Transaction", "AmountUpdate", "Services", "Contact", "ContactLabel"].forEach { entityName in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let delete = NSBatchDeleteRequest(fetchRequest: request)
            _ = try? context.execute(delete)
        }
        context.reset()
    }

    private static func makeLabel(name: String, color: Int16, labelForService: Bool, in context: NSManagedObjectContext) -> ContactLabel {
        let label = ContactLabel(context: context)
        label.id = UUID()
        label.name = name
        label.color = color
        label.labelForService = labelForService
        return label
    }

    private static func makeContact(name: String, emoji: String, label: ContactLabel, in context: NSManagedObjectContext) -> Contact {
        let contact = Contact(context: context)
        contact.id = UUID()
        contact.name = name
        contact.emoji = emoji
        contact.label = label
        contact.sync = false
        contact.hideSettled = false
        return contact
    }

    private static func makeTransaction(
        contact: Contact,
        amount: Double,
        debt: Bool,
        description: String,
        notes: String,
        due: Date,
        in context: NSManagedObjectContext
    ) {
        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.amount = amount
        transaction.debt = debt
        transaction.des = description
        transaction.notes = notes
        transaction.dateCreation = Date()
        transaction.estimatedPaymentDate = due
        transaction.settled = false
        transaction.contact = contact
    }

    private static func makeService(
        name: String,
        amount: Double,
        expense: Bool,
        frequency: Int16,
        day: Int,
        color: Int16,
        label: ContactLabel,
        in context: NSManagedObjectContext
    ) {
        let service = Services(context: context)
        service.id = UUID()
        service.name = name
        service.des = "Demo item for screenshots"
        service.amount = amount
        service.expense = expense
        service.frequency = frequency
        service.frequency_date = date(day: day)
        service.business_day_adjustment = 0
        service.color = color
        service.label = label
    }

    private static func date(day: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? now
        let maxDay = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 28
        return calendar.date(from: DateComponents(year: year, month: month, day: min(day, maxDay))) ?? now
    }

    private static func offset(_ date: Date, by days: Int, calendar: Calendar) -> Date {
        calendar.date(byAdding: .day, value: days, to: date) ?? date
    }
}
