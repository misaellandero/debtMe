//
//  SettingsList.swift
//  debtMe
//
//  Created by Misael Landero on 26/01/24.
//

import SwiftUI
import LocalAuthentication

struct SettingsList: View {
    
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    let savedVersion = UserDefaults.standard.string(forKey: "savedVersion")
    
    // MARK: - LocalAuthentication Security Context
    let context = LAContext()
    @State private var error: NSError?
    @AppStorage("lockOnClose") var  lockOnClose: Bool = false
    @AppStorage("ShowSummary") var ShowSummary = true
    @AppStorage("icon") var selectedIcon: String = "AppIconImg"
    var body: some View {
        List{
          
            // MARK: - Contacts Tab
            Section(header:
                        Text("Contacts Tab")
                .bold()
                .foregroundColor(.secondary)
            ){
                
                // MARK: - Show Summary
                HStack{
                    Label("Show Summary", systemImage: "sum")
                     
                    Spacer()
                    Toggle(isOn: $ShowSummary) {
                        Text("Show Summary")
                    }
                    .labelsHidden()
                }
                
            }
            
            // MARK: - Personalization Tab
            #if os(iOS)
            Section(header:
                        Text("Personalization")
                .bold()
                .foregroundColor(.secondary)
            ){
                
                // MARK: - icons
                HStack{
                    Label("Choose an icon", systemImage: "app.badge.checkmark.fill")
                        .fixedSize(horizontal: true, vertical: false)
                    Picker("", selection: $selectedIcon.onChange(changeAppIcon)) {
                        HStack{
                            Image(.appIconImg)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .cornerRadius(5)
                            Text("Classic")
                        }
                        .tag("AppIcon 5")
                     
                        HStack{
                            Image(.appIconImg2)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .cornerRadius(5)
                            Text("Flat")
                          
                        }
                        .tag("AppIcon 2")
                        
                        HStack{
                            Image(.appIconImg1)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .cornerRadius(5)
                            Text("Flat Dark")
                        }
                        .tag("AppIcon 1")
                         
                        HStack{
                            Image(.appIconImg1)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .cornerRadius(5)
                            Text("iOS 18")
                        }
                        .tag("AppIcon 6")
                        
                        
                    }
                    .pickerStyle(NavigationLinkPickerStyle())
                   
                }
                
               
            }
            #endif
            // MARK: - Security
                Section(
                    header:
                    Text("Security")
                    .bold()
                    .foregroundColor(.secondary),
                    footer: Text("When you turn on this option, the device will require your FaceID, TouchID, or passcode to unlock the app.")
                ){
                    // MARK: - Lock Upon Exit
                    HStack{
                        Label("Lock Upon Exit", systemImage: (context.biometryType == LABiometryType.faceID) ? "faceid" : "touchid")
                         
                        Spacer()
                        Toggle(isOn: self.$lockOnClose.onChange({ lock in
                            if lock {
                                authenticate()
                            }
                        })) {
                            Text("Lock Upon Exit")
                        }
                        .labelsHidden()
                    }
                }
            
            // MARK: - About this App
            Section(header:
                        Text("About this App")
                .bold()
                .foregroundColor(.secondary)
            ){
                
                NavigationLink(destination: AboutThisAppView()) {
                    Label("Learn More", systemImage: "info.bubble.fill")
                }
                NavigationLink(destination: WhatsNewView()) {
                    Label("What's New?", systemImage: "star.bubble.fill")
                }
                
                NavigationLink(destination:   LegalAppView(headerImage: "hand.raised", title: "Terms and conditions", text: "Terms_Text")) {
                    Label("Terms and conditions", systemImage: "hand.raised.fill")
                }
                NavigationLink(destination:   LegalAppView(headerImage: "lock.shield", title: "Privacy Policy", text: "Privacy_Text")) {
                    Label("Privacy Policy", systemImage: "lock.shield.fill")
                }
                
                
            }
            // MARK: - Footer
            Section{
                VStack{
                    HStack{
                        Spacer()
                        Image(.pig)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                        Spacer()
                    }
                    HStack{
                        Spacer()
                        Text("2023 - \(Date().formatted(.dateTime.year()))\nDebtMe App by Misael Landeros")
                            .multilineTextAlignment(.center)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    HStack{
                        Spacer()
                        Text("Version \(savedVersion ?? "0.0")")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    
                }
                #if os(iOS)
                .listRowBackground(Color(colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground )
                .opacity(0.95))
                
                #endif
            }
            
        }
        .navigationTitle("Settings")
    }
#if os(iOS)
    // MARK: -  Cambair el icono
    func changeAppIcon(tag icon: String){
        UIApplication.shared.setAlternateIconName(icon)
         
    }
#endif
    // MARK: -  Desbloquear el equipo
    func authenticate(){
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
          
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock to see your data" ) {
                success, authenticationError in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if success {
                                lockOnClose = true
                            }
                    }
            }
            
        } else {
            // sin biometricos
            context.evaluatePolicy(.deviceOwnerAuthentication , localizedReason: "Unlock to see your data" ) {
                success, authenticationError in
                    if success {
                        lockOnClose = true
                    }
            }
        }
        
    }
    
}

#Preview {
    SettingsList()
}
