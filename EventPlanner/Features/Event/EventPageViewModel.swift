//
//  EventViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 19.07.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseCore
import FirebaseFirestore


class EventPageViewModel: ObservableObject{
    @Published var upcomingEvent : Event?
    @Published var requestList : [Request] = []
    @Published var upcomingEventList : [Event] = []
    @Published var beforeList : [Event] = []
    @Published var request : [Request] = []
    @Published var upcomingPublicEvent : [Event] = []
    @Published var eventList : [Event] = []

    
    init(){
        getRequest()
        getUpcomingList()
        getBeforeList()
        getPublicUpcomingList()
        self.getEventById(eventIdList: requestList)
    }
    
    func getRequest(){
        let db = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else { return }
        
        db.collection("Request").getDocuments { snapshot, error in
            if let error = error{
                print(error.localizedDescription)
            }
            if let snapshot = snapshot {
                let requests = snapshot.documents.compactMap { document -> Request? in
                    do {
                        let request = try document.data(as: Request.self)
                        if request.receiverUser == email && request.status == Status.pending{
                            return request
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
                    self.requestList = requests
                    self.getEventById(eventIdList: self.requestList)
                }
            }
        }
    }
    
    func getEventById(eventIdList:Array<Request>){
        let db = Firestore.firestore()
        eventList.removeAll()
        //print(eventIdList.first)
        
        for i in 0..<eventIdList.count{
            db.collection("Events").document(eventIdList[i].eventId).getDocument { snapshot, error in
                if let error = error{
                    
                }
                if let snapshot = snapshot{
                    do{
                        print("event Id")
                        let event = try snapshot.data(as: Event.self)
                        if eventIdList[i].status == .pending{
                            self.eventList.append(event)
                            print(self.eventList.count)
                        }
                    } catch {
                        
                    }
                }
            }
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
    
    func acceptRequest(requestId:String,eventId:String,sender:String){
        let db = Firestore.firestore()
        
        
        let requestRef = db.collection("Request").document(requestId)
        
        
        requestRef.updateData(["status": Status.approved.rawValue]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                let addEvent = db.collection("Events").document(eventId)
                addEvent.updateData([
                    "users": FieldValue.arrayUnion([sender])
                ]){ error in
                    if let error = error {
                        print("Error adding user to event: \(error)")
                    } else {
                        print("User successfully added to event!")
                    }
                    
                }
            }
        }
    }
    
    func rejectRequest(requestId:String){
        let db = Firestore.firestore()
        let requestRef = db.collection("Request").document(requestId)
        
        requestRef.updateData(["status": Status.rejected.rawValue]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated!")
            }
        }
    }
    
    func getUpcomingList(){
        let date = Date()
        let db = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else { return }
        
        
        db.collection("Events").whereFilter(Filter.andFilter([
            Filter.whereField("eventStartTime",isGreaterThan: date.description),
            Filter.whereField("users",arrayContains: email)
        ])).getDocuments { snapshot, error in
            if let error = error {
                // Handle the error
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            if let snapshot = snapshot {
                let upcomingEvents = snapshot.documents.compactMap { document -> Event? in
                    do {
                        let upcomingEvent = try document.data(as: Event.self)
                        return upcomingEvent
                    } catch {
                        // Handle the decoding error
                        print("Error decoding document: \(error.localizedDescription)")
                        return nil
                    }
                }
                DispatchQueue.main.async {
                    self.upcomingEventList = upcomingEvents
                }
            }
        }
    }
    
    func getPublicUpcomingList(){
        
        let date = Date()
        let db = Firestore.firestore()
        
        
        db.collection("Events").whereFilter(Filter.andFilter([
            Filter.whereField("eventStartTime",isGreaterThan: date.description),
            Filter.whereField("publicEvent", isEqualTo: true)
        ])).getDocuments { snapshot, error in
            if let error = error {
                // Handle the error
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            if let snapshot = snapshot {
                let upcomingEvents = snapshot.documents.compactMap { document -> Event? in
                    do {
                        let upcomingEvent = try document.data(as: Event.self)
                        return upcomingEvent
                    } catch {
                        // Handle the decoding error
                        print("Error decoding document: \(error.localizedDescription)")
                        return nil
                    }
                }
                DispatchQueue.main.async {
                    self.upcomingPublicEvent = upcomingEvents
                }
            }
        }
        
    }
    
    
    
    func getBeforeList(){
        let date = Date()
        
        let db = Firestore.firestore()
        //   guard let email = Auth.auth().currentUser?.email else { return }
        guard let email = Auth.auth().currentUser?.email else { return }
        
        db.collection("Events").whereFilter(Filter.andFilter([
            Filter.whereField("eventStartTime", isLessThan: date.description),
            Filter.whereField("users",arrayContains: email)
        ])).getDocuments { snapshot, error in
            if let error = error {
                // Handle the error
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            if let snapshot = snapshot {
                let events = snapshot.documents.compactMap { document -> Event? in
                    do {
                        let event = try document.data(as: Event.self)
                        if event.users.contains(email){
                            return event
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
                    self.beforeList = events
                }
            }
        }
    }
        
}
