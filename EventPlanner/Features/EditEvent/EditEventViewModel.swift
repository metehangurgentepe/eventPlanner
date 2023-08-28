//
//  EditEventViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 25.07.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

protocol EditEventFormProtocol{
    var formIsValid : Bool { get }
}

class EditEventViewModel: ObservableObject{
    @Published var errorMessage = ""
    @Published var event : Event?
    @Published var showAlert : Bool = false
    @Published var isErrorAlertPresented : Bool = false
    @Published var errorAlert = Alert(title: Text(LocaleKeys.EditEvent.photoError.rawValue.locale()))
    @Published var success : Bool = false
    @Published var isLoading : Bool = true
    @Published var name : String = ""
    @Published var desc: String = ""
    @Published var price: String = ""
    @Published var isPublic : Bool = false
    @Published var date : Date = Date()
    @Published var groupChatLink : String = ""
    @Published var location : String = ""
    @Published var selectedOption: String = ""
    @Published var latitude : Double = 0
    @Published var longitude : Double = 0
    @Published var formIsValid : Bool = false

    
    
    let db = Firestore.firestore()
    
    init(eventId:String){
        self.getEvent(eventId: eventId)
    }
    func getEvent(eventId:String){
        db.collection("Events").document(eventId).getDocument { snapshot, error in
            if let error = error{
                self.showAlert = true
                self.errorMessage = "\(error.localizedDescription)"
            }
            if let snapshot = snapshot{
                do{
                    let event = try snapshot.data(as: Event.self)
                    print("buraya giriyor mu acaba kii")
                    self.event = event
                    self.name = event.eventName
                    self.desc = event.description
                    self.price = String(event.price)
                    self.isPublic = event.publicEvent
                    self.groupChatLink = event.groupChatLink
                    self.isLoading = false
                    self.location = event.location
                    self.selectedOption = event.eventType
                    self.latitude = event.latitude
                    self.longitude = event.longitude
                } catch{
                    self.errorMessage = "\(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
    }
    
    func updateEvent(name:String,desc:String,isPublic:Bool,price:Int,date:String,type:String,chatLink:String,location:String,latitude:Double,longitude:Double,image:UIImage?,eventId:String) async{
        switch (chatLink.isEmpty, isLink(chat: chatLink), image) {
        case (false, false, _):
            self.showAlert = true
            self.errorMessage = LocaleKeys.EditEvent.errorMessage.rawValue
        case (_, _, nil):
            let data = ["eventName": name, "description": desc, "publicEvent": isPublic, "price": price, "eventType": type, "groupChatLink": chatLink, "location": location, "latitude": latitude, "longitude": longitude] as [String : Any]
            do {
                try await db.collection("Events").document(eventId).updateData(data)
                self.success = true
                print("ilk if ")
                print(success)
            } catch {
                self.showAlert = true
                self.errorMessage = LocaleKeys.EditEvent.cannotUpdate.rawValue
            }
        case (_, _, _):
            do {
                let imageURL = await saveImage(image: image!)
                
                let data = ["eventName": name, "description": desc, "publicEvent": isPublic, "price": price, "eventType": type, "groupChatLink": chatLink, "location": location, "latitude": latitude, "eventPhoto": imageURL, "longitude": longitude] as [String : Any]
                try await db.collection("Events").document(eventId).updateData(data)
                self.success = true
                print("ikinci if ")
                print(success)
            } catch {
                self.showAlert = true
                self.errorMessage = LocaleKeys.EditEvent.cannotUpdate.rawValue
            }
        }
    }
   
    
    func isLink(chat: String) -> Bool {
        print("here")
        // Metni bağlantıları kontrol etmek için bir regex deseni kullanabilirsiniz.
        let linkPattern = "http(s)?://([-\\w]+\\.)+[\\w-]+(/[\\w- ./?%&=]*)?"
        
        // NSPredicate ile metni kontrol edin
        let linkPredicate = NSPredicate(format: "SELF MATCHES %@", linkPattern)
        print( linkPredicate.evaluate(with: chat))
        // Metin üzerinde kontrol yapın
        return linkPredicate.evaluate(with: chat)
    }

    func saveImage(image:UIImage) async -> String{
        let photoName = UUID().uuidString
        let storage = Storage.storage()
        let storageRef = storage.reference().child("\(photoName).jpeg")
        
        guard let resizedImage = image.jpegData(compressionQuality: 0.25) else{
            return ""
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        var imageUrlString = ""
        
        do{
            let _ = try await storageRef.putDataAsync(resizedImage,metadata: metadata)
            do{
                let imageURL = try await storageRef.downloadURL()
                imageUrlString = "\(imageURL)"
            } catch {
                
            }
        }catch{
            print("error upload photo ")
        }
        return imageUrlString
    }
    
    func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        return dateFormatter.date(from: dateString)
    }
    
}
