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
            /*Section(header:
                        Text("Personalization")
                .bold()
                .foregroundColor(.secondary)
            ){
                
            }*/
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

            #if DEBUG
            Section(header:
                        Text("Developer")
                .bold()
                .foregroundColor(.secondary)
            ) {
                NavigationLink(destination: StyleGuidePreviewView()) {
                    Label("Style Guide", systemImage: "paintbrush.pointed")
                }
            }
            #endif
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

#if DEBUG
// MARK: - In-app Style Guide Preview

struct StyleGuidePreviewView: View {
    @State private var showSheetPreview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                typographySection
                toolbarSection
                accentButtonsSection
                shapesSection
            }
            .padding(20)
        }
        .navigationTitle("Style Guide")
        .sheet(isPresented: $showSheetPreview) {
            StyleGuideSheetPreview()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DebtMe")
                .appBrandTitle()
            Text("Visual source of truth preview")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var typographySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Typography")
                .appHeadline()

            VStack(alignment: .leading, spacing: 10) {
                Text("Brand Title — Title2 / Rounded / Bold")
                    .appBrandTitle()
                Text("Brand Headline — Headline / Rounded / Semibold")
                    .appBrandHeadline()
                Text("Title — Title2 / Bold")
                    .appTitle()
                Text("Headline — Headline / Semibold")
                    .appHeadline()
                Text("Body — default body text for content and paragraphs.")
                    .font(AppTypography.body)
                Text("Caption — metadata, helper labels, secondary info.")
                    .font(AppTypography.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var toolbarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Toolbar Labels")
                .appHeadline()

            HStack(spacing: 10) {
                Label("Calendar", systemImage: "calendar")
                    .appToolbarLabel()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: Capsule())

                Label("List", systemImage: "list.bullet")
                    .appToolbarLabel()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: Capsule())

                Label("Add", systemImage: "plus.circle.fill")
                    .appToolbarLabel()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: Capsule())

                Spacer(minLength: 0)
            }
        }
    }

    private var accentButtonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accent Buttons")
                .appHeadline()

            HStack(spacing: 12) {
                Button {
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                        .appToolbarLabel()
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)

                Button {
                } label: {
                    Label("Edit", systemImage: AppIcons.edit)
                        .appToolbarLabel()
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor.opacity(0.85))

                Spacer(minLength: 0)
            }

            Button {
                showSheetPreview = true
            } label: {
                Label("Open Sheet Preview", systemImage: "rectangle.portrait.and.arrow.right")
                    .appToolbarLabel()
                    .frame(maxWidth: .infinity)
            }
            .appSheetPrimaryButtonStyle()

            HStack(spacing: 12) {
                Label("Filter", systemImage: "slider.horizontal.3")
                    .appToolbarLabel()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: Capsule())

                Label("Today", systemImage: "calendar")
                    .appToolbarLabel()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: Capsule())

                Spacer(minLength: 0)
            }
        }
    }

    private var shapesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shapes")
                .appHeadline()

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calendar cell")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.secondary.opacity(0.12))
                        .frame(width: 120, height: 72)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.accentColor.opacity(0.8), lineWidth: 2)
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Card container")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.secondary.opacity(0.08))
                        .frame(width: 160, height: 72)
                }
            }
        }
    }
}

struct StyleGuideSheetPreview: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Sheet Buttons")
                        .appTitle()

                    Text("Preview the standard sheet size, navigation actions, and primary/cancel button treatment.")
                        .font(AppTypography.body)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 12) {
                        Button {
                        } label: {
                            Label("Primary Action", systemImage: "checkmark.circle.fill")
                                .appToolbarLabel()
                                .frame(maxWidth: .infinity)
                        }
                        .appSheetPrimaryButtonStyle()

                        Button(role: .destructive) {
                        } label: {
                            Label("Destructive Action", systemImage: "trash")
                                .appToolbarLabel()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .navigationTitle("Sheet Preview")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .appSheetCancelButtonStyle()
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "checkmark.circle.fill")
                            .appToolbarLabel()
                    }
                    .appSheetPrimaryButtonStyle()
                }
            }
        }
        .macOSFixedSheet(width: 520, height: 360)
    }
}
#endif
