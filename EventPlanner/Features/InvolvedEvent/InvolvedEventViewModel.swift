//
//  InvolvedEventViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 19.08.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class InvolvedEventViewModel: ObservableObject{
    @Published var showAlert : Bool = false
    @Published var errorMessage = ""
    @Published var eventList : [Event] = []
    @Published var isLoading : Bool = true
    @Published var errorTitle = ""

    
    let db = Firestore.firestore()
    init(){
        self.userInEvent()
    }
    
    func userInEvent(){
        let email = Auth.auth().currentUser?.email
        db.collection("Events").whereField("users", arrayContains: email!).getDocuments { snapshot, error in
            if let error = error{
                self.errorMessage = error.localizedDescription
            }
            if let snapshot = snapshot {
               var events = snapshot.documents.compactMap { document -> Event? in
                    do{
                        let event = try document.data(as: Event.self)
                        if event.eventLeadUser != email{
                           // self.eventList.append(event)
                            return event
                        }
                        return nil
                    } catch {
                        self.showAlert = true
                        return nil
                    }
                }
                DispatchQueue.main.async {
                    self.eventList = events
                    self.isLoading = false
                }
               
            }
        }
    }
    
    func leaveEvent(eventId: String) {
        guard let email = Auth.auth().currentUser?.email else {
            // Handle the case where the current user's email is not available.
            return
        }
        
        db.collection("Events").document(eventId).getDocument { (document, error) in
            if let error = error {
                // Handle the error.
                self.showAlert = true
                self.errorMessage = LocaleKeys.InvolvedEvent.errorMessage.rawValue
                self.errorTitle =
                LocaleKeys.InvolvedEvent.errorTitle.rawValue
                print("Error getting event document: \(error)")
                return
            }
            
            if let document = document, document.exists {
                var updatedUsers: [String] = []
                
                if let users = document.data()?["users"] as? [String] {
                    // Remove the current user's email from the users array.
                    updatedUsers = users.filter { $0 != email }
                }
                
                // Update the event document with the modified users array.
                self.db.collection("Events").document(eventId).updateData(["users": updatedUsers]) { error in
                    if let error = error {
                        // Handle the error.
                        self.showAlert = true
                        self.errorMessage = LocaleKeys.InvolvedEvent.errorMessage.rawValue
                        self.errorTitle =
                        LocaleKeys.InvolvedEvent.errorTitle.rawValue
                        
                    } else {
                        // Successfully left the event.
                        self.showAlert = true
                        self.errorMessage = LocaleKeys.InvolvedEvent.successMessage.rawValue
                        self.errorTitle =
                        LocaleKeys.InvolvedEvent.successTitle.rawValue
                    }
                }
            } else {
                self.showAlert = true
                self.errorMessage = LocaleKeys.InvolvedEvent.errorMessage.rawValue
                self.errorTitle =
                LocaleKeys.InvolvedEvent.errorTitle.rawValue
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

    
    
   
    
    
}
