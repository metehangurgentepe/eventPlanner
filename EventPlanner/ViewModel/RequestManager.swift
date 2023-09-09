//
//  RequestManager.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 29.08.2023.
//

import Foundation
import Firebase
import FirebaseAuth

final class RequestManager{
    static let shared = RequestManager()
    let locationManager = LocationManager()
    private init(){ }
    
    private let requestCollection = Firestore.firestore().collection("Request")
    private let privateEventsCollection = Firestore.firestore().collection("privateEvents")
    private let eventsCollection = Firestore.firestore().collection("Events")
    
    
    func getAllRequest() async throws -> [Request]{
        let email = Auth.auth().currentUser?.email
        return try await requestCollection
            .whereField("receiverUser", isEqualTo: email)
            .whereField("status", isEqualTo: "Pending")
            .getDocuments(as: Request.self)
    }
    
    func acceptRequest(request: Request) async throws{
        try await requestCollection.document(request.id).updateData(["status": Status.approved.rawValue])
        let addEvent = privateEventsCollection.document(request.eventId)
        let addAllEvents = eventsCollection.document(request.eventId)
        
        try await addAllEvents.updateData([
            "users": FieldValue.arrayUnion([request.senderUser])
        ])
        try await addEvent.updateData([
            "users": FieldValue.arrayUnion([request.senderUser])
        ])
    }
    
    func sendRequest(reqeiver:String,eventId:String,eventName:String) async throws{
        let date = Date()
        let id = UUID()
        guard let email = Auth.auth().currentUser?.email else{return}
        let request = Request(id: id.uuidString, receiverUser: reqeiver, senderUser: email, dateTime: date, eventName: eventName, eventId: eventId, status: .pending)
        let encodedRequest = try Firestore.Encoder().encode(request)
        
        try await requestCollection.document(id.uuidString).setData(encodedRequest)
        
    }
    
    func isRequestSended(eventId:String,receiver:String) async throws -> Bool {
        if let email = Auth.auth().currentUser?.email {
            if let request  = try await requestCollection
                .whereField("eventId", isEqualTo: eventId)
                .whereField("receiverUser", isEqualTo: receiver)
                .whereField("senderUser", isEqualTo: email)
                .getDocuments(as: Request.self).first{
                return true
            } else{
                return false
            }
        }
        return false
    }
    
    func rejectRequest(request: Request) async throws{
        try await requestCollection.document(request.id).delete()
    }
    
    func convertAllEvent(eventIdList: [String]) async throws -> [EventDatabase]{
        var events : [EventDatabase] = []
        for id in eventIdList{
            events.append(try await eventsCollection.document(id).getDocument(as: EventDatabase.self))
        }
        return events
    }
    
    func convertEvent(request:Request) async throws -> EventDatabase {
        return try await privateEventsCollection.document(request.eventId).getDocument(as: EventDatabase.self)
    }
    
}
