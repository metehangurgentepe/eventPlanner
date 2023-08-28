//
//  Icons.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 11.07.2023.
//

import Foundation

struct IconItemString{
    enum TabView : String{
        case home = "house.fill"
        case event = "event.tab"
        case saved = "heart.fill"
        case account = "person.fill"
    }
    
    enum EventView : String{
        case name = "person"
        case type = "ticket.fill"
        case price = "dollarsign.circle"
        case next = "arrow.right"
        case photo = "photos"
        case location = "location.circle"
        case barTitle = "addBarTitle"
        case description = "text.justify"
        case locationTextField = "location"
    }
    
    enum Profile : String{
        case settings = "gear"
        case signOut = "arrow.left.circle.fill"
        case language = "globe"
        case create = "person.badge.key.fill"
    }
    
    enum Register : String{
        case back = "chevron.left"
        case name = "person"
        case password = "key"
        case phone = "phone"
        case email = "envelope"
    }
    
    enum Login : String{
        case next = "chevron.right"
        case mustLogin = "must_login"
        case login = "envelope"
        case password = "key"
        case name = "person"
    }
    enum AddEvent: String{
        case next = "arrow.right"
    }
    
    enum Category: String {
        case concert = "music.mic"
        case party = "party.popper.fill"
        case dinner = "dinner"
        case barbecue = "wineglass.fill"
        case sport = "soccerball"
        case other = "other"
    }
    enum EditProfile: String{
        case camera = "camera.fill"
    }
    enum DetailEvent: String{
        case backButton = "arrow.backward"
        case network = "network"
        case calendar = "calendar"
        case clock = "clock"
        case dollar = "dollarsign"
        case phone = "phone"
        case person = "person"
        case location = "location"
        case privateIcon = "eye.slash.fill"
    }
    enum Event: String{
        case click = "cursorarrow.click"
        case camera = "camera.fill"
        case tick = "checkmark.circle"
        case close = "xmark.circle"
        case select = "arrow.down"
    }
    enum Home: String{
        case network = "network"
        case click = "arrow.down"
        case plus = "plus"
        case back = "arrow.left"
        case search = "magnifyingglass"
        case close = "xmark.circle.fill"
        case list = "list.dash"
        case liked = "heart.fill"
        case unliked = "heart"
        case logo = "Logo"
    }
    
}
