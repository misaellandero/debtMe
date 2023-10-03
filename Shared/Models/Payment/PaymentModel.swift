//
//  PaymentModel.swift
//  debtMe
//
//  Created by Misael Landero on 12/02/23.
//

import Foundation

//Dummy for simple data

struct PaymentModel {
    var amout : String
    var note : String
    var date : Date
    var payAll = false
     
    var amountNumber : Double {
        let namount = Double(amout) ?? 0.0
        return namount
    }
}

