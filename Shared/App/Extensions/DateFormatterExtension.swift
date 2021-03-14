//
//  DateFormatterExtension.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import Foundation

extension DateFormatter {
    static let mediumDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        //make sure DateFormatter always up to date with the user's current locale
        df.locale = Locale.autoupdatingCurrent
        return df
    }()

    static let mediumTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .medium
        //make sure DateFormatter always up to date with the user's current locale
        df.locale = Locale.autoupdatingCurrent
        return df
    }()
    
    static let mediumDateTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium
        //make sure DateFormatter always up to date with the user's current locale
        df.locale = Locale.autoupdatingCurrent
        return df
    }()
}
