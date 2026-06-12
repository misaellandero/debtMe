import AppIntents
import CoreData
import SwiftUI
import WidgetKit

private enum WidgetShared {
    static let appGroupIdentifier = "group.mx.landercorp.debtMe"
    static let privacyKey = "debtMeWidgetUsesPercentages"
    static let paidOccurrencesKey = "paidServiceOccurrenceIDs"
}

struct ToggleWidgetPrivacyIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Privacy"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: WidgetShared.appGroupIdentifier) ?? .standard
        defaults.set(!defaults.bool(forKey: WidgetShared.privacyKey), forKey: WidgetShared.privacyKey)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct DebtFlowEntry: TimelineEntry {
    let date: Date
    let snapshot: DebtFlowSnapshot
}

struct PeopleDebtEntry: TimelineEntry {
    let date: Date
    let people: [PeopleDebtSnapshot]
}

struct DebtFlowSnapshot {
    var incoming: Double
    var outgoing: Double
    var usesPercentages: Bool
    var days: [DayDebtSnapshot]
    var items: [DebtWidgetItem]

    var balance: Double {
        incoming - outgoing
    }
}

struct DayDebtSnapshot: Identifiable {
    let id: Date
    let date: Date
    let incoming: Double
    let outgoing: Double

    var hasActivity: Bool {
        incoming > 0 || outgoing > 0
    }
}

struct DebtWidgetItem: Identifiable {
    let id: String
    let date: Date
    let title: String
    let subtitle: String
    let amount: Double
    let isIncome: Bool
}

struct PeopleDebtSnapshot: Identifiable {
    let id: String
    let name: String
    let symbol: String
    let balance: Double

    var isPositive: Bool {
        balance >= 0
    }
}

struct DebtFlowProvider: TimelineProvider {
    func placeholder(in context: Context) -> DebtFlowEntry {
        DebtFlowEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (DebtFlowEntry) -> Void) {
        completion(DebtFlowEntry(date: .now, snapshot: DebtWidgetRepository().debtFlowSnapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DebtFlowEntry>) -> Void) {
        let entry = DebtFlowEntry(date: .now, snapshot: DebtWidgetRepository().debtFlowSnapshot())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1_800)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct PeopleDebtProvider: TimelineProvider {
    func placeholder(in context: Context) -> PeopleDebtEntry {
        PeopleDebtEntry(date: .now, people: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (PeopleDebtEntry) -> Void) {
        completion(PeopleDebtEntry(date: .now, people: DebtWidgetRepository().peopleDebtSnapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PeopleDebtEntry>) -> Void) {
        let entry = PeopleDebtEntry(date: .now, people: DebtWidgetRepository().peopleDebtSnapshot())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1_800)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct DebtFlowWidgetView: View {
    let entry: DebtFlowEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            summary
            calendarStrip
            itemList
        }
        .padding(14)
        .containerBackground(.background, for: .widget)
    }

    private var header: some View {
        HStack {
            Text("Debt Flow")
                .font(.headline)
            Spacer()
            Button(intent: ToggleWidgetPrivacyIntent()) {
                Image(systemName: entry.snapshot.usesPercentages ? "percent" : "dollarsign")
                    .font(.caption.bold())
                    .frame(width: 28, height: 24)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
    }

    private var summary: some View {
        HStack(spacing: 8) {
            SummaryPill(title: "Incoming", value: amountText(entry.snapshot.incoming, total: entry.snapshot.incoming), color: .blue)
            SummaryPill(title: "Outgoing", value: amountText(entry.snapshot.outgoing, total: max(entry.snapshot.incoming, entry.snapshot.outgoing)), color: .red)
            SummaryPill(title: "Balance", value: amountText(entry.snapshot.balance, total: max(entry.snapshot.incoming, entry.snapshot.outgoing)), color: entry.snapshot.balance >= 0 ? .green : .red)
        }
    }

    private var calendarStrip: some View {
        HStack(spacing: 4) {
            ForEach(entry.snapshot.days.prefix(7)) { day in
                VStack(spacing: 4) {
                    Text(day.date, format: .dateTime.day())
                        .font(.caption2.bold())
                    Circle()
                        .fill(day.hasActivity ? (day.incoming >= day.outgoing ? Color.blue : Color.red) : Color.secondary.opacity(0.25))
                        .frame(width: 7, height: 7)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(day.hasActivity ? Color.secondary.opacity(0.14) : Color.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var itemList: some View {
        VStack(spacing: 7) {
            ForEach(entry.snapshot.items.prefix(3)) { item in
                HStack(spacing: 8) {
                    Image(systemName: item.isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .foregroundStyle(item.isIncome ? .blue : .red)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(item.title)
                            .font(.caption.bold())
                            .lineLimit(1)
                        Text(item.subtitle)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text(amountText(item.amount, total: max(entry.snapshot.incoming, entry.snapshot.outgoing)))
                        .font(.caption.bold())
                        .foregroundStyle(item.isIncome ? .blue : .red)
                }
            }
        }
    }

    private func amountText(_ amount: Double, total: Double) -> String {
        if entry.snapshot.usesPercentages {
            let base = max(abs(total), 1)
            return amount.formatted(.percent.precision(.fractionLength(0)).scale(1 / base))
        }
        return amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD").notation(.compactName))
    }
}

struct PeopleDebtWidgetView: View {
    let entry: PeopleDebtEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("People Debts")
                .font(.headline)

            ForEach(entry.people.prefix(5)) { person in
                HStack(spacing: 8) {
                    Text(person.symbol)
                        .font(.title3)
                        .frame(width: 30, height: 30)
                        .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                    Text(person.name)
                        .font(.caption.bold())
                        .lineLimit(1)
                    Spacer()
                    Text(person.balance.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD").notation(.compactName)))
                        .font(.caption.bold())
                        .foregroundStyle(person.isPositive ? .blue : .red)
                }
            }

            if entry.people.isEmpty {
                ContentUnavailableView("No People Debts", systemImage: "person.2")
                    .font(.caption)
            }
        }
        .padding(14)
        .containerBackground(.background, for: .widget)
    }
}

private struct SummaryPill: View {
    let title: LocalizedStringKey
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(color)
            Text(value)
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(color.opacity(0.14), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct DebtFlowWidget: Widget {
    let kind = "DebtFlowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DebtFlowProvider()) { entry in
            DebtFlowWidgetView(entry: entry)
        }
        .configurationDisplayName("Debt Flow")
        .description("Calendar and list overview for incoming and outgoing money.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct PeopleDebtWidget: Widget {
    let kind = "PeopleDebtWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PeopleDebtProvider()) { entry in
            PeopleDebtWidgetView(entry: entry)
        }
        .configurationDisplayName("People Debts")
        .description("Shows the current balances for people who owe you or that you owe.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct DebtMeWidgetsBundle: WidgetBundle {
    var body: some Widget {
        DebtFlowWidget()
        PeopleDebtWidget()
    }
}

private final class DebtWidgetRepository {
    private let calendar = Calendar.current

    func debtFlowSnapshot() -> DebtFlowSnapshot {
        let today = calendar.startOfDay(for: .now)
        let end = calendar.date(byAdding: .day, value: 13, to: today) ?? today
        let range = DateInterval(start: today, end: calendar.date(byAdding: .day, value: 1, to: end)?.addingTimeInterval(-1) ?? end)
        let items = serviceItems(in: range) + transactionItems(in: range)
        let activeItems = items.sorted { $0.date < $1.date }
        let incoming = activeItems.filter(\.isIncome).map(\.amount).reduce(0, +)
        let outgoing = activeItems.filter { !$0.isIncome }.map(\.amount).reduce(0, +)
        let days = (0..<14).compactMap { offset -> DayDebtSnapshot? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { return nil }
            let dayItems = activeItems.filter { calendar.isDate($0.date, inSameDayAs: date) }
            return DayDebtSnapshot(
                id: date,
                date: date,
                incoming: dayItems.filter(\.isIncome).map(\.amount).reduce(0, +),
                outgoing: dayItems.filter { !$0.isIncome }.map(\.amount).reduce(0, +)
            )
        }

        return DebtFlowSnapshot(
            incoming: incoming,
            outgoing: outgoing,
            usesPercentages: userDefaults.bool(forKey: WidgetShared.privacyKey),
            days: days,
            items: activeItems.isEmpty ? DebtFlowSnapshot.placeholder.items : activeItems
        )
    }

    func peopleDebtSnapshot() -> [PeopleDebtSnapshot] {
        guard let context = makeContext() else { return .placeholder }
        let request = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            return try context.fetch(request).compactMap { contact in
                let name = contact.value(forKey: "name") as? String ?? "Unknown"
        let symbol = contact.value(forKey: "emoji") as? String ?? "A"
                let transactions = contact.value(forKey: "transactions") as? Set<NSManagedObject> ?? []
                let balance = transactions.reduce(0) { partial, transaction in
                    guard !(transaction.value(forKey: "settled") as? Bool ?? false) else { return partial }
                    let amount = transaction.value(forKey: "amount") as? Double ?? 0
                    let payments = transactionPaymentsTotal(transaction)
                    let remaining = max(0, amount - payments)
                    let theyOweMe = transaction.value(forKey: "debt") as? Bool ?? true
                    return partial + (theyOweMe ? remaining : -remaining)
                }
                guard balance != 0 else { return nil }
                return PeopleDebtSnapshot(id: contact.objectID.uriRepresentation().absoluteString, name: name, symbol: symbol, balance: balance)
            }
            .sorted { abs($0.balance) > abs($1.balance) }
        } catch {
            return .placeholder
        }
    }

    private func serviceItems(in range: DateInterval) -> [DebtWidgetItem] {
        guard let context = makeContext() else { return [] }
        let request = NSFetchRequest<NSManagedObject>(entityName: "Services")

        do {
            return try context.fetch(request).flatMap { service in
                serviceOccurrences(for: service, in: range).compactMap { date in
                    let id = occurrenceID(for: service, date: date)
                    guard !paidOccurrenceIDs.contains(id) else { return nil }
                    let name = service.value(forKey: "name") as? String ?? "Service"
                    let amount = service.value(forKey: "amount") as? Double ?? 0
                    let isExpense = service.value(forKey: "expense") as? Bool ?? true
                    return DebtWidgetItem(
                        id: id,
                        date: date,
                        title: name,
                        subtitle: "Service",
                        amount: amount,
                        isIncome: !isExpense
                    )
                }
            }
        } catch {
            return []
        }
    }

    private func transactionItems(in range: DateInterval) -> [DebtWidgetItem] {
        guard let context = makeContext() else { return [] }
        let request = NSFetchRequest<NSManagedObject>(entityName: "Transaction")

        do {
            return try context.fetch(request).compactMap { transaction in
                guard !(transaction.value(forKey: "settled") as? Bool ?? false) else { return nil }
                let date = transaction.value(forKey: "estimatedPaymentDate") as? Date ?? .now
                guard range.contains(date) else { return nil }
                let amount = max(0, (transaction.value(forKey: "amount") as? Double ?? 0) - transactionPaymentsTotal(transaction))
                guard amount > 0 else { return nil }
                let contact = transaction.value(forKey: "contact") as? NSManagedObject
                let title = contact?.value(forKey: "name") as? String ?? "Contact"
                let isIncome = transaction.value(forKey: "debt") as? Bool ?? true
                return DebtWidgetItem(
                    id: transaction.objectID.uriRepresentation().absoluteString,
                    date: date,
                    title: title,
                    subtitle: isIncome ? "They owe me" : "I owe them",
                    amount: amount,
                    isIncome: isIncome
                )
            }
        } catch {
            return []
        }
    }

    private func transactionPaymentsTotal(_ transaction: NSManagedObject) -> Double {
        let payments = transaction.value(forKey: "payments") as? Set<NSManagedObject> ?? []
        return payments
            .filter { !($0.value(forKey: "planned") as? Bool ?? false) }
            .map { $0.value(forKey: "amount") as? Double ?? 0 }
            .reduce(0, +)
    }

    private func serviceOccurrences(for service: NSManagedObject, in range: DateInterval) -> [Date] {
        let frequency = service.value(forKey: "frequency") as? Int16 ?? 0
        let anchor = calendar.startOfDay(for: service.value(forKey: "frequency_date") as? Date ?? .now)
        let recurrenceEnd = service.value(forKey: "recurrence_end_date") as? Date
        let endLimit = recurrenceEnd.map { min(range.end, calendar.date(bySettingHour: 23, minute: 59, second: 59, of: $0) ?? $0) } ?? range.end
        guard endLimit >= range.start, range.end >= anchor else { return [] }
        let normalizedRange = DateInterval(start: calendar.startOfDay(for: range.start), end: endLimit)

        switch frequency {
        case 0:
            return strideDays(from: max(anchor, normalizedRange.start), through: normalizedRange.end, step: 1)
        case 1:
            return matchingWeekdays(anchor: anchor, in: normalizedRange)
        case 2:
            return semiMonthlyDates(anchor: anchor, in: normalizedRange)
        case 3:
            return monthlyDates(anchor: anchor, in: normalizedRange, monthStep: 1)
        case 4:
            return monthlyDates(anchor: anchor, in: normalizedRange, monthStep: 3)
        case 5:
            return monthlyDates(anchor: anchor, in: normalizedRange, monthStep: 6)
        case 6:
            return monthlyDates(anchor: anchor, in: normalizedRange, monthStep: 12)
        case 7:
            return normalizedRange.contains(anchor) ? [adjustedForBusinessDay(anchor, service: service)] : []
        case 8:
            return lastDayOfMonthDates(anchor: anchor, in: normalizedRange, service: service)
        default:
            return []
        }
    }

    private func strideDays(from start: Date, through end: Date, step: Int) -> [Date] {
        var dates: [Date] = []
        var current = calendar.startOfDay(for: start)
        while current <= end {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: step, to: current) ?? current.addingTimeInterval(86_400)
        }
        return dates
    }

    private func matchingWeekdays(anchor: Date, in range: DateInterval) -> [Date] {
        let weekday = calendar.component(.weekday, from: anchor)
        return strideDays(from: range.start, through: range.end, step: 1)
            .filter { $0 >= anchor && calendar.component(.weekday, from: $0) == weekday }
    }

    private func semiMonthlyDates(anchor: Date, in range: DateInterval) -> [Date] {
        monthStarts(in: range).flatMap { monthStart -> [Date] in
            let year = calendar.component(.year, from: monthStart)
            let month = calendar.component(.month, from: monthStart)
            let lastDay = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
            return [15, lastDay].compactMap { day in
                calendar.date(from: DateComponents(year: year, month: month, day: day))
            }
            .filter { $0 >= anchor && range.contains($0) }
        }
    }

    private func monthlyDates(anchor: Date, in range: DateInterval, monthStep: Int) -> [Date] {
        let anchorDay = calendar.component(.day, from: anchor)
        let anchorMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: anchor)) ?? anchor
        return monthStarts(in: range).compactMap { monthStart in
            let diff = calendar.dateComponents([.month], from: anchorMonthStart, to: monthStart).month ?? 0
            guard diff >= 0, diff % monthStep == 0 else { return nil }
            let day = min(anchorDay, calendar.range(of: .day, in: .month, for: monthStart)?.count ?? anchorDay)
            let date = calendar.date(from: DateComponents(
                year: calendar.component(.year, from: monthStart),
                month: calendar.component(.month, from: monthStart),
                day: day
            ))
            return date.flatMap { $0 >= anchor && range.contains($0) ? $0 : nil }
        }
    }

    private func lastDayOfMonthDates(anchor: Date, in range: DateInterval, service: NSManagedObject) -> [Date] {
        monthStarts(in: range).compactMap { monthStart in
            let day = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
            let date = calendar.date(from: DateComponents(
                year: calendar.component(.year, from: monthStart),
                month: calendar.component(.month, from: monthStart),
                day: day
            ))
            return date.flatMap { $0 >= anchor && range.contains($0) ? adjustedForBusinessDay($0, service: service) : nil }
        }
    }

    private func monthStarts(in range: DateInterval) -> [Date] {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: range.start)) ?? range.start
        let end = calendar.date(from: calendar.dateComponents([.year, .month], from: range.end)) ?? range.end
        var months: [Date] = []
        var current = start
        while current <= end {
            months.append(current)
            current = calendar.date(byAdding: .month, value: 1, to: current) ?? current.addingTimeInterval(2_592_000)
        }
        return months
    }

    private func adjustedForBusinessDay(_ date: Date, service: NSManagedObject) -> Date {
        let adjustment = service.value(forKey: "business_day_adjustment") as? Int16 ?? 0
        guard adjustment != 0 else { return date }
        var current = date
        while calendar.isDateInWeekend(current) {
            current = calendar.date(byAdding: .day, value: adjustment == 1 ? -1 : 1, to: current) ?? current
        }
        return current
    }

    private func occurrenceID(for service: NSManagedObject, date: Date) -> String {
        let id = service.value(forKey: "id") as? UUID ?? UUID()
        return "\(id.uuidString)-\(date.timeIntervalSince1970)"
    }

    private var paidOccurrenceIDs: Set<String> {
        Set(userDefaults.stringArray(forKey: WidgetShared.paidOccurrencesKey) ?? [])
    }

    private var userDefaults: UserDefaults {
        UserDefaults(suiteName: WidgetShared.appGroupIdentifier) ?? .standard
    }

    private func makeContext() -> NSManagedObjectContext? {
        guard let modelURL = Bundle.main.url(forResource: "debtMe", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL),
              let storeURL = sharedStoreURL else {
            return nil
        }

        let container = NSPersistentContainer(name: "debtMe", managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        return loadError == nil ? container.viewContext : nil
    }

    private var sharedStoreURL: URL? {
        let storeDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: WidgetShared.appGroupIdentifier)
        #if BETA_DEMO_DATA
        return storeDirectory?.appendingPathComponent("debtMe-beta-demo.sqlite")
        #else
        return storeDirectory?.appendingPathComponent("debtMe.sqlite")
        #endif
    }
}

private extension DebtFlowSnapshot {
    static var placeholder: DebtFlowSnapshot {
        let today = Calendar.current.startOfDay(for: .now)
        let days = (0..<7).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: today) ?? today
            return DayDebtSnapshot(id: date, date: date, incoming: offset == 2 ? 20_000 : 0, outgoing: [1, 4, 5].contains(offset) ? 1_200 : 0)
        }
        return DebtFlowSnapshot(
            incoming: 20_000,
            outgoing: 3_600,
            usesPercentages: false,
            days: days,
            items: [
                DebtWidgetItem(id: "rent", date: today, title: "Rent", subtitle: "Service", amount: 9_500, isIncome: false),
                DebtWidgetItem(id: "payroll", date: today, title: "Payroll", subtitle: "Service", amount: 20_000, isIncome: true),
                DebtWidgetItem(id: "alex", date: today, title: "Alex Rivera", subtitle: "They owe me", amount: 850, isIncome: true)
            ]
        )
    }
}

private extension Array where Element == PeopleDebtSnapshot {
    static var placeholder: [PeopleDebtSnapshot] {
        [
            PeopleDebtSnapshot(id: "alex", name: "Alex Rivera", symbol: "A", balance: 850),
            PeopleDebtSnapshot(id: "sofia", name: "Sofia Chen", symbol: "S", balance: -420),
            PeopleDebtSnapshot(id: "maya", name: "Maya Lopez", symbol: "M", balance: 1_200)
        ]
    }
}
