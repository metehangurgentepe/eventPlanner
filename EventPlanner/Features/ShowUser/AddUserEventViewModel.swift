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
    @Published var userList : [UserModel] = []
    let db = Firestore.firestore()
    @Published var errorMessage = ""
    @Published var errorTitle = ""
    @Published var userEmails : [String] = []
    @Published var showAlert : Bool = false
    @Published var searchList : [UserModel] = []
    
    
    @MainActor
    func getUsers(eventId:String) async throws{
        self.convertUser(userEmailArray: try await EventsManager.shared.getUserInEvent(eventId: eventId))
    }
    
    func convertUser(userEmailArray: [String]){
        userList.removeAll()
        for i in 0..<userEmailArray.count{
            db.collection("Users").document(userEmailArray[i]).getDocument { snapshot, error in
                if let error = error{
                    self.errorMessage = "\(error.localizedDescription)"
                }
                if let snapshot = snapshot{
                    do{
                        let user = try snapshot.data(as:UserModel.self)
                        self.userList.append(user)
                    } catch{
                        self.errorMessage = "\(error.localizedDescription)"
                    }
                }
            }
        }
    }
     
    
    func removeUser(email: String, eventId: String) async throws {
        do{
            try await EventsManager.shared.removeUserInEvent(email: email, eventId: eventId)
        } catch{
            showAlert = true
            errorMessage = error.localizedDescription
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
