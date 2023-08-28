//
//  SavedEventModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 17.07.2023.
//

import Foundation

struct SavedEventModel: Hashable, Codable{
    var email: String
    var eventsId : [String]
}
