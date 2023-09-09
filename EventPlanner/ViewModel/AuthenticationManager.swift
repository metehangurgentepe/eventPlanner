//
//  AuthenticationManager.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 3.09.2023.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseStorage

final class AuthenticationManager{
    
    static let shared = AuthenticationManager()
    private init(){}
    
    private let usersCollection = Firestore.firestore().collection("Users")
    
    func getAuthenticatedUser() throws -> User{
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return user
    }
    
    
    func createUser(email: String, password: String, fullname: String, phoneNumber: String) async throws -> UserModel{
        let savedToken = UserDefaults.standard.string(forKey: "FCMToken")
        let user = try await Auth.auth().createUser(withEmail: email, password: password)
        let result = UserModel(id: user.user.uid, fullname: fullname, email: email, phoneNumber: phoneNumber, imageUrl: "", fcmToken: savedToken ?? "")
        let encodedUser = try Firestore.Encoder().encode(result)
        try await usersCollection.document(email).setData(encodedUser)
        return result
    }
    
    func signIn(email:String,password: String) async throws -> UserModel {
        try await Auth.auth().signIn(withEmail: email, password: password)
        return try await usersCollection.document(email).getDocument(as: UserModel.self)
    }
    
    func signOut() throws {
       try Auth.auth().signOut()
    }
    
    func fetchUser() async throws -> UserModel?{
        if let user = Auth.auth().currentUser {
            return try await usersCollection.document(user.email!).getDocument(as: UserModel.self)
        }
        return nil
    }
    func updateUser(id:String,email:String,fullname:String, phoneNumber: String,photoUrl: String) async throws {
        let savedToken = UserDefaults.standard.string(forKey: "FCMToken")
        let user = UserModel(id: id, fullname: fullname, email: email, phoneNumber: phoneNumber, imageUrl: photoUrl, fcmToken: savedToken ?? "")
        let encodedUser = try Firestore.Encoder().encode(user)
        try await usersCollection.document(email).updateData(encodedUser)
    }
    
    func resetPassword(email:String) {
        Auth.auth().sendPasswordReset(withEmail: email)
    }
    func saveImage(image:UIImage) async throws -> String{
        let email = Auth.auth().currentUser?.email
        _ = UUID().uuidString
        let storage = Storage.storage()
        let storageRef = storage.reference().child("\(email).jpeg")
        
        guard let resizedImage = image.jpegData(compressionQuality: 0.4) else{
            return ""
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        var imageUrlString = ""
        let _ = try await storageRef.putDataAsync(resizedImage,metadata: metadata)
        do{
            let imageURL = try await storageRef.downloadURL()
            imageUrlString = "\(imageURL)"
                
        } catch {
            
        }
        
        return imageUrlString
    }

}
