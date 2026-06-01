//
//  ViewExtension.swift
//  debtMe
//
//  Created by Misael Landero on 05/10/23.
//

import SwiftUI

enum AppIcons {
    static let edit = "square.and.pencil"
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
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    func appSheetCancelButtonStyle() -> some View {
        self.buttonStyle(.bordered)
            .tint(.red)
    }
}
