//
//  CreatedEventViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 25.07.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


class CreatedEventViewModel: ObservableObject{
    @Published var alertMessage = ""
    @Published var createdEventList : [EventDatabase] = []
    @Published var isLoading : Bool = true
    
    let db = Firestore.firestore()
    
    init(){
        getCreatedEvent()
    }
    func getCreatedEvent(){
        guard let email = Auth.auth().currentUser?.email else { return }
        db.collection("Events").whereField("eventLeadUser", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error{
                self.alertMessage = "\(error.localizedDescription)"
            }
            
            if let snapshot = snapshot{
                let events = snapshot.documents.compactMap { document -> EventDatabase? in
                    do{
                        let event = try document.data(as: EventDatabase.self)
                        return event
                    } catch{
                        self.alertMessage = "\(error.localizedDescription)"
                        return nil
                    }
                }
                DispatchQueue.main.async {
                    self.createdEventList = events
                    self.isLoading = false
                }
            }
        }
    }
    
    
    func deleteEvent(eventId:String){
        do{
            db.collection("Events").document(eventId).delete()
            self.getCreatedEvent()
        } catch{
            self.alertMessage = "\(error.localizedDescription)"
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
    
}
