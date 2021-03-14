//
//  BindingExtension.swift
//  Revisits
//
//  Created by Francisco Misael Landero Ychante on 06/12/20.
//  Copyright © 2020 Francisco Misael Landero Ychante. All rights reserved.
//

import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}
