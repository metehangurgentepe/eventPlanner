//
//  localeKeys.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 11.07.2023.
//

import Foundation
import SwiftUI

struct LocaleKeys{
    enum Tab : String{
        case home = "tabHome"
        case message = "tabMessage"
        case event = "tabEvent"
        case account = "tabAccount"
    }
    enum addEvent : String{
        case title = "addTitle"
        case name = "addName"
        case type = "addType"
        case price = "addPrice"
        case next = "addNext"
        case selectImage = "addSelectImage"
        case description = "addDescription"
        case location = "addLocation"
        case time = "addTime"
        case publicEvent = "addPublicEvent"
        case createEvent = "addCreateEvent"
        case notCreated = "addNotCreated"
        case okButton = "addOK"
        case barTitle = "addBarTitle"
        case locationNotAdded = "addLocationNotAdded"
    }
    enum Login : String{
        case title = "loginTitle"
        case email = "loginEmail"
        case password = "loginPassword"
        case button = "loginButton"
        case error = "loginError"
        case next = "loginNext"
        case okButton = "loginOK"
    }
    enum Register : String{
        case title = "registerTitle"
        case name = "registerName"
        case email = "registerEmail"
        case phone = "registerPhone"
        case password = "registerPassword"
        case button = "registerButton"
        case back = "registerBack"
    }
    enum Profile : String{
        case general = "profileGeneral"
        case account = "profileAccount"
        case signOut = "profileSignOut"
    }

}

extension String {
    func locale() -> LocalizedStringKey {
        return LocalizedStringKey(self)
    }
}
