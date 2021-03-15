//
//  UserPreferencesModel.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import Foundation

struct UserPreferencesModel : Identifiable, Codable {
    var id = UUID()
    //Accent Color
    var accentColor = 0
    //Alternative App Icon
    var appIcon = 0
}

