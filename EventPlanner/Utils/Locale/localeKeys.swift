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
        case saved = "tabSaved"
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
        case select = "addSelect"
        case errorTitle = "addErrorTitle"
        case errorMessage = "addErrorMessage"
        case photoError = "addPhotoError"
        case timeError = "addTimeError"
        case priceError = "addPriceError"
        case locationError = "addLocationError"
        case selectLocationError = "addSelectLocationError"
        case creationError = "addCreationError"
        case addButton = "addEventAddButton"
    }
    enum Distance: String{
        case title = "distanceTitle"
        case subtitle = "distanceSubtitle"
    }
    enum ResetPassword: String{
        case alertTitleError = "resetAlertTitleError"
        case alertMessageError = "resetAlertMessageError"
        case alertTitleSuccess = "resetAlertTitleSuccess"
        case alertMessageSuccess = "resetAlertMessageSuccess"
        case resetPassword = "resetPassword"
        case resetEmail = "resetEmail"
    }
    enum AddUser: String{
        case errorCreated = "userErrorCreated"
        case errorLeadUser = "userErrorLeadUser"
        case error = "userError"
        case title = "userTitle"
    }
    enum Login : String{
        case title = "loginTitle"
        case email = "loginEmail"
        case password = "loginPassword"
        case button = "loginButton"
        case error = "loginError"
        case next = "loginNext"
        case okButton = "loginOK"
        case mustLogin = "loginMust"
        case errorMessage = "loginErrorMessage"
        case reset = "loginReset"
    }
    enum Register : String{
        case title = "registerTitle"
        case name = "registerName"
        case email = "registerEmail"
        case phone = "registerPhone"
        case password = "registerPassword"
        case button = "registerButton"
        case back = "registerBack"
        case error = "registerError"
       //case errorMessage = "registerErrorMessage"
    }
    enum Profile : String{
        case general = "profileGeneral"
        case account = "profileAccount"
        case signOut = "profileSignOut"
        case language = "profileLanguage"
        case create = "profileCreate"
        case version = "profileVersion"
        case versionNumber = "profileVersionNumber"
        case english = "profileEnglish"
        case involved = "profileInvolved"
        case title = "profileTitle"
        case deleteAccount = "profileDelete"
        case deleteMessage = "profileDeleteMessage"
        case yesButton = "profileYes"
        case noButton = "profileNo"
        case loginMessage = "profileLogin"
    }
    enum Map: String{
        case tap = "mapTap"
    }
    enum CreatedEvent: String{
        case edit = "createdEdit"
        case users = "createdUsers"
        case delete = "createdDelete"
        case noEvent = "createdNoEvent"
        case select = "createdSelect"
        case addEvent = "createdAddEvent"
        case title = "createdEventTitle"
    }
    enum Category: String {
        case concert = "categoryConcert"
        case party = "categoryParty"
        case dinner = "categoryDinner"
        case barbecue = "categoryBarbecue"
        case sport = "categorySport"
        case other = "categoryOther"
        case all = "categoryAll"
    }
    enum Saved: String{
        case title = "savedTitle"
        case create = "savedCreate"
        case subtitle = "savedSubtitle"
    }
    enum EditProfile: String{
        case title = "editNavigationTitle"
        case image = "editImage"
        case personalInfo = "editPersonalInfo"
        case name = "editNameField"
        case phone = "editPhoneField"
        case reset = "editResetPassword"
        case okButton = "editAlertOkButton"
        case saveButton = "editSaveButton"
        case photoError = "photoError"
        case successTitle = "editSuccessTitle"
        case errorTitle = "editErrorTitle"
        case successMessage = "editSuccessMessage"
        case errorMessage = "editErrorMessage"
        case errorMessageResetPassword = "editErrorResetPassword"
        case successMessageResetPassword = "editSuccessResetPassword"
        case loading = "editIsLoading"
    }
    enum InvolvedEvent: String{
        case noEvent = "involvedNoEvent"
        case errorMessage = "errorLeaveEvent"
        case successMessage = "successLeaveEvent"
        case errorTitle = "errorTitleLeaveEvent"
        case successTitle = "successTitleLeaveEvent"
        case leaveEvent = "leaveEvent"
    }
    enum DetailEvent: String{
        case highlight = "detailHighlights"
        case users = "detailUsers"
        case location = "detailLocation"
        case reserve = "detailReserve"
        case requestSended = "detailSended"
        case publicStr = "detailPublic"
        case privateStr = "detailPrivate"
        case share = "detailShare"
        case call = "detailCall"
        case error = "detailErrorMessage"
        case close = "detailDescClose"
        case readMore = "detailDescReadMore"
    }
    enum Event: String{
        case title = "eventTitle"
        case select = "eventSelect"
        case create = "eventCreate"
        case upcoming = "eventUpcoming"
        case view = "eventView"
        case viewDetails = "eventViewDetails"
        case request = "eventRequest"
        case noRequest = "eventNoRequest"
        case noEvent = "eventNoEvent"
    }
    enum Home: String{
        case planner = "homePlanner"
        case search = "homeSearch"
        case noEvent = "homeNoEvent"
        case button = "homeButton"
        case refresh = "homeRefresh"
        case loginMessage = "homeLoginMessage"
        case saveEventMessage = "homeSaveMessage"
    }
    enum EditEvent: String{
        case name = "editEventName"
        case desc = "editEventDescription"
        case price = "editEventPrice"
        case type = "editEventType"
        case chatLink = "editChatLink"
        case chat = "editChat"
        case location = "editLocation"
        case go = "editGoTo"
        case publicStr = "editPublic"
        case cancel = "editCancel"
        case save = "editSave"
        case title = "editEventTitle"
        case photoError = "editEventPhotoError"
        case error = "editEventError"
        case okButton = "editEventOkButton"
        case groupChatLinkWrong = "editGroupChatLinkWrong"
        case cannotUpdate = "editCannotUpdateEvent"
        case errorMessage = "editEventErrorMessage"
        case imageSaveError = "editSavePhotoError"
        case saving = "editEventSaving"
        case cancelButton = "editCancelButton"
    }

}

extension String {
    func locale() -> LocalizedStringKey {
        return LocalizedStringKey(self)
    }
}
