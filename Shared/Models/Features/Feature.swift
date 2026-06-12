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
    var newOnThisVersion = false
}

struct whatsNewFeatures {
    
    static var thanks = ("Thanks")
    static var people = ("Ross, Hugo, Josue")
    static var bugReportsInfo = (" for their comments and ideas. If you have a suggestion or found an error, please send an email to hola@misaellandero.com.")
    static var combinedLocalizedString = "\(NSLocalizedString(thanks, comment: "")) \(NSLocalizedString(people, comment: "")) \(NSLocalizedString(bugReportsInfo, comment: ""))"
    
   
    static var appFeatures = [
        
        Feature(image:"dollarsign.circle.fill", title: "Track Debts and Loans", des: "Track your transactions with friends and family, keep an easy record of what you debt and own",color: .orange, newOnThisVersion: false),
        
        Feature(image:"icloud.fill", title: "iCloud Sync", des: "Keep all your devices up to date using iCloud sync",color: .blue, newOnThisVersion: false),
        
        Feature(image:"macbook.and.iphone", title: "Universal App", des: "Get the app on your iPhone, iPad, Mac and VisionPro",color: .green, newOnThisVersion: false),
        
        Feature(image:"sum", title: "Summary", des: "Now you can view the summary and balance directly within the Contacts tab. Head to Settings if you wish to disable this feature",color: .indigo, newOnThisVersion: false),
        
        Feature(image:"photo.on.rectangle.angled", title: "Images", des: "Now you add images to the transactions and payments",color: .blue, newOnThisVersion: false),
        
        
        Feature(image:"square.dashed", title: "Icons", des: "New icon for iOS 18 support dark and tinted mode",color: .purple, newOnThisVersion: false),
       
        Feature(image:"macwindow.on.rectangle", title: "Tile", des: "Now the apps is compatible with tiles on macOS",color: .pink, newOnThisVersion: false),

        Feature(image:"house.fill", title: "Home Hub", des: "Home is now the main hub for scheduled services and people transactions, with quick actions to add contacts and services.", color: .accentColor, newOnThisVersion: true),

        Feature(image:"calendar", title: "Unified Calendar", des: "The Home calendar now combines services and scheduled people transactions so you can see income, expenses, and balances in one place.", color: .blue, newOnThisVersion: true),

        Feature(image:"slider.horizontal.3", title: "Configuration Lists", des: "People and Services now focus on managing your saved contacts and services, while Home handles daily tracking.", color: .orange, newOnThisVersion: true),

        Feature(image:"photo", title: "Improved Image Editor", des: "Service images have clearer pickers, loading states, better icon visibility, and safer image sizing.", color: .purple, newOnThisVersion: true),

        Feature(image:"globe", title: "Localization Cleanup", des: "User-facing base strings were cleaned up so the app is easier to translate from English.", color: .green, newOnThisVersion: true),
        
    ]
    
    static var thanksSection = Feature(image: "exclamationmark.bubble.fill", title: "Thanks", des: LocalizedStringKey(combinedLocalizedString), color: Color.blue , system: true, newOnThisVersion: false)
}
