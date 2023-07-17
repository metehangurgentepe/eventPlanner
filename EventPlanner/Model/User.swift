//
//  User.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 7.07.2023.
//

import Foundation

struct User: Identifiable, Hashable, Codable{
    let id : String
    let fullname : String
    let email : String
    let phoneNumber : String
    
    var initials: String{
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname){
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
extension User{
    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "Kobe Braynt ", email: "test@gmail.com", phoneNumber: "05079908165")
}
