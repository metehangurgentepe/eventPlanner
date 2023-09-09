//
//  EditProfileViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 23.07.2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseStorage
import UIKit
import SwiftUI


class EditProfileViewModel:ObservableObject{
    @Published var userList : UserModel?
    @Published var alertMessage = ""
    @Published var showAlert = false
    @Published var currentUser : UserModel?
    @Published var showPhotoAlert = false
    @Published var alertTitle = ""
    @Published var user : UserModel? = nil
    
    let db = Firestore.firestore()
    
    
    func updateUser(fullname: String, email: String, phoneNumber: String,imageUrl:String) async throws {
        let ref = try await db.collection("Users").document(email.lowercased()).getDocument(as: UserModel.self)
        try await AuthenticationManager.shared.updateUser(id: ref.id, email: ref.email, fullname: fullname, phoneNumber: phoneNumber, photoUrl: imageUrl)
    }
    
    func fetchUser() async throws {
        self.user = try await AuthenticationManager.shared.fetchUser()
    }
    
    func saveImage(image:UIImage) async throws -> String {
        try await AuthenticationManager.shared.saveImage(image: image)
    }
    func resetPassword(email:String) throws{
        AuthenticationManager.shared.resetPassword(email: email)
    }
}
