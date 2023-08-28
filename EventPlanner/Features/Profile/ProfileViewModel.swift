//
//  ProfileViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 23.07.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject{
    @Published var currentUser : User?
    @StateObject var service = AuthManager()
    @Published var isSignOut: Bool = false
    
    init(){
        Task{
           await self.fetchUser()
            print("user fetch")
        }
    }
    func signOut(){
        service.signOut()
    }
    func fetchUser() async {
        guard let email = Auth.auth().currentUser?.email else { return }
        do {
            let documentRef = Firestore.firestore().collection("Users").document(email.lowercased())
            let documentSnapshot = try await documentRef.getDocument()
            print("fonksiyon içinde")
            
            if let documentData = documentSnapshot.data() {
                if let currentUser = try? Firestore.Decoder().decode(User.self, from: documentData) {
                    DispatchQueue.main.async{
                        self.currentUser = currentUser
                        print(currentUser.email)
                    }
                } else {
                    print("Error decoding user data")
                }
            } else {
                print("User document does not exist")
            }
        } catch {
            print("Error fetching user: \(error)")
        }
    }
}
