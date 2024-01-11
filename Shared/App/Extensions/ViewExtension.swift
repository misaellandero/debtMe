//
//  ViewExtension.swift
//  debtMe
//
//  Created by Misael Landero on 05/10/23.
//

import SwiftUI

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
}
