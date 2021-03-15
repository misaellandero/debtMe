//
//  UserPreferences.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

class UserPreferences: ObservableObject {
    @Published var userPreferences : UserPreferencesModel
    
    //To save in userdefaults
    static let saveKey = "SavedSettings"
    
    init() {
        //get dato from userdefaults
        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
            if let decoded = try? JSONDecoder().decode(UserPreferencesModel.self, from: data){
                // set data to var userdefaults
                self.userPreferences = decoded
                return
            }
        }
        // if we dont have data create a new instace
        self.userPreferences = UserPreferencesModel()
    }
    
    //Save data to userDeafults on everychange
    func save() {
        if let encoded = try? JSONEncoder().encode(userPreferences){
            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
        }
    }
    
    //Change AssentColor
    func changeAssentColor(_ colorID : Int){
        objectWillChange.send()
        
        userPreferences.accentColor  = colorID
         
        //Para cuando se añadan widgets
        /*if userSetings.widgetIndependtColor {
            if let userDefaults = UserDefaults(suiteName: "group.mx.landercorp.debtMe") {
                userDefaults.set(colorID as Int , forKey: "themeColor")
                userDefaults.synchronize()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }*/
         
        save()
    }
    
    //Get Colors from the Colors Model
    func getThemeColor() -> Color {
        let accentColorApp =  AppColorsModel.colors[userPreferences.accentColor].color
        return accentColorApp
    }
     
    
}
