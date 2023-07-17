//
//  signUpViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 3.07.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CryptoKit
import FirebaseFirestoreSwift

protocol AuthenticationFormProtocol{
    var formIsValid : Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var signUpError: Error?
    @Published var signInError : Error?
    @Published var isLoggedIn = Bool()
    @Published var userSession : FirebaseAuth.User?
    @Published var currentUser : User?
    let db = Firestore.firestore()
    
    init(){
        self.userSession = Auth.auth().currentUser
        Task{
           await fetchUser()
        }
    }
    func signUp(fullname:String, email: String, password: String,phoneNumber:String) async throws {
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email,phoneNumber: phoneNumber)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await db.collection("Users").document(result.user.uid).setData(encodedUser)
            await fetchUser()
        } catch{
            signUpError = error
            print(signUpError)
        }
    }
    func signInVM(email:String, password : String) async throws{
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch{
            signInError = error
        }
    }
    func signOut(){
        do{
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            print("sign out")
        } catch {
            // Handle the sign-out error appropriately
            print("Failed to sign out with error: \(error.localizedDescription)")
        }
    }
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let documentRef = Firestore.firestore().collection("Users").document(uid)
            let documentSnapshot = try await documentRef.getDocument()
            
            if let documentData = documentSnapshot.data() {
                if let currentUser = try? Firestore.Decoder().decode(User.self, from: documentData) {
                    self.currentUser = currentUser
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

