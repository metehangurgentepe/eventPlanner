//
//  EditProfileViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 23.07.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


class EditProfileViewModel:ObservableObject{
    @Published var userList : User?
    @Published var alertMessage = ""
    @Published var showAlert = false
    @Published var currentUser : User?
    @Published var showPhotoAlert = false
    @Published var alertTitle = ""

    

    
    let db = Firestore.firestore()
    
    func saveChanges(fullname: String, email: String, phoneNumber: String,imageUrl:String) {
        let ref = db.collection("Users").document(email)
        let data = ["fullname":fullname,"email":email.lowercased(),"phoneNumber":phoneNumber,"imageUrl":imageUrl]
        ref.updateData(data){ error in
            if let error = error{
                self.showAlert = true
                self.alertTitle = LocaleKeys.EditProfile.errorTitle.rawValue
                self.alertMessage = LocaleKeys.EditProfile.errorMessage.rawValue
            } else{
                self.showAlert = true
                self.alertTitle = LocaleKeys.EditProfile.successTitle.rawValue
                self.alertMessage = LocaleKeys.EditProfile.successMessage.rawValue
            }
        }
        async{
            await self.fetchUser()
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
    
    
    func resetPassword(email:String){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.showAlert = true
                self.alertTitle = LocaleKeys.EditProfile.errorTitle.rawValue
                self.alertMessage = LocaleKeys.EditProfile.errorMessageResetPassword.rawValue
            } else {
                self.showAlert = true
                self.alertTitle = LocaleKeys.EditProfile.successTitle.rawValue
                self.alertMessage = LocaleKeys.EditProfile.successMessageResetPassword.rawValue
            }
        }
    }
    func saveImage(image:UIImage) async -> String{
        let photoName = UUID().uuidString
        let storage = Storage.storage()
        let storageRef = storage.reference().child("\(photoName).jpeg")
        
        guard let resizedImage = image.jpegData(compressionQuality: 0.4) else{
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
                self.showAlert = true
                self.alertTitle = LocaleKeys.EditProfile.errorTitle.rawValue
                self.alertMessage = LocaleKeys.EditProfile.photoError.rawValue
            }
        }catch{
            self.showAlert = true
            self.alertTitle = LocaleKeys.EditProfile.errorTitle.rawValue
            self.alertMessage = LocaleKeys.EditProfile.photoError.rawValue
        }
        return imageUrlString
    }
}
