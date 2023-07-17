//
//  Event.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 9.07.2023.
//

import Foundation
import CoreLocation

struct Event : Identifiable, Hashable, Codable{
    let id : String
    let eventName : String
    let description : String
    let eventStartTime : String
    let eventLeadUser : String
    let eventPhoto : String
    let eventType : String
    let users : [String]
    let location : String
    let publicEvent : Bool
    let price : Int
    let phoneNumber : String
    let latitude: Double
    let longitude : Double
    
    
}


