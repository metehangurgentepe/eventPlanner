//
//  SavedEventViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 24.07.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class SavedEventViewModel: ObservableObject{
    @Published var alertMessage : String = ""
    @Published private(set) var savedEventIds : [String] = []
    @Published var events : [EventDatabase] = []
    @Published var likedEvent : SavedEvent?
    @Published var countOfEvents : Int = -1
    @Published var errorMessage : String = ""
    @Published var showAlert: Bool = false
    let db = Firestore.firestore()
    
    func getSavedEvents() async throws{
        do{
            self.events = try await SavedEventManager.shared.getSavedEvents()
        } catch {
            showAlert = true
            errorMessage = error.localizedDescription
        }
    }
    
    func addListenerForSavedEvents() async{
        guard let email = Auth.auth().currentUser?.email else {return}
        SavedEventManager.shared.addListenerSavedEvent {[weak self] events in
            self?.savedEventIds = events
        }
        do{
            try await convertToEvent(eventIdList: savedEventIds)
        } catch{
            showAlert = true
            errorMessage = error.localizedDescription
        }
    }
    
    

    func convertToEvent(eventIdList: [String]) async throws{
        var events: [EventDatabase] = []
        for id in savedEventIds {
                events.append(try await db.collection("Events").document(id).getDocument(as: EventDatabase.self))
        }
        print(events)
        self.events = events.compactMap { $0 } // Remove nil values
    }


}
