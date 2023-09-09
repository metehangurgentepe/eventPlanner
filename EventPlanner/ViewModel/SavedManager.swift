//
//  SavedManager.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 30.08.2023.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage


final class SavedEventManager{
    static let shared = SavedEventManager()
    private init(){ 
        
    }
    private let savedEventCollection = Firestore.firestore().collection("SavedEvents")
    
    func getSavedEventId() async throws -> SavedEvent {
        guard let email = Auth.auth().currentUser?.email else {
                // Handle the case when the user is not logged in or email is not available.
                // You can return an empty array or throw an error as needed.
                return SavedEvent(email: "", eventsId: [""])
        }
        return try await savedEventCollection.document(email).getDocument(as: SavedEvent.self)
    }
    
    func getSavedEvents() async throws -> [EventDatabase] {
        guard let email = Auth.auth().currentUser?.email else {
                // Handle the case when the user is not logged in or email is not available.
                // You can return an empty array or throw an error as needed.
                return []
        }
        var events : [EventDatabase] = []
        let eventsId = try await savedEventCollection.document(email).getDocument(as: SavedEvent.self)
        for id in eventsId.eventsId{
            if id != ""{
                events.append(try await EventsManager.shared.getEvent(id:id))
            }
        }   
        return events
    }
    
    func saveEvent(eventId:String) async throws {
        var email = Auth.auth().currentUser?.email
        try await savedEventCollection.document(email!).updateData(["eventsId": FieldValue.arrayUnion([eventId])])
    }
    
    func unsaveEvent(eventId:String) async throws {
        var email = Auth.auth().currentUser?.email
        try await savedEventCollection.document(email!).updateData(["eventsId":FieldValue.arrayRemove([eventId])])
    }
    
    func addListenerSavedEvent(completion: @escaping (_ events: [String]) -> Void) {
        guard let email = Auth.auth().currentUser?.email else { return }
        savedEventCollection.document(email).addSnapshotListener { querySnapshot, error in
            if let error = error {
                // Handle the error here, if needed
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot else { return }
            
            do {
                let events: SavedEvent = try documents.data(as: SavedEvent.self)
                completion(events.eventsId)
            } catch {
                // Handle the data parsing error here, if needed
                print("Data parsing error: \(error.localizedDescription)")
            }
        }
    }
}
