//
//  ContentView.swift
//  Shared
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI
import CoreData
import LocalAuthentication

// MARK: - Navigation Options
enum SectionSelected {
    case contacts, debts, loans, settings, budget
}

struct ContentView: View {
    
    // MARK: - Screen Size for determining ipad or iphone screen
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    // MARK: - current section selected 
    @State var sectionSelected : SectionSelected? = .contacts
  
    // MARK: - LocalAuthentication Security Context
    let context = LAContext()
    @State private var error: NSError?
    @AppStorage("lockOnClose") var  lockOnClose: Bool = false
    @AppStorage("locked") var unlocked: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    
    var body: some View {
            ZStack{
                if lockOnClose && !unlocked {
                    LockedView(unlock: authenticate)
                } else {
                    #if os(iOS)
                    if horizontalSizeClass == .compact {
                        TabBarView()
                    } else {
                        SideBarView(sectionSelected : $sectionSelected)
                    }
                    #elseif os(visionOS)
                    TabBarView()
                    #else
                    SideBarView(sectionSelected : $sectionSelected)
                    #endif
                }
                WellcomeView()
                
                /*VStack{
                    Spacer()
                    Text("lockOnClose \(lockOnClose.description)")
                    Text("unlocked \(unlocked.description)")
                }*/
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .background {
                    //print("Background")
                    unlocked = false
                }
            }
    }
    
    // MARK: - LocalAuthentication
    
    // MARK: -  Desbloquear el equipo
    func authenticate(){
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let  reason = "Desbloquea para ver tus datos"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) {
                success, authenticationError in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if success {
                                unlocked = true
                            }
                    }
            }
            
        } else {
            let  reason = "Desbloquea para ver tus datos"
            // sin biometricos
            context.evaluatePolicy(.deviceOwnerAuthentication , localizedReason: reason ) {
                success, authenticationError in
                    if success {
                        unlocked = true
                    }
            }
        }
        
    }
     
}
