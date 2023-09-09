//
//  Event.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 9.07.2023.
//

import Foundation
import CoreLocation

struct Event : Identifiable, Hashable, Codable{
    var id : String
    var eventName : String
    var description : String
    var eventStartTime : String
    var eventLeadUser : String
    var eventPhoto : String
    var eventType : String
    var users : [String]
    var location : String
    var publicEvent : Bool
    var price : Int
    var phoneNumber : String
    var latitude: Double
    var longitude : Double
    var eventUrl: String
    var groupChatLink: String
}

