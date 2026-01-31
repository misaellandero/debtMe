//
//  CurrencyExtension.swift
//  debtMe
//
//  Created by Misael Landero on 07/04/23.
//

import Foundation

extension Double {
    func toCurrencyString(locale: Locale = .current) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = locale
        if let formattedString = numberFormatter.string(from: NSNumber(value: self)) {
            return formattedString
        } else {
            numberFormatter.numberStyle = .decimal
            return numberFormatter.string(from: NSNumber(value: 0.0)) ?? ""
        }
    }

    func toCompactCurrencyString(locale: Locale = .current) -> String {
        if #available(iOS 15.0, macOS 12.0, visionOS 1.0, *) {
            let code = locale.currency?.identifier ?? "USD"
            return formatted(.currency(code: code).notation(.compactName).locale(locale))
        }
        return toCurrencyString(locale: locale)
    }
}

