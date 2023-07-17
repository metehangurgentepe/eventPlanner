//
//  Icons.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 11.07.2023.
//

import Foundation

struct IconItemString{
    enum TabView : String{
        case home = "house"
        case event = "bell"
        case message = "message"
        case account = "person"
    }
    
    enum EventView : String{
        case name = "person"
        case type = "ticket.fill"
        case price = "dollarsign.circle.fill"
        case next = "arrow.right"
        case photo = "photo"
        case location = "location.circle"
        case barTitle = "addBarTitle"
        case description = "text.justify"
        case locationTextField = "location"
    }
    
    enum Profile : String{
        case settings = "gear"
        case signOut = "arrow.left.circle.fill"
    }
    
    enum Register : String{
        case back = "chevron.left"
    }
    
    enum Login : String{
        case next = "chevron.right"
    }
    
}
