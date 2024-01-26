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
    
    static var appFeatures = [
        
        Feature(image:"dollarsign.circle.fill", title: "Track Debts and Loads", des: "Track your transactions with friends and family, keep an easy record of what you debt and own",color: .orange),
        
        Feature(image:"icloud.fill", title: "iCloud Sync", des: "Keep all your devices up to date using iCloud sync",color: .blue),
        
        Feature(image:"macbook.and.iphone", title: "Universal App", des: "Get the app on your iPhone, iPad, Mac and VisionPro",color: .green)
        
    ]
    
    
    static var newFeatures = [
        
        Feature(image:"dollarsign.circle.fill", title: "Track Debts and Loads", des: "Track your transactions with friends and family, keep an easy record of what you debt and own",color: .orange),
        
        Feature(image:"icloud.fill", title: "iCloud Sync", des: "Kepp all your devices up to date using the iCloud sync",color: .blue),
        
        Feature(image:"macbook.and.iphone", title: "Universal App", des: "Get the app on your iPhone, iPad, Mac and VisionPro",color: .green)
        
    ]
    
}
