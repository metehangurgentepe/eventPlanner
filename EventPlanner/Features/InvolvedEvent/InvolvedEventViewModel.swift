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
    @Published var eventList : [EventDatabase] = []
    @Published var isLoading : Bool = false
    @Published var errorTitle = ""
    
    func userInEvent() async throws{
        isLoading = true
        self.eventList = try await EventsManager.shared.getInvolvedEvents()
        isLoading = false
    }
    
    func leaveEvent(eventId: String) async throws {
       try await EventsManager.shared.leaveEvent(eventId: eventId)
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
