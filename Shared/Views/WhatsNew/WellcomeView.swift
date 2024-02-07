//
//  WellcomeView.swift
//  debtMe (iOS)
//
//  Created by Misael Landero on 24/01/24.
//

import SwiftUI

struct WellcomeView: View {
    
    @AppStorage("newUser") static var newUser = true
    
    var features = whatsNewFeatures.appFeatures
     
    @State var isVisible : Bool = true
    
    @State var debuAllwayShow = true
    
    var body: some View {
        Group{
            if isVisible {
                
                HStack{
                    #if os(iOS)
                    #else
                    Spacer()
                        .layoutPriority(1)
                    #endif
                    
                    Group{
                        VStack{
                            Spacer()
                            DebtMeAppHeaderView()
                            Spacer()
                            Text("A simple app to register small loans between friends and family")
                            .padding()
                            Spacer()
                            ScrollView(.vertical){
                                FeaturesList(features: features)
                            }
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    isVisible.toggle()
                                }
                                
                            }, label: {
                                ButtonLabelContinue()
                            })
                            .buttonStyle(PlainButtonStyle())
                            Spacer()
                            
                        }
                    }
                    .background(Material.ultraThin)
                    .cornerRadius(10)
                    .padding()
                    .transition(.move(edge: .bottom))
                    .shadow(radius: 10)
                    .layoutPriority(1)
                    #if os(macOS)
                    .frame(width: 500)
                    #endif
                    
                    
                    #if os(iOS)
                    #else
                    Spacer()
                        .layoutPriority(1)
                    #endif
                    
                }
                
               
            }
        }
        .onAppear(perform: showWhatsNew)
    }
    
    // Check if app if app has been started after update
    func showWhatsNew() {
        #if DEBUG
        if debuAllwayShow {
            isVisible = true
            return
            
        }
        #endif
        
        
        let newVersion = getCurrentAppVersion()
        let oldVersion = UserDefaults.standard.string(forKey: "savedVersion") ?? "1.0.0"
        
        //Show only if is a mayor update
        var shouldShowWhatsNew = shouldShowWhatsNew(currentVersion: oldVersion, newVersion: newVersion)
         
        //Dont show if not update
        if newVersion == oldVersion {
            shouldShowWhatsNew = false
        }
        
        //Always show if is a new user or new instalation
        if WellcomeView.newUser {
            shouldShowWhatsNew = true
            WellcomeView.newUser = false
        }
         
        UserDefaults.standard.set(newVersion, forKey: "savedVersion")
        isVisible = shouldShowWhatsNew
        
    }
    
    // Check if whatsNew is required to be show
    func shouldShowWhatsNew(currentVersion: String, newVersion: String, showMinorUpdates: Bool = false) -> Bool {
        var currentVersionParts = currentVersion.split(separator: ".")
        var newVersionParts = newVersion.split(separator: ".")
        
        // Ensure each version part has a value
        while currentVersionParts.count < 3 {
            currentVersionParts.append("0")
        }
        while newVersionParts.count < 3 {
            newVersionParts.append("0")
        }
        
        let currentVersionPartsInt =  currentVersionParts.map { Int($0)! }
        let newVersionPartsInt =  newVersionParts.map { Int($0)! }
        
        
        if newVersionPartsInt[0] > currentVersionPartsInt[0]{
            return true
        }
        else if newVersionPartsInt[1] > currentVersionPartsInt[1]{
            return true
        }
        else if newVersionPartsInt[2] > currentVersionPartsInt[2]{
            if showMinorUpdates {
                return true
            } else{
                return false
            }
        }
        else{
            return false
        }
         
    }
    
    // Get current Version of the App
    func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "1.0.0"
        let version = (appVersion as! String)
        return version
    }
    
}

#Preview {
    WellcomeView(isVisible: true)
}
