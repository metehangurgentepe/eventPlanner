//
//  User.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 7.07.2023.
//

import Foundation

struct UserModel: Identifiable, Codable{
    let id : String
    let fullname : String
    let email : String
    let phoneNumber : String
    let imageUrl : String
    let fcmToken: String
    
    var initials: String{
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname){
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
extension UserModel{
    static var MOCK_USER = UserModel(id: NSUUID().uuidString, fullname: "Kobe Braynt ", email: "test@gmail.com", phoneNumber: "05079908165", imageUrl: "asdas", fcmToken: "")
}
