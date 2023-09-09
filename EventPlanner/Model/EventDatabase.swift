//
//  EventDatabase.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 28.08.2023.
//

import Foundation
import FirebaseFirestore

struct EventDatabase : Identifiable, Codable, Equatable{
    let id : String
    let eventName : String
    let description : String
    let eventStartTime : String
    let eventLeadUser : String
    let eventPhoto : String
    let eventType : String
    let users : [String]
    let locationName : String
    let publicEvent : Bool
    let price : Int
    let phoneNumber : String
    let location : GeoPoint
    let eventUrl: String
    let groupChatLink: String
    
    static func ==(lhs:EventDatabase,rhs:EventDatabase) -> Bool{
        return lhs.id == rhs.id
    }
}

struct EventArray: Codable{
    let events: [Event]
    let total, skip, limit: Int
}
