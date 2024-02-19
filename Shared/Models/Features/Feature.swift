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
        
        Feature(image:"sum", title: "Summary", des: "Now you can view the summary and balance directly within the Contacts tab. Head to Settings if you wish to disable this feature.",color: .indigo, newOnThisVersion: true)
        
        
    ]
    
    static var thanksSection = Feature(image: "exclamationmark.bubble.fill", title: "Thanks", des: LocalizedStringKey(combinedLocalizedString), color: Color.blue , system: true, newOnThisVersion: false)
}
