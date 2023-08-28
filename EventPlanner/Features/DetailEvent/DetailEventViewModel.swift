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

class DetailEventViewModel : ObservableObject{
    let db = Firestore.firestore()
    @Published var isContainsUser : Bool = false
    @Published var isPublicEvent : Bool = false
    @Published var requestList : [Request] = []
    @Published var requestSended : Bool = false
    @Published var errorMessage : String = ""
    @Published var isLoading: Bool = true
    @Published var event: Event?
    @Published var showAlert : Bool = false
    
    
    init(eventId:String){
        self.getEventDetail(eventId: eventId)
    }
    
    func getEventDetail(eventId:String){
        db.collection("Events").document(eventId).getDocument { snapshot, error in
            if let error = error{
                self.showAlert = true
                self.errorMessage = LocaleKeys.DetailEvent.error.rawValue
            }
            if let snapshot = snapshot{
                do{
                    let event = try snapshot.data(as: Event.self)
                    self.event = event
                    self.isLoading = false
                } catch{
                    self.showAlert = true
                    self.errorMessage = LocaleKeys.DetailEvent.error.rawValue
                }
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
    
    func copyToClipboard(text: String) {
            UIPasteboard.general.string = text
    }
    
    func isUserInEvent(eventId: String){
        let db = Firestore.firestore()
        let docRef = db.collection("Events").document(eventId)
        guard let email = Auth.auth().currentUser?.email else {return}
        
        docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let eventData = document.data(),
                       let users = eventData["users"] as? [String] {
                        if users.contains(email) {
                            DispatchQueue.main.async {
                                self.isContainsUser = true
                                self.isLoading = false
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.isContainsUser = false
                                self.isLoading = false
                            }
                        }
                    } else {
                        print("Error reading event data or 'users' field not found.")
                    }
                } else {
                    print("Document does not exist or error occurred.")
                }
            }
        
    }
    func isRequestSended(eventId:String,receiver: String){
        let db = Firestore.firestore()
        let email = Auth.auth().currentUser?.email
        
        db.collection("Request").whereField("eventId", isEqualTo: eventId).whereField("receiverUser", isEqualTo: receiver).whereField("senderUser", isEqualTo: email!).getDocuments { snapshot, error in
            if let error = error{
                self.errorMessage = error.localizedDescription
            }
            if let snapshot = snapshot {
               let requests = snapshot.documents.compactMap { Document -> Request in
                    do{
                        let request = try Document.data(as: Request.self)
                        print(request)
                        return request
                    } catch {
                        print(error.localizedDescription)
                        self.errorMessage = error.localizedDescription
                        return self.requestList.first!
                    }
                }
                DispatchQueue.main.async {
                    self.requestList = requests
                    if self.requestList.first != nil{
                        if self.requestList.first!.status == .pending {
                            self.requestSended = true
                        }
                    }
                }
            }
        }
    }
    
    func isEventPublic(eventId:String) -> Bool{
        let db = Firestore.firestore()
        db.collection("Events").document(eventId).getDocument { (snapshot, error) in
            do{
                if let error = error{
                    self.errorMessage = error.localizedDescription
                }
                if let snapshot = snapshot{
                    let event = try snapshot.data(as: Event.self)
                    DispatchQueue.main.async {
                        self.isPublicEvent = event.publicEvent
                        self.isLoading = false
                    }
                }
            } catch{
                
            }
            
        }
        return isPublicEvent
    }
    
    
    func sendRequest(receiver:String,eventId:String,eventName:String){
        let db = Firestore.firestore()
        let date = Date()
        let id = UUID()
        guard let email = Auth.auth().currentUser?.email else{return}
        do{
            let request = try db.collection("Request").document(id.uuidString).parent.addDocument(from: Request(id:id.uuidString, receiverUser: receiver, senderUser: email, dateTime: date, eventName: eventName, eventId: eventId,status: .pending))
            let id = request.documentID
            db.collection("Request").document(id).updateData(["id":id])
        } catch{
            
        }
        
    }
    
}
