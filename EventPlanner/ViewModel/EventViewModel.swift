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
    @Published var currentUser : User?
    @Published var createEventError: Error?
    @Published var userSession : FirebaseAuth.User?
    @Published var detailEvent : Event?
    @Published var list = [Event]()
    @Published var userEventList = [Event]()
    @Published var isValid : Bool = false
    @Published var success : Bool = false
    @Published var upcomingList = [Event]()
    @Published var beforeList = [Event]()

    
    
    let db = Firestore.firestore()
    
    
    func createEvent(name:String,type:String,price:String,description:String,location:String,isPublic:Bool,date:Date,imageUrl:String,latitude:Double,longitude:Double,phoneNumber:String) async throws{
        do{
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            guard let email = Auth.auth().currentUser?.email else { return }
            
            
            
            let eventID = UUID()
            let event = Event(id:eventID.uuidString , eventName: name, description: description, eventStartTime: date.description, eventLeadUser: email, eventPhoto:imageUrl, eventType: type, users: [email], location: location, publicEvent: isPublic, price: Int(price) ?? 0, phoneNumber: phoneNumber,latitude: latitude,longitude: longitude)
            let encodedEvent = try Firestore.Encoder().encode(event)
            
            
            
            try await db.collection("Events").document().setData(encodedEvent) { error in
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
    
    func form2IsValid(image:UIImage,nowDate:Date,annotation:AnnotationStore,desc:String,location:String,eventTime:Date) -> Alert{
        if image == nil {
            return Alert(title: Text("Error"), message: Text("Image is empty, select Image"), dismissButton: .default(Text(LocaleKeys.addEvent.okButton.rawValue.locale())))
        } else if eventTime < nowDate{
           return Alert(title: Text("Error"), message: Text("You can not select time before now"), dismissButton: .default(Text(LocaleKeys.addEvent.okButton.rawValue.locale())))
        } else if annotation == nil {
           return Alert(title: Text("Error"), message: Text("Select place in map"), dismissButton: .default(Text(LocaleKeys.addEvent.okButton.rawValue.locale())))
        } else if desc == "" {
           return Alert(title: Text("Error"), message: Text("Enter description"), dismissButton: .default(Text(LocaleKeys.addEvent.okButton.rawValue.locale())))
        } else if location == "" {
           return Alert(title: Text("Error"), message: Text("Location Name is empty"), dismissButton: .default(Text(LocaleKeys.addEvent.okButton.rawValue.locale())))
        }
        return Alert(title: Text("Success"))
    }
    
    func getEventDetail(eventId: String, completion: @escaping (Event?, Error?) -> Void) {
        let db = Firestore.firestore()
        let eventsCollection = db.collection("Events")
        let eventDocument = eventsCollection.document(eventId)
        
        eventDocument.getDocument { (document, error) in
            if let error = error {
                // Handle error
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists else {
                // Event document does not exist
                completion(nil, nil)
                return
            }
            
            // Parse event details from the document data
            if let eventData = document.data() {
                do {
                    let decoder = Firestore.Decoder()
                    let event = try decoder.decode(Event.self, from: eventData, in: eventDocument)
                    completion(event, nil)
                } catch {
                    // Failed to parse event details
                    completion(nil, error)
                }
            } else {
                // Failed to retrieve event data
                completion(nil, nil)
            }
        }
    }
    
    func getPublicData() {
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        // Read the documents at a specific path
        db.collection("Events").getDocuments { snapshot, error in
            if let error = error {
                // Handle the error
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            // Check for errors
            if error == nil {
                // No errors
                
                if let snapshot = snapshot {
                    // Get all the documents and create Events
                    let events = snapshot.documents.compactMap { document -> Event? in
                        if let data = document.data() as? [String:Any], let isPublic = data["publicEvent"] as? Bool,isPublic == true {
                            guard let data = document.data() as? [String:Any],
                                  let id = data["id"] as? String,
                                  let eventName = data["eventName"] as? String,
                                  let description = data["description"] as? String,
                                  let eventStartTime = data["eventStartTime"] as? String,
                                  let eventLeadUser = data["eventLeadUser"] as? String,
                                  let eventPhoto = data["eventPhoto"] as? String,
                                  let eventType = data["eventType"] as? String,
                                  let users = data["users"] as? [String],
                                  let location = data["location"] as? String,
                                  let publicEvent = data["publicEvent"] as? Bool,
                                  let price = data["price"] as? Int,
                                  let phoneNumber = data["phoneNumber"] as? String else {
                                // Invalid data, skip this document
                                return nil
                            }
                            return Event(id: id, eventName: eventName, description: description, eventStartTime: eventStartTime, eventLeadUser: eventLeadUser, eventPhoto: eventPhoto, eventType: eventType, users: users, location: location, publicEvent: publicEvent, price:price, phoneNumber: phoneNumber, latitude: 1.23, longitude: 1.23)
                        }
                        return nil
                        
                    }
                    
                    // Update the list property in the main thread
                    DispatchQueue.main.async {
                        self.list = events
                    }
                }
            } else {
                // Handle the error
            }
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
        
        guard let resizedImage = image.jpegData(compressionQuality: 0.4) else{
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
                if let currentUser = try? Firestore.Decoder().decode(User.self, from: documentData) {
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
