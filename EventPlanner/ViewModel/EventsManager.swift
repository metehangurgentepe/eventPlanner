//
//  EventsManager.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 28.08.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


final class EventsManager{
    static let shared = EventsManager()
    private init(){ }
    
    private let eventsCollection = Firestore.firestore().collection("Events")
    
   /* func uploadEvent(event:Event) async throws{
        let eventID = UUID()
        try eventsCollection.document(eventID.uuidString).setData(from:Event,merge: false)
    } */
}
