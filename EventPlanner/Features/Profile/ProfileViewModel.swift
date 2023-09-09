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
    @Published var currentUser : UserModel?
    @StateObject var service = AuthManager()
    @Published var isSignOut: Bool = false
    @Published var isLoading : Bool = false
    
    init(){
        Task{
           await self.fetchUser()
            print("user fetch")
        }
    }
    func signOut(){
        do {
            try AuthenticationManager.shared.signOut()
        } catch {
            
        }
    }
    
    func deleteAccount() {
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("Users").document(email.lowercased()).delete()
        Auth.auth().currentUser?.delete()
    }
    
    func fetchUser() async {
        isLoading = true
        do {
            self.currentUser = try await AuthenticationManager.shared.fetchUser()
            isLoading = false
        } catch{
            self.currentUser = nil
            isLoading = false
        }
    }
}
