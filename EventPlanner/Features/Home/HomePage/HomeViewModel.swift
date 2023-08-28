//
//  HomeViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 17.07.2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UIKit
import SwiftUI
import CoreLocation


class HomeViewModel : ObservableObject{
    static let shared = HomeViewModel()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var publicEventList : [Event] = []
    @Published var animate : Bool = false
    let db = Firestore.firestore()
    @Published var selectedCategory : String = ""
    @Published var savedEvent : [String] = []
    @Published var savedPost : SavedEventModel?
    let locationManager = LocationManager()
    @Published var isLoading : Bool = true
    
    init(){
        Task{
            await self.getSavedPost()
        }
        Task{
            await getPublicData(searchQuery:"",category:"")
        }
    }
    
    
    @MainActor
    func getPublicData(searchQuery: String, category: String) {
        guard let email = Auth.auth().currentUser?.email else { return }
        var query = db.collection("Events")
            .whereField("publicEvent", isEqualTo: true)
        
        // Add search query filter
        if !searchQuery.isEmpty {
            // Using stringContains filter for partial search
            query = query.whereField("eventName", isGreaterThanOrEqualTo: searchQuery)
                .whereField("eventName", isLessThanOrEqualTo: searchQuery + "\u{f8ff}")
        }
        
        // Add category filter
        if !selectedCategory.isEmpty {
            if selectedCategory == "categoryOther"{
                
            }else{
                query = query.whereField("eventType", isEqualTo: selectedCategory)
            }
        }
        if let userLocation = locationManager.location?.coordinate{
            Task{
                do{
                    // let mesafe = try await self.getDistance()
                    let dissss = try await self.getDistanceByUserDefaults()
                    query.getDocuments  { snapshot, error in
                        if let error = error {
                            // Handle the error
                            print("Error fetching documents: \(error.localizedDescription)")
                            return
                        }
                        if let snapshot = snapshot {
                            let events = snapshot.documents.compactMap { document -> Event? in
                                do {
                                    let event = try document.data(as: Event.self)
                                    let eventLatitude = event.latitude
                                    let eventLongitude = event.longitude
                                    let eventLocation = GeoPoint(latitude: eventLatitude, longitude: eventLongitude)
                                    let userCurrentLocation = GeoPoint(latitude:userLocation.latitude, longitude: userLocation.longitude)
                                    // Kullanıcının konumunu ve etkinliğin konumunu karşılaştırarak sınırları kontrol edin.
                                    let distance = self.calculateDistance(userCurrentLocation, eventLocation)
                                    // Örneğin, kullanıcının 200 km içindeki etkinlikleri almak için bir sınırlama ekleyebilirsiniz.
                                    
                                    // distance değerini alma
                                    if distance <= dissss {
                                        return event
                                    } else{
                                        return nil
                                    }
                                } catch {
                                    // Handle the decoding error
                                    print("Error decoding document: \(error.localizedDescription)")
                                    return nil
                                }
                            }
                            DispatchQueue.main.async {
                                self.publicEventList = events
                                self.isLoading = false
                            }
                        }
                    }
                } catch{
                    
                }
            }
            
        } else {
            query.getDocuments { snapshot, error in
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
                        self.publicEventList = events
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    @MainActor
    func getDistanceByUserDefaults() async throws -> Double{
        let userDefaults = UserDefaults.standard
        return userDefaults.double(forKey: "Distance")
    }
    
    func calculateDistance(_ point1: GeoPoint, _ point2: GeoPoint) -> Double {
        let radiusOfEarthKm: Double = 6371.0 // Dünya yarıçapı, kilometre cinsinden
        
        let lat1 = point1.latitude * .pi / 180.0
        let lon1 = point1.longitude * .pi / 180.0
        let lat2 = point2.latitude * .pi / 180.0
        let lon2 = point2.longitude * .pi / 180.0
        
        let dlon = lon2 - lon1
        let dlat = lat2 - lat1
        
        let a = sin(dlat / 2) * sin(dlat / 2) + cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        let distance = radiusOfEarthKm * c
        
        return distance
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
    
    
    
    func savePost(eventId:String){
        guard let email = Auth.auth().currentUser?.email else { return }
        
        let data = ["email":email,"eventsId": FieldValue.arrayUnion([eventId])] as [String : Any]
        let removeData = ["eventsId": FieldValue.arrayRemove([eventId])] as [String : Any]
        let ref = db.collection("SavedEvents").document(email)
        let query = db.collection("SavedEvents").document(email).parent.whereField("eventsId", arrayContains: eventId)
        
        
        // check if saved post user
        ref.getDocument(completion: { snapshot, error in
            if error != nil{
                print(error!.localizedDescription)
            }
            // self.isSavedPost()
            if let snapshot = snapshot, snapshot.exists {
                // if saved post user update data
                
                self.getSavedPost()
                if let array = self.savedPost?.eventsId{
                    if array.contains(eventId){
                        ref.updateData(removeData){ error in
                            if let error = error{
                                print("Error saving document: \(error.localizedDescription)")
                            }
                        }
                    }else{
                        ref.updateData(data){ error in
                            if let error = error{
                                print("Error saving document: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        })
    }
    @MainActor
    func getSavedPost(){
        guard let email = Auth.auth().currentUser?.email else{return}
        
        db.collection("SavedEvents").whereField("email", isEqualTo: email).getDocuments{ snapshot, error in
            if let snapshot = snapshot{
                let events = snapshot.documents.compactMap { query -> SavedEventModel? in
                    do{
                        let savedEvents = try query.data(as: SavedEventModel.self)
                        return savedEvents
                    } catch{
                        print("error:\(error.localizedDescription)")
                    }
                    return nil
                }
                if events.isEmpty{
                    let ref = self.db.collection("SavedEvents").document(email)
                    let data = ["email":email,"eventsId": [""]] as [String : Any]
                    ref.setData(data) { error in
                        if let error = error {
                            // Handle the error
                            print("Error saving document: \(error.localizedDescription)")
                        } else {
                            print("Document saved successfully!")
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.savedPost = events.first
                }
            }
        }
    }
}
