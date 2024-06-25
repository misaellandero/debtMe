//
//  Constants.swift
//  debtMe
//
//  Created by Misael Landero on 25/06/24.
//

import Foundation

enum sortModeServices : String, CaseIterable {
    case alfabethAsc = "Ascendente A-Z"
    case alfabethDes = "Descendente Z-A"
    case amountAsc = "Menor primero"
    case amountDes = "Mayor primero"
}

enum shortMode : String {
    case alfabethAsc, alfabethDes, amountAsc, amountDes, dateCreationAsc, dateCreationDes, dateSettledAsc, dateSettledDes
}

enum summaryContactsMenu: String, CaseIterable {
    case balance = "Balance"
    case loans = "Loans"
    case debts = "Debts"
    case all = "All"
}

enum summaryServicesMenu: String, CaseIterable {
    case balance = "Balance"
    case income = "Income"
    case expense = "Expenses"
    case all = "All"
}
