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
import FirebaseMessaging

protocol AuthenticationFormProtocol{
    var formIsValid : Bool { get }
}

@MainActor
final class AuthManager: ObservableObject {
    @Published var signUpError: Error?
    @Published var signInError : Error?
    @Published var isLoggedIn = Bool()
    @Published var userSession : FirebaseAuth.User?
    @Published var currentUser : UserModel?
    let db = Firestore.firestore()
    static let shared = AuthManager() // Singleton instance
    //static let shared = AuthManager()
    
    init(){
        self.userSession = Auth.auth().currentUser
        Task{
           await fetchUser()
        }
    }
    
    private let usersCollection = Firestore.firestore().collection("Users")
    
    
    func getUser() async throws -> UserModel {
        let email = Auth.auth().currentUser?.email
        let documentRef = Firestore.firestore().collection("Users").document(email!)
        let documentSnapshot = try await documentRef.getDocument()
        if let documentData = documentSnapshot.data() {
            if let currentUser = try? Firestore.Decoder().decode(UserModel.self, from: documentData) {
                    self.currentUser = currentUser
            } else {
                print("Error decoding user data")
            }
        }
        return self.currentUser!
    }
    func getUserByEmail(email:String) async throws -> UserModel {
        let documentRef = Firestore.firestore().collection("Users").document(email)
        let documentSnapshot = try await documentRef.getDocument()
        if let documentData = documentSnapshot.data() {
            if let currentUser = try? Firestore.Decoder().decode(UserModel.self, from: documentData) {
                    self.currentUser = currentUser
            } else {
                print("Error decoding user data")
            }
        }
        return self.currentUser!
    }

    func signUp(fullname:String, email: String, password: String,phoneNumber:String) async throws  -> UserModel{
        do{
                let savedToken = UserDefaults.standard.string(forKey: "FCMToken")
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                try await db.collection("fcmTokens").document(email.lowercased()).setData(["token": savedToken,"email":email.lowercased()])
                self.userSession = result.user
                let user = UserModel(id: result.user.uid, fullname: fullname, email: email.lowercased(),phoneNumber: phoneNumber, imageUrl: "", fcmToken: savedToken ?? "")
                let encodedUser = try Firestore.Encoder().encode(user)
                try await db.collection("SavedEvents").document(email.lowercased()).setData(["email" : email.lowercased(),"eventsId":[]])
                try await db.collection("Users").document(email.lowercased()).setData(encodedUser)
                await fetchUser()
                currentUser = user
                return user
        } catch{
            throw error
        }
    }
    func signInVM(email: String, password: String) async throws -> UserModel {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            if let savedToken = UserDefaults.standard.string(forKey: "FCMToken"), savedToken != "" {
                try await db.collection("fcmTokens").document(email.lowercased()).setData(["token": savedToken,"email":email.lowercased()])
                try await db.collection("Users").document(email.lowercased()).updateData(["fcmToken" : savedToken])
            }
           print(try await getUserByEmail(email: (userSession!.email!)))
            print("EMAİİİİİLLLLLLLLLLLLLLLLL")
            print(Auth.auth().currentUser?.email)
            return try await getUserByEmail(email: (userSession!.email!))
        } catch {
            throw error // Throw the caught error instead of assigning it to signInError
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
        guard let email = Auth.auth().currentUser?.email else { return }
        do {
            let documentRef = Firestore.firestore().collection("Users").document(email)
            let documentSnapshot = try await documentRef.getDocument()
            
            if let documentData = documentSnapshot.data() {
                if let currentUser = try? Firestore.Decoder().decode(UserModel.self, from: documentData) {
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


