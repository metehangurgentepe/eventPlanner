//
//  EventsManager.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 28.08.2023.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase
import MapKit
import FirebaseStorage
import FirebaseCore
import SwiftUI

final class EventsManager{
    static let shared = EventsManager()
    var location = LocationManager()
    private let eventsCollection = Firestore.firestore().collection("Events")
    private let publicEventsCollection = Firestore.firestore().collection("publicEvents")
    private let privateEventsCollection = Firestore.firestore().collection("privateEvents")
    private var currentUser: UserModel?
    
    private init(){}
   
    func getUpcomingList() async throws -> [EventDatabase] {
        guard let email = Auth.auth().currentUser?.email else {return []}
        let date = Date()
        return try await eventsCollection
            .whereFilter(Filter.andFilter([
                Filter.whereField("eventStartTime",isGreaterThan: date.description),
                Filter.whereField("users",arrayContains: email)
            ]))
            .getDocuments(as: EventDatabase.self)
    }
    
    
    /* func uploadEvent(event:Event) async throws{
     let eventID = UUID()
     try eventsCollection.document(eventID.uuidString).setData(from:EventDatabase,merge: false)
     } */
    func saveImage(image:UIImage) async throws -> String{
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
    
    func calculateBoundingBox(center: CLLocationCoordinate2D, radiusInKilometers: Double) -> (minGeoPoint: GeoPoint, maxGeoPoint: GeoPoint) {
        
        // Merkez noktanın enlem ve boylam değerleri
        let centerLatitude = center.latitude
        let centerLongitude = center.longitude
        
        // 1 derece enlem değişimi yaklaşık olarak 111.32 km'ye karşılık gelir.
        let latitudeDegreesPerKilometer = 1.0 / 111.32
        
        // Yarıçapı kullanarak minimum ve maksimum enlem ve boylam değerlerini hesaplayın
        let minLatitude = centerLatitude - (radiusInKilometers * latitudeDegreesPerKilometer)
        let maxLatitude = centerLatitude + (radiusInKilometers * latitudeDegreesPerKilometer)
        
        // Bir derece boylam değişimi, belirli bir enlemdeki km cinsinden değişimi hesaplamak için kullanılır.
        // Örneğin, ekvator hizasındaki bir derece boylam değişimi yaklaşık olarak 111.32 km'ye karşılık gelir.
        // Ancak enlem açısına göre bu mesafe değişebilir.
        let longitudeDegreesPerKilometer = 1.0 / (111.32 * cos(centerLatitude * .pi / 180.0))
        
        let minLongitude = centerLongitude - (radiusInKilometers * longitudeDegreesPerKilometer)
        let maxLongitude = centerLongitude + (radiusInKilometers * longitudeDegreesPerKilometer)
        
        // Sonuçları GeoPoint türüne çevirin
        let minGeoPoint = GeoPoint(latitude: minLatitude, longitude: minLongitude)
        let maxGeoPoint = GeoPoint(latitude: maxLatitude, longitude: maxLongitude)
        
        return (minGeoPoint, maxGeoPoint)
    }
    @MainActor
    func getDistanceByUserDefaults() async throws -> Double{
        let userDefaults = UserDefaults.standard
        if userDefaults.double(forKey: "Distance") == 0 {
            userDefaults.setValue(1000, forKey: "Distance")
        }
        return userDefaults.double(forKey: "Distance")
    }
    
    
    func leaveEvent(eventId:String) async throws {
        let email = Auth.auth().currentUser?.email
        let event = try await privateEventsCollection.document(eventId).getDocument(as: EventDatabase.self)
        let users = event.users.filter {$0 != email}
        try await privateEventsCollection.document(eventId).updateData(["users":users])
        try await eventsCollection.document(eventId).updateData(["users":users])
    }
    
    
    func getInvolvedEvents() async throws -> [EventDatabase]{
        guard let email = Auth.auth().currentUser?.email else {return []}
        return try await privateEventsCollection.whereField("users", arrayContains: email.lowercased()).whereField("eventLeadUser", isNotEqualTo: email) .getDocuments(as: EventDatabase.self)
    }
    
    
    
    func getUserInEvent(eventId:String) async throws -> [String] {
        try await privateEventsCollection.document(eventId).getDocument(as: EventDatabase.self).users
    }
    
    
    func removeUserInEvent(email:String,eventId:String) async throws{
        let currentUser = Auth.auth().currentUser?.email
        let event = try await privateEventsCollection.document(eventId).getDocument(as: EventDatabase.self)
        if !(email.lowercased() == event.eventLeadUser.lowercased()) && !(currentUser?.lowercased() != event.eventLeadUser.lowercased()) {
            try await privateEventsCollection.document(eventId).updateData([
                "users": FieldValue.arrayRemove([email.lowercased()])])
        } else {
            throw MyError.userNotAllowed // Özel hatayı fırlat
        }
    }
    
    func getPublicUpcomingList() async throws -> [EventDatabase] {
        let date = Date()
        guard let email = Auth.auth().currentUser?.email else {return []}
        return try await eventsCollection
            .whereFilter(Filter.andFilter([
                Filter.whereField("eventStartTime",isGreaterThan: date.description),
                Filter.whereField("users",arrayContains: email)
            ]))
            .getPublicDocuments(as: EventDatabase.self)
    }
    
    func createEvent(event: EventDatabase) async throws{
        let encodedEvent = try Firestore.Encoder().encode(event)
        if event.publicEvent {  
            try await eventsCollection.document(event.id)
                .setData(encodedEvent)
            try await publicEventsCollection.document(event.id)
                .setData(encodedEvent)
        } else{
            try await eventsCollection.document(event.id)
                .setData(encodedEvent)
            try await privateEventsCollection.document(event.id)
                .setData(encodedEvent)
        }
    }
    
    func updateEvent(event:EventDatabase) async throws{
        let encodedEvent = try Firestore.Encoder().encode(event)
        if event.publicEvent {
            try await eventsCollection.document(event.id)
                .updateData(encodedEvent)
            try await publicEventsCollection.document(event.id)
                .updateData(encodedEvent)
        } else{
            try await eventsCollection.document(event.id)
                .updateData(encodedEvent)
            try await privateEventsCollection.document(event.id)
                .updateData(encodedEvent)
        }
    }
    
    func getEvent(id:String) async throws -> EventDatabase {
        try await eventsCollection.document(id).getDocument(as: EventDatabase.self)
    }
    
    func getEventByUrl(url:String) async throws -> EventDatabase {
        let events = try await eventsCollection.getDocuments(as: EventDatabase.self)
        return events.filter({ event in
            event.eventUrl == url
        }).first!
    }
    
    func getPublicEvent(count:Int,lastDocument:DocumentSnapshot?,location:CLLocationCoordinate2D?) async throws -> (events:[EventDatabase], lastDocument:DocumentSnapshot?){
        if let userLocation = location{
            let mesafe = try await self.getDistanceByUserDefaults()
            let (minGeoPoint, maxGeoPoint) = calculateBoundingBox(center: CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude), radiusInKilometers: mesafe)
            if let lastDocument{
                print("GEO POİNT")
                print((minGeoPoint,maxGeoPoint))
                return  try await publicEventsCollection
                    .order(by: "location")
                    .order(by: "eventStartTime", descending: true)
                    .whereField("location", isGreaterThan: minGeoPoint)
                    .whereField("location", isLessThan: maxGeoPoint)
                    .limit(to: count)
                    .start(afterDocument: lastDocument)
                    .getDocumentsWithSnapshot(as: EventDatabase.self)
            } else{
                return try await publicEventsCollection
                    .order(by: "location")
                    .order(by: "eventStartTime", descending: true)
                    .whereField("location", isGreaterThan: minGeoPoint)
                    .whereField("location", isLessThan: maxGeoPoint)
                    .limit(to: count)
                    .getDocumentsWithSnapshot(as: EventDatabase.self)
            }
        } else{
            if let lastDocument{
                return  try await publicEventsCollection
                    .limit(to: count)
                    .start(afterDocument: lastDocument)
                    .getDocumentsWithSnapshot(as: EventDatabase.self)
            } else{
                return try await publicEventsCollection
                    .limit(to: count)
                    .getDocumentsWithSnapshot(as: EventDatabase.self)
            }
        }
    }
    
    func getPublicEventFilteredByCategory(categoryName: String,count:Int,lastDocument:DocumentSnapshot?,location:CLLocationCoordinate2D?) async throws -> (events:[EventDatabase],lastDocument:DocumentSnapshot?) {
        if let userLocation = location{
            let mesafe = try await self.getDistanceByUserDefaults()
            let (minGeoPoint, maxGeoPoint) = calculateBoundingBox(center: CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude), radiusInKilometers: mesafe)
            print((minGeoPoint,maxGeoPoint))
            print("GEOOOOOOOO POİİİNNTTTTTT")

            if let lastDocument{
                return try await publicEventsCollection
                    .whereField("location", isGreaterThan: minGeoPoint)
                    .whereField("location", isLessThan: maxGeoPoint)
                    .whereField("eventType", isEqualTo: categoryName)
                    .limit(to: count)
                    .start(afterDocument: lastDocument)
                    .getDocumentsWithSnapshot(as: EventDatabase.self)
            } else {
                return  try await publicEventsCollection
                    .whereField("location", isGreaterThan: minGeoPoint)
                    .whereField("location", isLessThan: maxGeoPoint)
                    .whereField("eventType", isEqualTo: categoryName)
                    .limit(to: count)
                    .getDocumentsWithSnapshot(as: EventDatabase.self)
            }
        }
        else{
            if let lastDocument{
                return   try await publicEventsCollection
                    .whereField("eventType", isEqualTo: categoryName)
                    .limit(to: count)
                    .start(afterDocument: lastDocument)
                    .getDocumentsWithSnapshot(as: EventDatabase.self)
            } else {
                return try await publicEventsCollection
                    .whereField("eventType", isEqualTo: categoryName)
                    .limit(to: count)
                    .getDocumentsWithSnapshot(as: EventDatabase.self)
            }
        }
    }
}

extension Query {
    func getDocuments<T>(as type:T.Type) async throws -> [T] where T: Decodable {
        try await getDocumentsWithSnapshot(as: type).events
    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type ) async throws -> (events: [T], lastDocument: DocumentSnapshot?) where T: Decodable{
        let snapshot = try await self
            .getDocuments()
        let events = try snapshot.documents.map { document in
            try document.data(as: T.self)
        }
        
        return (events, snapshot.documents.last)
    }
    
    func getPublicDocuments(as type: EventDatabase.Type ) async throws -> [EventDatabase] {
        return try await getDocumentsWithSnapshot(as: EventDatabase.self).events
    }
    
    
    
}
enum MyError: Error {
    case userNotAllowed
}
