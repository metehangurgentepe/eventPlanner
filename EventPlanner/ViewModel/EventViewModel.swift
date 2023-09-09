//
//  EventViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 9.07.2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UIKit
import SwiftUI

protocol EventFormProtocol{
    var formIsValid : Bool { get }
}

class EventViewModel : ObservableObject{
    static let shared = EventViewModel()
    @Published var currentUser : UserModel?
    @Published var createEventError: Error?
    @Published var userSession : FirebaseAuth.User?
    @Published var detailEvent : Event?
    @Published var list = [Event]()
    @Published var userEventList = [Event]()
    @Published var isValid : Bool = false
    @Published var success : Bool = false
    @Published var upcomingList = [Event]()
    @Published var beforeList = [Event]()
    @Published var eventDetail : [Event] = []
    let db = Firestore.firestore()
    
    
    func createEvent(name:String,type:String,price:String,description:String,location:String,isPublic:Bool,date:Date,imageUrl:String,latitude:Double,longitude:Double,phoneNumber:String) async throws{
        do{
            guard let email = Auth.auth().currentUser?.email else { return }
            
            let eventID = UUID()
            let urlId = UUID()
            let url = "evplanner://event_id=\(urlId)"
            let event = Event(id:eventID.uuidString , eventName: name, description: description, eventStartTime: date.description, eventLeadUser: email, eventPhoto:imageUrl, eventType: type, users: [email], location: location, publicEvent: isPublic, price: Int(price) ?? 0, phoneNumber: phoneNumber,latitude: latitude,longitude: longitude, eventUrl: url, groupChatLink: "")
            let encodedEvent = try Firestore.Encoder().encode(event)
            
            try db.collection("Events").document(eventID.uuidString).setData(encodedEvent) { error in
                if let error = error {
                    // Handle the error
                    print("Error setting data: \(error.localizedDescription)")
                } else {
                    // Data set successfully
                    print("successssssss")
                }
            }
            
        } catch {
            createEventError = error
            print(error.localizedDescription)
        }
    }
    
    func convertToDate(dateStr:String) -> String{
        let dateFormatter = DateFormatter()

        // Set the input format to match the given timestamp
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        if let date = dateFormatter.date(from: dateStr) {
            // Set the desired output format
            dateFormatter.dateFormat = "dd MMMM"
            
            // Format the Date object as "14 September"
            let formattedDateStr = dateFormatter.string(from: date)
            return formattedDateStr // Output: 14 September
        } else {
            return dateStr
        }
    }
    
    func convertToTime(timeStr:String) -> String{
        let dateFormatter = DateFormatter()

        // Set the input format to match the given timestamp
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

        // Parse the timestamp string to a Date object
        if let date = dateFormatter.date(from: timeStr) {
            // Set the desired output format for time
            dateFormatter.dateFormat = "HH:mm"
            
            // Format the Date object to get the time in 24-hour format
            let formattedTimeStr = dateFormatter.string(from: date)
            return formattedTimeStr // Output: 16:03
        } else {
            return timeStr
        }
    }
    
    func formIsValid(name:String,type:String,price:String){
        func isNumericString(_ string: String) -> Bool {
            let numericRegex = "^[0-9]+$"
            let numericPredicate = NSPredicate(format: "SELF MATCHES %@", numericRegex)
            return numericPredicate.evaluate(with: string)
        }
        if !name.isEmpty && !type.isEmpty && isNumericString(price){
            isValid = true
        }
    }
    
    
    
    
    func getUserEvents() {
        let db = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else { return }
        db.collection("Events").whereField("users", arrayContains: email).getDocuments { snapshot, error in
            if let error = error {
                // Handle the error
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot {
                let events = snapshot.documents.compactMap { document -> Event? in
                    do {
                        let event = try document.data(as: Event.self)
                        return event
                    } catch {
                        // Handle the decoding error
                        print("Error decoding document: \(error.localizedDescription)")
                        return nil
                    }
                }
                DispatchQueue.main.async {
                    self.userEventList = events
                }
            }
        }
    }
    
    func getUpcomingList(){
       let date = Date()
        let db = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else { return }
        db.collection("Events").whereField("eventStartTime",isGreaterThan: date.description).getDocuments { snapshot, error in
            if let error = error {
                // Handle the error
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            if let snapshot = snapshot {
                let upcomingEvents = snapshot.documents.compactMap { document -> Event? in
                    do {
                        let upcomingEvent = try document.data(as: Event.self)
                        if upcomingEvent.users.contains(email){
                            print(upcomingEvent)
                            return upcomingEvent
                        } else {
                            return nil
                        }
                        
                    } catch {
                        // Handle the decoding error
                        print("Error decoding document: \(error.localizedDescription)")
                        return nil
                    }
                }
                DispatchQueue.main.async {
                    self.upcomingList = upcomingEvents
                }
            }
        }
    }
    
    func getBeforeList(){
        let date = Date()
        
        let db = Firestore.firestore()
     //   guard let email = Auth.auth().currentUser?.email else { return }
       
        db.collection("Events").whereField("eventStartTime", isLessThan: date.description).getDocuments { snapshot, error in
            if let error = error {
                // Handle the error
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            if let snapshot = snapshot {
                let events = snapshot.documents.compactMap { document -> Event? in
                    do {
                        let event = try document.data(as: Event.self)
                        return event
                    } catch {
                        // Handle the decoding error
                        print("Error decoding document: \(error.localizedDescription)")
                        return nil
                    }
                }
                DispatchQueue.main.async {
                    self.beforeList = events
                }
            }
        }
    }
    
    
    
    func saveImage(image:UIImage) async -> String{
            let photoName = UUID().uuidString
            let storage = Storage.storage()
            let storageRef = storage.reference().child("\(photoName).jpeg")
            
            guard let resizedImage = image.jpegData(compressionQuality: 0.25) else{
                return ""
            }
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            
            var imageUrlString = ""
            
            do{
                let _ = try await storageRef.putDataAsync(resizedImage,metadata: metadata)
                do{
                    let imageURL = try await storageRef.downloadURL()
                    imageUrlString = "\(imageURL)"
                    print(imageUrlString)
                } catch {
                    
                }
            }catch{
                print("error upload photo ")
            }
            return imageUrlString
        }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let documentRef = Firestore.firestore().collection("Users").document(uid)
            let documentSnapshot = try await documentRef.getDocument()
            
            if let documentData = documentSnapshot.data() {
                if let currentUser = try? Firestore.Decoder().decode(UserModel.self, from: documentData) {
                    self.currentUser = currentUser
                } else {
                    print("Error decoding user data")
                }
            } else {
                print("User document does not exist")
            }
        } catch {
            print("Error fetching user: \(error)")
        }
    }
}
