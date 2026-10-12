//
//  AppReviewRequest.swift
//  App Review
//
//  Created by Stewart Lynch on 2020-11-03.
//

import SwiftUI
import StoreKit
#if os(macOS)
import AppKit
#endif

enum AppReviewRequest {
    static var threshold = 0
    @AppStorage("runsSinceLastRequest") static var runsSinceLastRequest = 0
    @AppStorage("version") static var version = ""
    
    @MainActor
    static func requestReviewIfNeeded() {
        runsSinceLastRequest += 1
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let thisVersion =  "\(appVersion) build: \(appBuild)"
        print("Run Count: \(runsSinceLastRequest)")
        print("Version: \(thisVersion)")
        
        
        if thisVersion != version {
            if runsSinceLastRequest >= threshold {
                          
            #if os(macOS)
                if let controller = NSApplication.shared.keyWindow?.contentViewController {
                    AppStore.requestReview(in: controller)
                    version = thisVersion
                    runsSinceLastRequest = 0
                }
            #else
                if let scene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene {
                    AppStore.requestReview(in: scene)
                    version = thisVersion
                    runsSinceLastRequest = 0
                }
            #endif
                
            }
        } else {
            runsSinceLastRequest = 0
        }
        
    }
}
