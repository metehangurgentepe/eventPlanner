//
//  SavedEvent.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 30.08.2023.
//

import Foundation

struct SavedEvent: Hashable, Codable{
    var email: String
    var eventsId : [String]
}
