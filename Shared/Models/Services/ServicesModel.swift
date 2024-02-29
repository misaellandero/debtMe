//
//  ServicesModel.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI

struct ServicesModel {
    
    var amout : String = ""
    var des : String = ""
    var expense : Bool = true
    var frecuency : Int = 1
    var frecuencyDate : Int = 1
    var image: Image = Image(.cromaPig)
    var name : String = ""
    
    var amountNumber : Double {
        let namount = Double(amout) ?? 0.0
        return namount
    }
}

 

 
