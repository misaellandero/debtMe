import AppIntents
import CoreData
import ImageIO
import SwiftUI
import UniformTypeIdentifiers
import WidgetKit

private enum WidgetShared {
    static var appGroupIdentifier: String {
        #if BETA_DEMO_DATA
        return "group.mx.landercorp.debtMe.beta"
        #else
        return "group.mx.landercorp.debtMe"
        #endif
    }
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

enum WidgetDateRangeOption: String, AppEnum {
    case week
    case twoWeeks
    case month
    case twoMonths

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Date Range"
    static var caseDisplayRepresentations: [WidgetDateRangeOption: DisplayRepresentation] = [
        .week: "Next 7 days",
        .twoWeeks: "Next 14 days",
        .month: "Next 30 days",
        .twoMonths: "Next 60 days"
    ]

    var days: Int {
        switch self {
        case .week: 7
        case .twoWeeks: 14
        case .month: 30
        case .twoMonths: 60
        }
    }
}

struct DebtWidgetRangeIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Date Range"
    static var description = IntentDescription("Choose how many days ahead the widget shows.")

    @Parameter(title: "Date Range", default: .twoWeeks)
    var dateRange: WidgetDateRangeOption
}

struct DebtFlowEntry: TimelineEntry {
    let date: Date
    let snapshot: DebtFlowSnapshot
}

struct PeopleDebtEntry: TimelineEntry {
    let date: Date
    let people: [PeopleDebtSnapshot]
}

struct UpcomingPaymentsEntry: TimelineEntry {
    let date: Date
    let items: [DebtWidgetItem]
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
    let source: DebtWidgetItemSource
    var imageData: Data? = nil
    var emoji: String? = nil
}

enum DebtWidgetItemSource {
    case service
    case person
}

struct PeopleDebtSnapshot: Identifiable {
    let id: String
    let name: String
    let symbol: String
    let balance: Double
    var imageData: Data? = nil

    var isPositive: Bool {
        balance >= 0
    }
}

private func widgetRefreshDate() -> Date {
    Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1_800)
}

struct DebtFlowProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> DebtFlowEntry {
        DebtFlowEntry(date: .now, snapshot: .placeholder)
    }

    func snapshot(for configuration: DebtWidgetRangeIntent, in context: Context) async -> DebtFlowEntry {
        DebtFlowEntry(date: .now, snapshot: DebtWidgetRepository().debtFlowSnapshot(days: configuration.dateRange.days))
    }

    func timeline(for configuration: DebtWidgetRangeIntent, in context: Context) async -> Timeline<DebtFlowEntry> {
        let entry = DebtFlowEntry(date: .now, snapshot: DebtWidgetRepository().debtFlowSnapshot(days: configuration.dateRange.days))
        return Timeline(entries: [entry], policy: .after(widgetRefreshDate()))
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
        completion(Timeline(entries: [entry], policy: .after(widgetRefreshDate())))
    }
}

struct UpcomingPaymentsProvider: AppIntentTimelineProvider {
    var filter: DebtWidgetItemSource? = nil

    func placeholder(in context: Context) -> UpcomingPaymentsEntry {
        UpcomingPaymentsEntry(date: .now, items: .placeholderUpcoming)
    }

    func snapshot(for configuration: DebtWidgetRangeIntent, in context: Context) async -> UpcomingPaymentsEntry {
        UpcomingPaymentsEntry(date: .now, items: items(for: configuration))
    }

    func timeline(for configuration: DebtWidgetRangeIntent, in context: Context) async -> Timeline<UpcomingPaymentsEntry> {
        let entry = UpcomingPaymentsEntry(date: .now, items: items(for: configuration))
        return Timeline(entries: [entry], policy: .after(widgetRefreshDate()))
    }

    private func items(for configuration: DebtWidgetRangeIntent) -> [DebtWidgetItem] {
        DebtWidgetRepository().upcomingPaymentsSnapshot(days: configuration.dateRange.days, filter: filter)
    }
}

struct DebtFlowWidgetView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    let entry: DebtFlowEntry

    var body: some View {
        VStack(alignment: .leading, spacing: widgetFamily == .systemMedium ? 8 : 10) {
            header
            summary
            calendarStrip
            itemList
        }
        .padding(widgetFamily == .systemMedium ? 12 : 14)
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
        HStack(spacing: widgetFamily == .systemMedium ? 6 : 8) {
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
        VStack(spacing: widgetFamily == .systemMedium ? 5 : 7) {
            ForEach(entry.snapshot.items.prefix(widgetFamily == .systemMedium ? 2 : 4)) { item in
                HStack(spacing: 8) {
                    WidgetItemIcon(item: item, size: 24, compact: true)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(item.title)
                            .font(.caption.bold())
                            .lineLimit(1)
                        Text(paymentCountdownText(for: item.date))
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
    @Environment(\.widgetFamily) private var widgetFamily
    let entry: PeopleDebtEntry

    var body: some View {
        VStack(alignment: .leading, spacing: widgetFamily == .systemSmall ? 7 : 10) {
            Text("People Debts")
                .font(.headline)

            ForEach(entry.people.prefix(itemLimit)) { person in
                HStack(spacing: 8) {
                    if let imageData = person.imageData, let image = widgetImage(from: imageData) {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: iconSize, height: iconSize)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Text(person.symbol)
                            .font(widgetFamily == .systemSmall ? .caption.bold() : .title3)
                            .frame(width: iconSize, height: iconSize)
                            .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                    }
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
        .padding(widgetFamily == .systemSmall ? 10 : 14)
        .containerBackground(.background, for: .widget)
    }

    private var itemLimit: Int {
        widgetFamily == .systemSmall ? 3 : 5
    }

    private var iconSize: CGFloat {
        widgetFamily == .systemSmall ? 24 : 30
    }
}

struct UpcomingPaymentsWidgetView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    let entry: UpcomingPaymentsEntry
    var title: LocalizedStringKey = "Upcoming Payments"
    var subtitleText: LocalizedStringKey = "People and services"
    var itemSource: DebtWidgetItemSource? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            header
            itemList
            if entry.items.isEmpty {
                ContentUnavailableView("No Upcoming Payments", systemImage: "calendar.badge.checkmark")
                    .font(.caption)
            }
        }
        .padding(padding)
        .containerBackground(.background, for: .widget)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            if widgetFamily != .systemSmall {
                Text(subtitleText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var itemList: some View {
        VStack(spacing: spacing) {
            ForEach(entry.items.prefix(itemLimit)) { item in
                UpcomingPaymentRow(item: item, compact: widgetFamily == .systemSmall)
            }
        }
    }

    private var itemLimit: Int {
        switch widgetFamily {
        case .systemSmall: itemSource == .person ? 2 : 3
        case .systemLarge: 8
        default: 5
        }
    }

    private var padding: CGFloat {
        widgetFamily == .systemSmall ? 10 : 14
    }

    private var spacing: CGFloat {
        widgetFamily == .systemSmall ? 7 : 9
    }
}

private func paymentCountdownText(for date: Date) -> String {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    let target = calendar.startOfDay(for: date)
    let days = calendar.dateComponents([.day], from: today, to: target).day ?? 0
    switch days {
    case ..<0:
        let overdue = -days
        return String(localized: "Overdue by \(overdue) days")
    case 0:
        return String(localized: "Payment today")
    case 1:
        return String(localized: "Payment tomorrow")
    default:
        return String(localized: "Payment in \(days) days")
    }
}

private struct WidgetItemIcon: View {
    let item: DebtWidgetItem
    let size: CGFloat
    var compact: Bool = false

    var body: some View {
        Group {
            if let imageData = item.imageData, let image = widgetImage(from: imageData) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else if item.source == .person, let emoji = item.emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(compact ? .caption : .body)
                    .frame(width: size, height: size)
                    .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: fallbackSymbol)
                    .font(compact ? .caption.bold() : .callout.bold())
                    .foregroundStyle(item.isIncome ? .blue : .red)
                    .frame(width: size, height: size)
                    .background((item.isIncome ? Color.blue : Color.red).opacity(0.13), in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var fallbackSymbol: String {
        item.source == .service ? "calendar.badge.clock" : (item.isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
    }
}

private func widgetImage(from data: Data) -> Image? {
    #if canImport(UIKit)
    guard let image = UIImage(data: data) else { return nil }
    return Image(uiImage: image)
    #elseif canImport(AppKit)
    guard let image = NSImage(data: data) else { return nil }
    return Image(nsImage: image)
    #else
    return nil
    #endif
}

private struct UpcomingPaymentRow: View {
    let item: DebtWidgetItem
    let compact: Bool

    var body: some View {
        if compact {
            HStack(alignment: .center, spacing: 8) {
                WidgetItemIcon(item: item, size: iconSize, compact: true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.caption.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    HStack(spacing: 4) {
                        Text(shortDate)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)

                        Text(amount)
                            .font(.caption2.bold())
                            .foregroundStyle(item.isIncome ? .blue : .red)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            HStack(spacing: 9) {
                WidgetItemIcon(item: item, size: iconSize, compact: false)

                VStack(alignment: .leading, spacing: 1) {
                    Text(item.title)
                        .font(.caption.bold())
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Text(amount)
                    .font(.caption.bold())
                    .foregroundStyle(item.isIncome ? .blue : .red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
    }

    private var subtitle: String {
        let countdown = paymentCountdownText(for: item.date)
        if compact {
            return countdown
        }
        let date = item.date.formatted(.dateTime.month(.abbreviated).day())
        return "\(date) · \(countdown)"
    }

    private var amount: String {
        item.amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD").notation(.compactName))
    }

    private var shortDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(item.date) {
            return String(localized: "Today")
        }
        if calendar.isDateInTomorrow(item.date) {
            return String(localized: "Tomorrow")
        }
        return item.date.formatted(.dateTime.month(.abbreviated).day())
    }

    private var iconSize: CGFloat {
        compact ? 28 : 32
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
        AppIntentConfiguration(kind: kind, intent: DebtWidgetRangeIntent.self, provider: DebtFlowProvider()) { entry in
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

struct UpcomingPaymentsWidget: Widget {
    let kind = "UpcomingPaymentsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: DebtWidgetRangeIntent.self, provider: UpcomingPaymentsProvider()) { entry in
            UpcomingPaymentsWidgetView(entry: entry, title: "DebtMe", subtitleText: "People and services")
        }
        .configurationDisplayName("DebtMe")
        .description("Shows upcoming payments from people and services together.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct ServicesPaymentsWidget: Widget {
    let kind = "ServicesPaymentsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: DebtWidgetRangeIntent.self, provider: UpcomingPaymentsProvider(filter: .service)) { entry in
            UpcomingPaymentsWidgetView(entry: entry, title: "Services", subtitleText: "Upcoming service payments", itemSource: .service)
        }
        .configurationDisplayName("Services")
        .description("Shows upcoming payments from services only.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct ContactsPaymentsWidget: Widget {
    let kind = "ContactsPaymentsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: DebtWidgetRangeIntent.self, provider: UpcomingPaymentsProvider(filter: .person)) { entry in
            UpcomingPaymentsWidgetView(entry: entry, title: "Contacts", subtitleText: "Upcoming payments from people", itemSource: .person)
        }
        .configurationDisplayName("Contacts")
        .description("Shows upcoming payments from people only.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct DebtMeWidgetsBundle: WidgetBundle {
    var body: some Widget {
        ContactsPaymentsWidget()
        ServicesPaymentsWidget()
        UpcomingPaymentsWidget()
    }
}

private final class DebtWidgetRepository {
    private let calendar = Calendar.current

    func debtFlowSnapshot(days rangeDays: Int = 14) -> DebtFlowSnapshot {
        let rangeDays = max(1, rangeDays)
        let today = calendar.startOfDay(for: .now)
        let end = calendar.date(byAdding: .day, value: rangeDays - 1, to: today) ?? today
        let range = DateInterval(start: today, end: calendar.date(byAdding: .day, value: 1, to: end)?.addingTimeInterval(-1) ?? end)
        let items = serviceItems(in: range) + transactionItems(in: range)
        let activeItems = items.sorted { $0.date < $1.date }
        let incoming = activeItems.filter(\.isIncome).map(\.amount).reduce(0, +)
        let outgoing = activeItems.filter { !$0.isIncome }.map(\.amount).reduce(0, +)
        let days = (0..<rangeDays).compactMap { offset -> DayDebtSnapshot? in
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
                return PeopleDebtSnapshot(
                    id: contact.objectID.uriRepresentation().absoluteString,
                    name: name,
                    symbol: symbol,
                    balance: balance,
                    imageData: thumbnailData(from: contact.value(forKey: "avatarImage") as? Data)
                )
            }
            .sorted { abs($0.balance) > abs($1.balance) }
        } catch {
            return .placeholder
        }
    }

    func upcomingPaymentsSnapshot(days rangeDays: Int = 45, filter: DebtWidgetItemSource? = nil) -> [DebtWidgetItem] {
        let rangeDays = max(1, rangeDays)
        let today = calendar.startOfDay(for: .now)
        let end = calendar.date(byAdding: .day, value: rangeDays - 1, to: today) ?? today
        let range = DateInterval(start: today, end: calendar.date(byAdding: .day, value: 1, to: end)?.addingTimeInterval(-1) ?? end)
        let allItems: [DebtWidgetItem]
        switch filter {
        case .service:
            allItems = serviceItems(in: range)
        case .person:
            allItems = transactionItems(in: range)
        case nil:
            allItems = serviceItems(in: range) + transactionItems(in: range)
        }
        let items = allItems
            .sorted { first, second in
                if calendar.isDate(first.date, inSameDayAs: second.date) {
                    return first.title.localizedStandardCompare(second.title) == .orderedAscending
                }
                return first.date < second.date
            }

        guard items.isEmpty else { return items }
        return [DebtWidgetItem].placeholderUpcoming.filter { filter == nil || $0.source == filter }
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
                        isIncome: !isExpense,
                        source: .service,
                        imageData: thumbnailData(from: service.value(forKey: "image") as? Data)
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
                    isIncome: isIncome,
                    source: .person,
                    imageData: thumbnailData(from: contact?.value(forKey: "avatarImage") as? Data),
                    emoji: contact?.value(forKey: "emoji") as? String
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

    private func thumbnailData(from data: Data?, maxDimension: CGFloat = 120) -> Data? {
        guard let data, !data.isEmpty,
              let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension * 2
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, UTType.png.identifier as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, cgImage, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return output as Data
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
                DebtWidgetItem(id: "rent", date: today, title: "Rent", subtitle: "Service", amount: 9_500, isIncome: false, source: .service),
                DebtWidgetItem(id: "payroll", date: today, title: "Payroll", subtitle: "Service", amount: 20_000, isIncome: true, source: .service),
                DebtWidgetItem(id: "alex", date: today, title: "Alex Rivera", subtitle: "They owe me", amount: 850, isIncome: true, source: .person)
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

private extension Array where Element == DebtWidgetItem {
    static var placeholderUpcoming: [DebtWidgetItem] {
        let today = Calendar.current.startOfDay(for: .now)
        return [
            DebtWidgetItem(id: "payroll", date: today, title: "Payroll", subtitle: "Service", amount: 20_000, isIncome: true, source: .service),
            DebtWidgetItem(id: "internet", date: today.addingTimeInterval(86_400), title: "Internet", subtitle: "Service", amount: 750, isIncome: false, source: .service),
            DebtWidgetItem(id: "alex", date: today.addingTimeInterval(172_800), title: "Alex Rivera", subtitle: "They owe me", amount: 850, isIncome: true, source: .person)
        ]
    }
}
