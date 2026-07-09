//
//  Feature.swift
//  debtMe
//
//  Created by Misael Landero on 24/01/24.
//

import SwiftUI

struct Feature {
    var id = UUID()
    var image = ""
    var title : LocalizedStringKey = ""
    var des : LocalizedStringKey =  ""
    var color = Color.blue
    var system = true
}

struct FeatureVersion: Identifiable {
    var id = UUID()
    var version = ""
    var features: [Feature] = []
}

struct whatsNewFeatures {

    static var thanks = ("Thanks")
    static var people = ("Ross, Hugo, Josue")
    static var bugReportsInfo = (" for their comments and ideas. If you have a suggestion or found an error, please send an email to hola@misaellandero.com.")
    static var combinedLocalizedString = "\(NSLocalizedString(thanks, comment: "")) \(NSLocalizedString(people, comment: "")) \(NSLocalizedString(bugReportsInfo, comment: ""))"

    /// Feature history grouped by version, newest first. The welcome screen
    /// shows only the latest group; Settings shows the full history.
    static var versions = [

        FeatureVersion(version: "1.2", features: [

            Feature(image:"rectangle.3.group", title: "Redesigned Widgets", des: "Widgets now show your service images and contact photos, and tell you how many days are left before each payment.", color: .orange),

            Feature(image:"calendar.badge.clock", title: "Choose Your Widget Range", des: "Pick how far ahead each widget looks — 7, 14, 30 or 60 days — right from the widget settings.", color: .blue),

            Feature(image:"square.grid.2x2", title: "Services and Contacts Widgets", des: "Two new widgets show only your services or only your contacts, so you can see each at a glance.", color: .green),

            Feature(image:"sum", title: "Services Summary", des: "The Services tab now shows income, expenses and balance together, just like Contacts.", color: .indigo),

            Feature(image:"sparkles", title: "Smarter Icon Search", des: "Find icons for your services by describing them. Uses Apple Intelligence when available.", color: .purple),
        ]),

        FeatureVersion(version: "1.1", features: [

            Feature(image:"house.fill", title: "Home Hub", des: "Home is now the main hub for scheduled services and people transactions, with quick actions to add contacts and services.", color: .accentColor),

            Feature(image:"calendar", title: "Unified Calendar", des: "The Home calendar now combines services and scheduled people transactions so you can see income, expenses, and balances in one place.", color: .blue),

            Feature(image:"checkmark.circle", title: "Daily Payment Tracking", des: "Swipe scheduled services to mark that day as paid or cancelled without changing the rest of the schedule.", color: .green),

            Feature(image:"rectangle.3.group", title: "Widgets", des: "New widgets show your debt flow, people balances, and upcoming payments from services and people.", color: .orange),

            Feature(image:"photo", title: "Improved Image Editor", des: "Service images have clearer pickers, loading states, better icon visibility, and safer image sizing.", color: .purple),

            Feature(image:"slider.horizontal.3", title: "Configuration Lists", des: "People and Services now focus on managing your saved contacts and services, while Home handles daily tracking.", color: .indigo),
        ]),

        FeatureVersion(version: "1.0", features: [

            Feature(image:"dollarsign.circle.fill", title: "Track Debts and Loans", des: "Track your transactions with friends and family, keep an easy record of what you debt and own",color: .orange),

            Feature(image:"icloud.fill", title: "iCloud Sync", des: "Keep all your devices up to date using iCloud sync",color: .blue),

            Feature(image:"macbook.and.iphone", title: "Universal App", des: "Get the app on your iPhone, iPad, Mac and VisionPro",color: .green),

            Feature(image:"sum", title: "Summary", des: "Now you can view the summary and balance directly within the Contacts tab. Head to Settings if you wish to disable this feature",color: .indigo),

            Feature(image:"photo.on.rectangle.angled", title: "Images", des: "Now you add images to the transactions and payments",color: .blue),

            Feature(image:"square.dashed", title: "Icons", des: "New icon for iOS 18 support dark and tinted mode",color: .purple),

            Feature(image:"macwindow.on.rectangle", title: "Tile", des: "Now the apps is compatible with tiles on macOS",color: .pink),
        ]),
    ]

    /// Features of the current release, shown when the app presents What's New.
    static var latest: FeatureVersion {
        versions.first ?? FeatureVersion()
    }

    static var thanksSection = Feature(image: "exclamationmark.bubble.fill", title: "Thanks", des: LocalizedStringKey(combinedLocalizedString), color: Color.blue , system: true)
}
