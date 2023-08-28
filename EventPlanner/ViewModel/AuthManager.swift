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
class AuthManager: ObservableObject {
    @Published var signUpError: Error?
    @Published var signInError : Error?
    @Published var isLoggedIn = Bool()
    @Published var userSession : FirebaseAuth.User?
    @Published var currentUser : User?
    let db = Firestore.firestore()
    //static let shared = AuthManager() // Singleton instance
    //static let shared = AuthManager()
    
    init(){
        self.userSession = Auth.auth().currentUser
        Task{
           await fetchUser()
        }
    }
    func signUp(fullname:String, email: String, password: String,phoneNumber:String) async throws  -> User{
        do{
                let savedToken = UserDefaults.standard.string(forKey: "FCMToken")
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                try await db.collection("fcmTokens").document(email.lowercased()).setData(["token": savedToken,"email":email.lowercased()])
                self.userSession = result.user
                let user = User(id: result.user.uid, fullname: fullname, email: email.lowercased(),phoneNumber: phoneNumber, imageUrl: "", fcmToken: savedToken ?? "")
                let encodedUser = try Firestore.Encoder().encode(user)
                try await db.collection("Users").document(email.lowercased()).setData(encodedUser)
                await fetchUser()
                currentUser = user
                return user
        } catch{
            throw error
        }
    }
    func signInVM(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            if let savedToken = UserDefaults.standard.string(forKey: "FCMToken"), savedToken != "" {
                try await db.collection("fcmTokens").document(email.lowercased()).setData(["token": savedToken,"email":email.lowercased()])
                try await db.collection("Users").document(email.lowercased()).updateData(["fcmToken" : savedToken])
            }
            print("bsabdfsdafbhasdfnjsadfjnsajdfnajsdfnjsadnjsadfnjsaksafnksaşnfakjans")
            print(result)
            await fetchUser()
            return currentUser!
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


