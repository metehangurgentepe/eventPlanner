//
//  HomeViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 17.07.2023.
//

import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
class HomeViewModel : ObservableObject{
    
    @Published private(set) var events: [EventDatabase] = []
    @Published var selectedTab = CategoryModel(title: LocaleKeys.Category.other, image: IconItemString.Category.other)
    @Published var isSelected : Bool = false
    @Published var selectedCategory : String?
    @Published var text = ""
    @Published var isLoading: Bool = false
    @Published var savedEvents: SavedEvent?
    private var lastDocument: DocumentSnapshot? = nil
    @ObservedObject var locationManager = LocationManager()
    @Published var isUserLoggedIn : Bool = false
    @Published var showAlert : Bool = false
    
    func filterFunc() async throws{
        isLoading = true
        
        let category = selectedCategory ?? ""
        switch (category.isEmpty, text.isEmpty) {
        case (true,true):
            try await getAllPublicEvents()
        case (false,true):
            try await getFilteredPublicEvents(categoryName: selectedCategory ?? "")
        case(false,false):
            try await filterEvents(categoryName:selectedCategory ?? "")
        case(true,false):
            searchEvent()
        }
        isLoading = false
    }
    
    func fetchUser() async throws{
        let user = try await AuthenticationManager.shared.fetchUser()
        isUserLoggedIn = user != nil
    }
    
    func searchEvent() {
        self.events = self.events.filter { event in
            return event.eventName.lowercased().contains(text.lowercased()) || event.description.contains(text)
        }
    }
    
    func saveEvent(eventId:String) async throws {
        switch(savedEvents?.eventsId.contains(eventId)) {
        case(true):
            try await SavedEventManager.shared.unsaveEvent(eventId: eventId)
        case(false):
            try await SavedEventManager.shared.saveEvent(eventId: eventId)
        default:
            print("default")
        }
    }
    
    func getFilteredPublicEvents(categoryName: String) async throws{
        isLoading = true // Set isLoading to true before starting the filtering
        if categoryName == "categoryOther" {
            self.events = try await EventsManager.shared.getPublicEvent(count: 100, lastDocument: nil, location: locationManager.location?.coordinate).events
        } else{
            self.events = try await EventsManager.shared.getPublicEventFilteredByCategory(categoryName: categoryName,count: 100,lastDocument: nil, location: locationManager.location?.coordinate).events
        }
        isLoading = false // Set isLoading back to false when the filtering is completed
    }
    
    func getSavedEvents() async throws {
        self.savedEvents = try await SavedEventManager.shared.getSavedEventId()
    }
    
    func filterEvents(categoryName: String) async throws{
        if selectedCategory == "categoryOther" {
            self.searchEvent()
        } else{
            self.events = try await EventsManager.shared.getPublicEventFilteredByCategory(categoryName: categoryName,count: 100,lastDocument: nil, location: locationManager.location?.coordinate).events.filter { event in
                event.eventName.lowercased().contains(text.lowercased()) || event.description.contains(text)
            }
        }
    }
        
    func getAllPublicEvents() async throws{
        do{
            let(events,_) = try await EventsManager.shared.getPublicEvent(count: 100, lastDocument: lastDocument, location: locationManager.location?.coordinate)
            self.events = events
        } catch{
            print(error.localizedDescription)
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
