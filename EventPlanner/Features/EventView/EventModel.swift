//
//  EventModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 16.07.2023.
//

import Foundation

struct EventModel: Identifiable{
    var id = UUID()
    var title : String
    var list : [Event]
    
    
    init(title: String, list: Array<Event>) {
        self.title = title
        self.list = list
    }
}
