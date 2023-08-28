//
//  AddUserEventViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 25.07.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AddUserEventViewModel: ObservableObject{
    @Published var userList : [User] = []
    let db = Firestore.firestore()
    @Published var errorMessage = ""
    @Published var errorTitle = ""
    @Published var userEmails : [String] = []
    @Published var showAlert : Bool = false
    @Published var searchList : [User] = []
    
    
    @MainActor
    func getUsers(eventId:String){
        print("here")
        db.collection("Events").document(eventId).getDocument { snapshot, error in
            if let error = error{
                self.errorMessage = "\(error.localizedDescription)"
            }
            if let snapshot = snapshot{
                do{
                    print("buras")
                    let user = try snapshot.data(as: Event.self)
                    self.convertUser(userEmailArray: user.users)
                    
                    print(user.users)
                } catch{
                    self.errorMessage = "\(error.localizedDescription)"
                }
            }
        }
        //self.convertUser(userEmailArray: userEmails)
    }
    
    func convertUser(userEmailArray: [String]){
        userList.removeAll()
        for i in 0..<userEmailArray.count{
            print("here2")
            db.collection("Users").document(userEmailArray[i]).getDocument { snapshot, error in
                if let error = error{
                    self.errorMessage = "\(error.localizedDescription)"
                }
                if let snapshot = snapshot{
                    do{
                        let user = try snapshot.data(as:User.self)
                        self.userList.append(user)
                    } catch{
                        self.errorMessage = "\(error.localizedDescription)"
                    }
                }
            }
            
        }
    }
    
    
    func removeUser(email: String, eventId: String) {
        let currentUser = Auth.auth().currentUser?.email
        db.collection("Events").document(eventId).getDocument { snapshot, error in
            if let snapshot = snapshot {
                do {
                    let event = try snapshot.data(as: Event.self)
                    let leadUser = event.eventLeadUser // Use optional chaining and nil coalescing to safely access the lead user's email
                    
                    if email.lowercased() == leadUser.lowercased() {
                        self.showAlert = true
                        self.errorMessage = LocaleKeys.AddUser.errorCreated.rawValue
                    } else if currentUser?.lowercased() != leadUser.lowercased(){
                        self.showAlert = true
                        self.errorMessage = LocaleKeys.AddUser.errorLeadUser.rawValue
                    } else {
                        // Uncomment the updateData code if you want to remove the user from the "users" array in the Firestore document
                        self.db.collection("Events").document(eventId).updateData([
                            "users": FieldValue.arrayRemove([email.lowercased()])
                        ])
                    }
                } catch {
                    print("Error parsing event data:", error)
                }
            }
        }
    }
    
    func searchUser(query: String){
        searchList.removeAll()
        if query != ""{
            for i in 0..<userList.count{
                if userList[i].email.lowercased().contains(query.lowercased()) || userList[i].fullname.lowercased().contains(query.lowercased()){
                    searchList.append(userList[i])
                }
            }
        }
    }
}
