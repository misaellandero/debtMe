//
//  ViewExtension.swift
//  debtMe
//
//  Created by Misael Landero on 05/10/23.
//

import SwiftUI

enum AppIcons {
    static let edit = "pencil"
}

enum AppTheme {
    static let actionTint = Color(red: 0.961, green: 0.690, blue: 0.247)
    static let destructiveTint = Color(red: 1.0, green: 0.0, blue: 0.0)
}

extension View {
    func embeddedInNavigationViewIfNeccessary() -> some View {
#if os (iOS)
        NavigationView {
            self
        }
#elseif os(macOS)
        self
#else
        self
#endif
    }

    @ViewBuilder
    func macOSFixedSheet(width: CGFloat, height: CGFloat) -> some View {
        #if os(macOS)
        self.frame(width: width, height: height)
        #else
        self
        #endif
    }

    @ViewBuilder
    func appSheetPrimaryButtonStyle() -> some View {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            self
                .buttonStyle(.glassProminent)
                .tint(AppTheme.actionTint)
        } else {
            self
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.actionTint)
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    func appGlassControlButtonStyle(tint: Color = AppTheme.actionTint) -> some View {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            self
                .buttonStyle(.glassProminent)
                .tint(tint)
        } else {
            self
                .buttonStyle(.borderedProminent)
                .tint(tint)
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    func appSheetCancelButtonStyle() -> some View {
        self.buttonStyle(.appToolbarCancel)
    }

    func appSheetBottomConfirmationAction(
        edition: Bool,
        isPresented: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        #if os(macOS)
        self
        #else
        self.safeAreaInset(edge: .bottom) {
            Button(action: action) {
                Label(
                    edition ? "Save" : "Add",
                    systemImage: edition ? "checkmark" : "plus"
                )
                .appToolbarLabel()
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .appSheetPrimaryButtonStyle()
            .padding()
            .background(.bar)
        }
        #endif
    }
}

#if os(macOS)
struct AppMacFormSection<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.secondary.opacity(0.12), lineWidth: 1)
        )
    }
}

struct AppMacFormRow<Content: View>: View {
    let title: LocalizedStringKey
    let systemImage: String?
    let content: Content

    init(_ title: LocalizedStringKey, systemImage: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        HStack(spacing: 12) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)
                    .frame(width: 18)
            }

            Text(title)
                .foregroundStyle(.secondary)

            Spacer(minLength: 16)

            content
                .frame(maxWidth: 280, alignment: .trailing)
        }
        .frame(minHeight: 34)
    }
}

struct AppMacFormDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 30)
    }
}
#endif
