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
    @Published var savedEventIds : [String] = []
    @Published var events : [Event] = []
    @Published var likedEvent : SavedEventModel?
    @Published var countOfEvents : Int = -1
    
    let db = Firestore.firestore()
    
    init(){
        print("init içinde")
        countOfEvents = self.lengthofEvents()
        Task{
            await getSavedEvents()
        }
    }
    
    func lengthofEvents() -> Int {
        let email = Auth.auth().currentUser?.email
        db.collection("SavedEvents").document(email!.lowercased()).getDocument { snapshot, error in
             if let error = error {
                 self.alertMessage = "\(error.localizedDescription)"
             }
             if let snapshot = snapshot {
                 do {
                     let event = try snapshot.data(as: SavedEventModel.self)
                     self.countOfEvents = event.eventsId.count
                     print(self.countOfEvents)
                 } catch {
                     self.alertMessage = "\(error.localizedDescription)"
                 }
             }
         }
        print(countOfEvents)
        return countOfEvents
    }
    
    func getSavedEvents() async{
        guard let email = Auth.auth().currentUser?.email else { return }
       db.collection("SavedEvents").document(email.lowercased()).getDocument { snapshot, error in
            if let error = error {
                self.alertMessage = "\(error.localizedDescription)"
            }
            if let snapshot = snapshot {
                do {
                    print("buraya giriyor mu")
                    let event = try snapshot.data(as: SavedEventModel.self)
                    self.savedEventIds = event.eventsId
                    self.countOfEvents = event.eventsId.count
                    DispatchQueue.main.async {
                        //self.lengthofEvents(list:event.eventsId.count)
                        self.convertToEvent(eventIdList: self.savedEventIds)
                    }
                } catch {
                    self.alertMessage = "\(error.localizedDescription)"
                }
            }
        }
    }

    func convertToEvent(eventIdList: [String]) {
        events.removeAll()
        var tasksCount = eventIdList.count
        
        for eventId in eventIdList {
            if eventId != "" {
                db.collection("Events").document(eventId).getDocument { snapshot, error in
                    tasksCount -= 1
                    
                    if let error = error {
                        self.alertMessage = "\(error.localizedDescription)"
                    }
                    if let snapshot = snapshot {
                        do {
                            let event = try snapshot.data(as: Event.self)
                            self.events.append(event)
                        } catch {
                            self.alertMessage = "\(error.localizedDescription)"
                        }
                    }
                    
                    if tasksCount == 0 {
                    }
                }
            } else {
                tasksCount -= 1
            }
        }
    }

}
