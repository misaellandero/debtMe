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
                .appHeadline()
                .foregroundStyle(.secondary)
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
                    .appHeadline()
                    .foregroundStyle(.secondary),
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
                .appHeadline()
                .foregroundStyle(.secondary)
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
                .appHeadline()
                .foregroundStyle(.secondary)
            ) {
                NavigationLink(destination: StyleGuidePreviewView()) {
                    Label("Style Guide", systemImage: "paintpalette.fill")
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
                .listRowBackground(Color(colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground).opacity(0.95))
                
                #endif
            }
            
        }
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
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
                buttonStyleBuilderSection
                appButtonStylesSection
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

                Label("Add", systemImage: "plus")
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
                    Label("Add", systemImage: "plus")
                        .appToolbarLabel()
                }
                .buttonStyle(.appAdd)

                Button {
                } label: {
                    Label("Edit", systemImage: AppIcons.edit)
                        .appToolbarLabel()
                }
                .buttonStyle(.appEdit)

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

    private var buttonStyleBuilderSection: some View {
        ButtonStyleBuilderView()
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

    private var appButtonStylesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Button Styles")
                .appHeadline()

            Text("Reusable button styles for the legacy UIElements button labels. Prefer `.buttonStyle(...)` for new buttons.")
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                Text("Outside")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                StyleGuideActionButtons()
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Form")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Form {
                    Section("Actions") {
                        StyleGuideActionButtons()
                    }
                }
                .frame(minHeight: 260)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("List")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                List {
                    Section("Actions") {
                        StyleGuideActionButtons()
                    }
                }
                .frame(minHeight: 260)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Navigation")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                NavigationStack {
                    Form {
                        Section("Actions") {
                            StyleGuideActionButtons()
                        }
                    }
                    .navigationTitle("Buttons")
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button {
                            } label: {
                                Label("Done", systemImage: "checkmark.circle.fill")
                                    .appToolbarLabel()
                            }
                            .appSheetPrimaryButtonStyle()
                        }
                    }
                }
                .frame(minHeight: 320)
            }
        }
    }
}

private enum StyleGuideButtonShape: String, CaseIterable, Identifiable {
    case capsule = "Capsule"
    case roundedRectangle = "Rounded Rectangle"
    case circle = "Circle"

    var id: String { rawValue }
}

private enum StyleGuideButtonSymbol: String, CaseIterable, Identifiable {
    case plus = "plus"
    case checkmark = "checkmark"
    case pencil = "pencil"
    case trash = "trash"

    var id: String { rawValue }
}

private struct ButtonStyleBuilderView: View {
    @State private var tint = AppTheme.actionTint
    @State private var shape = StyleGuideButtonShape.circle
    @State private var symbol = StyleGuideButtonSymbol.plus
    @State private var title = "Add"
    @State private var size = 64.0
    @State private var horizontalPadding = 18.0
    @State private var verticalPadding = 12.0
    @State private var cornerRadius = 18.0
    @State private var showTitle = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Button Style Builder")
                .appHeadline()

            Text("Tune a Liquid Glass button and use the generated SwiftUI snippet as the shared style reference.")
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)

            preview
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)

            controls
            snippet
        }
        .padding(14)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder
    private var preview: some View {
        Button {
        } label: {
            if showTitle {
                Label(title, systemImage: symbol.rawValue)
                    .labelStyle(.titleAndIcon)
                    .font(.system(size: shape == .circle ? 30 : 18, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: shape == .circle ? size : nil, height: shape == .circle ? size : nil)
                    .padding(.horizontal, shape == .circle ? 0 : horizontalPadding)
                    .padding(.vertical, shape == .circle ? 0 : verticalPadding)
            } else {
                Label(title, systemImage: symbol.rawValue)
                    .labelStyle(.iconOnly)
                    .font(.system(size: shape == .circle ? 30 : 18, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: shape == .circle ? size : nil, height: shape == .circle ? size : nil)
                    .padding(.horizontal, shape == .circle ? 0 : horizontalPadding)
                    .padding(.vertical, shape == .circle ? 0 : verticalPadding)
            }
        }
        .buttonStyle(.plain)
        .modifier(
            StyleGuideGlassPreviewModifier(
                tint: tint,
                shape: shape,
                cornerRadius: cornerRadius
            )
        )
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            ColorPicker("Tint", selection: $tint, supportsOpacity: true)

            Picker("Shape", selection: $shape) {
                ForEach(StyleGuideButtonShape.allCases) { shape in
                    Text(shape.rawValue).tag(shape)
                }
            }
            .pickerStyle(.segmented)

            Picker("Symbol", selection: $symbol) {
                ForEach(StyleGuideButtonSymbol.allCases) { symbol in
                    Text(symbol.rawValue).tag(symbol)
                }
            }
            .pickerStyle(.menu)

            TextField("Title", text: $title)
                .textFieldStyle(.roundedBorder)

            Toggle("Show title", isOn: $showTitle)

            LabeledContent("Size") {
                Slider(value: $size, in: 44...96, step: 1)
                    .frame(maxWidth: 220)
            }

            if shape != .circle {
                LabeledContent("Horizontal padding") {
                    Slider(value: $horizontalPadding, in: 10...32, step: 1)
                        .frame(maxWidth: 220)
                }

                LabeledContent("Vertical padding") {
                    Slider(value: $verticalPadding, in: 8...24, step: 1)
                        .frame(maxWidth: 220)
                }

                LabeledContent("Corner radius") {
                    Slider(value: $cornerRadius, in: 10...32, step: 1)
                        .frame(maxWidth: 220)
                }
            }
        }
        .font(AppTypography.body)
    }

    private var snippet: some View {
        Text(generatedSnippet)
            .font(.system(.caption, design: .monospaced))
            .textSelection(.enabled)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var generatedSnippet: String {
        let shapeCode: String
        switch shape {
        case .capsule:
            shapeCode = ".capsule"
        case .roundedRectangle:
            shapeCode = ".rect(cornerRadius: \(Int(cornerRadius)))"
        case .circle:
            shapeCode = ".circle"
        }

        return """
        Label("\(title)", systemImage: "\(symbol.rawValue)")
            .foregroundStyle(AppTheme.actionTint)
            .glassEffect(.regular.tint(AppTheme.actionTint).interactive(), in: \(shapeCode))
        """
    }
}

private struct StyleGuideGlassPreviewModifier: ViewModifier {
    let tint: Color
    let shape: StyleGuideButtonShape
    let cornerRadius: Double

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            switch shape {
            case .capsule:
                content.glassEffect(.regular.tint(tint).interactive(), in: .capsule)
            case .roundedRectangle:
                content.glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
            case .circle:
                content.glassEffect(.regular.tint(tint).interactive(), in: .circle)
            }
        } else {
            switch shape {
            case .capsule:
                content.background(.thinMaterial, in: Capsule())
            case .roundedRectangle:
                content.background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            case .circle:
                content.background(.thinMaterial, in: Circle())
            }
        }
    }
}

private struct StyleGuideActionButtons: View {
    var body: some View {
        VStack(spacing: 10) {
            Button {
            } label: {
                Label("Add", systemImage: "plus")
            }
            .buttonStyle(.appAdd)

            Button {
            } label: {
                Label("Continue", systemImage: "checkmark.circle.fill")
            }
            .buttonStyle(.appContinue)

            Button {
            } label: {
                Label("Mark as Settled", systemImage: "face.smiling")
            }
            .buttonStyle(.appPayAll)

            Button {
            } label: {
                Label("Toggle Status to Unpaid", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.appReset)

            HStack {
                Button {
                } label: {
                    Label("Show Settled", systemImage: "eye")
                }
                .buttonStyle(.appShowSettled)

                Spacer(minLength: 0)
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
                        .buttonStyle(.appAction(tint: AppTheme.destructiveTint))
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
