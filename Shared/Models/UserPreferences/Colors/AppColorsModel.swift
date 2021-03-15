//
//  AppColors.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

public struct  ThemeColorModel {
    var name : String
    var color: Color
}

public struct AppColorsModel {
    static let colors = [
         ThemeColorModel(name: "Peter river", color: .peterRiver),
         ThemeColorModel(name: "Belize hole", color: .belizeHole),
         ThemeColorModel(name: "Blue", color: .blue),
         ThemeColorModel(name: "Dark Blue", color: .darkBlue),
         ThemeColorModel(name: "Yellow", color: .yellow),
         ThemeColorModel(name: "Sun flower", color: .sunflower ),
         ThemeColorModel(name: "Orange", color: .orange),
         ThemeColorModel(name: "Carrot", color: .carrot),
         ThemeColorModel(name: "Pumpkin", color: .pumpkin),
         ThemeColorModel(name: "Green", color: .green),
         ThemeColorModel(name: "Emerald", color: .emerald),
         ThemeColorModel(name: "Nephritis", color: .nephritis),
         ThemeColorModel(name: "Turquoise", color: .turquoise),
         ThemeColorModel(name: "Green sea", color:.greenSea),
         ThemeColorModel(name: "Amethyst", color: .amethyst),
         ThemeColorModel(name: "Wisteria", color: .wisteria),
         ThemeColorModel(name: "Purple", color: .purple ),
         ThemeColorModel(name: "Alizarin", color: .alizarin),
         ThemeColorModel(name: "Pomegranate", color :.pomegranate),
         ThemeColorModel(name: "Red", color: .red),
         ThemeColorModel(name: "Pink", color: .pink),
         ThemeColorModel(name: "Pink rose ", color: .rose),
         ThemeColorModel(name: "Flamingo", color: .flamingo)
    ]
}
