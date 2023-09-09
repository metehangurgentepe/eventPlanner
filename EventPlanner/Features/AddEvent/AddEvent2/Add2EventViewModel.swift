//
//  Add2EventViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 29.08.2023.
//

import Foundation
import PhotosUI
import SwiftUI
import FirebaseAuth
import MapKit
import FirebaseFirestore

protocol AddEvent2FormProtocol{
    var formIsValid : Bool { get }
}
protocol AddEventFormProtocol{
    var formIsValid : Bool { get }
}

class Add2EventViewModel: ObservableObject{
    @Published var data : Data?
    @Published var selectedItem: [PhotosPickerItem] = []
    @Published var location = ""
    @Published var isPublic = false
    @Published var imageUrl = ""
    @Published var eventTime = Date()
    @Published var selectedImage: UIImage?
    @Published var showAlert = false
    @Published var success = false
    @Published var price = ""
    @Published var errorMessage = ""
    @Published var isSaving = false
    //@ObservedObject var authManager = AuthManager()
    
    func createEvent(name:String,type:String,desc:String,annotation: MKPointAnnotation) async throws {
        guard let email = Auth.auth().currentUser?.email else {return}
        let id = UUID().uuidString
        let time = eventTime
        print(time)
        let user = try await AuthenticationManager.shared.fetchUser()
        // url
        let urlId = UUID()
        let url = "evplanner://event_id=\(urlId)"
        
    
        switch true {
        case data == nil:
            showAlert = true
            self.errorMessage = LocaleKeys.addEvent.photoError.rawValue
            
        case eventTime < Date():
            showAlert = true
            self.errorMessage = LocaleKeys.addEvent.timeError.rawValue
            
        case price.isEmpty:
            showAlert = true
            self.errorMessage = LocaleKeys.addEvent.priceError.rawValue
            
        case location.isEmpty:
            showAlert = true
            self.errorMessage = LocaleKeys.addEvent.locationError.rawValue
       
        default:
            isSaving = true
            
            imageUrl = try await saveImage()
            let event = EventDatabase(id: id, eventName: name, description: desc, eventStartTime: time.description, eventLeadUser: email, eventPhoto: imageUrl, eventType: type, users: [email], locationName: location, publicEvent: isPublic, price: Int(price) ?? 0, phoneNumber: user!.phoneNumber, location: GeoPoint(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), eventUrl: url, groupChatLink: "")
            try await EventsManager.shared.createEvent(event: event)
            isSaving = false
            success = true
            
        }
    }
    func saveImage() async throws -> String{
        if let data = data{
            if let image = UIImage(data: data){
                return try await EventsManager.shared.saveImage(image: image)
            }
        }
        return ""
    }
}
