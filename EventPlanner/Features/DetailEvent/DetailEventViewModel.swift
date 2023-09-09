//
//  DetailEventViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 19.07.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore
import UIKit
import MapKit
import Firebase

class DetailEventViewModel : ObservableObject{
    let db = Firestore.firestore()
    @Published var isContainsUser : Bool = false
    @Published var isPublicEvent : Bool = false
    @Published var requestList : [Request] = []
    @Published var requestSended : Bool = false
    @Published var errorMessage : String = ""
    @Published var isLoading: Bool = false
    @Published var event: EventDatabase? = nil
    @Published var showAlert : Bool = false
    @Published var publicEvent : Bool = false
    
    func getEventDetail(eventId:String)async throws{
        isLoading = true
        self.event = try await EventsManager.shared.getEvent(id: eventId)
        isLoading = false
    }
    
    func countOfDesc(text:String) -> Int{
        return text.count
    }
    
    
    func copyToClipboard(text: String) {
            UIPasteboard.general.string = text
    }
    
    func isUserInEvent(eventId: String) async throws{
        guard let email = Auth.auth().currentUser?.email else {return}

        let userList = try await EventsManager.shared.getUserInEvent(eventId: eventId)
        self.isContainsUser = userList.contains(email.lowercased())
    }
    
    func isRequestSended(eventId:String,receiver: String) async throws{
        self.requestSended = try await RequestManager.shared.isRequestSended(eventId: eventId, receiver: receiver)
    }
    
    
    func sendRequest(receiver:String,eventId:String,eventName:String) async throws{
       try await RequestManager.shared.sendRequest(reqeiver: receiver, eventId: eventId, eventName: eventName)
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
