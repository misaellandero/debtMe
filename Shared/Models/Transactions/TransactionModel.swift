//
//  TransactionModel.swift
//  debtMe (iOS)
//
//  Created by Francisco Misael Landero Ychante on 18/04/21.
//

import Foundation

struct TransactionModel {
    var amout : String
    var des : String
    var notes : String
    var date : Date
    var debt : Bool
    var settled = false
     
    var amountNumber : Double {
        let namount = Double(amout) ?? 0.0
        return namount
    }
}
