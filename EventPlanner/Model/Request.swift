//
//  Request.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 20.07.2023.
//

import Foundation


struct Request: Identifiable, Hashable, Codable {
    let id : String
    let receiverUser: String
    let senderUser: String
    let dateTime: Date
    let eventName: String
    let eventId: String
    let status: Status
}

enum Status: String, Codable {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
}
