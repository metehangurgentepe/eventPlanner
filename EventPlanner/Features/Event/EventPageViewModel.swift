//
//  EventViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 19.07.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseCore
import FirebaseFirestore


class EventPageViewModel: ObservableObject{
    @Published private (set) var requestList : [Request] = []
    @Published private (set) var upcomingEventList : [EventDatabase] = []
    @Published var beforeList : [Event] = []
    @Published var request : [Request] = []
    @Published private (set) var upcomingPublicEvent : [EventDatabase] = []
    @Published private (set) var eventList : EventDatabase?
    @Published private (set) var isUserLoggedIn: Bool = false
    @Published var showAlert : Bool = false
    
    func fetchUser() async throws{
        let user = try await AuthenticationManager.shared.fetchUser()
        isUserLoggedIn = user != nil
    }
    
    func getRequest() async throws{
        self.requestList = try await RequestManager.shared.getAllRequest()        
    }
    
    func getEventById(request:Request) async throws -> EventDatabase{
        return try await EventsManager.shared.getEvent(id: request.eventId)
    }
    
    func acceptRequest() async throws{
        if let request = requestList.first{
            try await RequestManager.shared.acceptRequest(request: request)
        }
    }
    
    func rejectRequest() async throws{
        if let request = requestList.first{
            try await RequestManager.shared.rejectRequest(request: request)
        }
    }
    
    func getUpcomingList() async throws{
        let upcomingEventList = try await EventsManager.shared.getUpcomingList()
        DispatchQueue.main.async {
            self.upcomingEventList = upcomingEventList
        }
    }
    
    func getPublicUpcomingList() async throws {
        let upcomingPublicEvent = try await EventsManager.shared.getPublicUpcomingList()
        DispatchQueue.main.async{
            self.upcomingPublicEvent = upcomingPublicEvent
        }
       // self.upcomingPublicEvent = try await EventsManager.shared.getPublicUpcomingList()
    }
    
    func convertEvent(request:Request) async throws{
        self.eventList = try await RequestManager.shared.convertEvent(request: request)
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
