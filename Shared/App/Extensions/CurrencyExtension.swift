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
}


