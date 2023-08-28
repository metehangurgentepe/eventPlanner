//
//  Service.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 10.08.2023.
//
/*
import Foundation
import FirebaseCore
import FirebaseFirestore

struct Service{
    var event: Event
    let db = Firestore.firestore()
    
    func getEventData(eventUrl: String) async throws -> Event {
        db.collection("Events").whereField("eventUrl", isEqualTo: eventUrl).getDocuments{ snapshot, error in
            if let error = error{
                    
            }
            if let snapshot = snapshot{
               let events = snapshot.documents.compactMap{document -> Event? in
                   do{
                       let event = try document.data(as:Event.self)
                       return event
                   } catch{
                       return nil
                   }
               }
                DispatchQueue.main.async {
                    self.event = events
                }
                return event
            }
        }
    }
}*/
