//
//  ResetPasswordViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 20.08.2023.
//

import Foundation
import FirebaseAuth

class ResetPasswordViewModel: ObservableObject{
    @Published var alertMessage = ""
    @Published var showAlert : Bool = false
    @Published var alertTitle = ""
    
    func resetPassword(email:String){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                self.alertTitle = LocaleKeys.ResetPassword.alertTitleError.rawValue
                self.showAlert = true
                self.alertMessage = LocaleKeys.ResetPassword.alertMessageError.rawValue
            } else {
                self.showAlert = true
                self.alertTitle = LocaleKeys.ResetPassword.alertTitleSuccess.rawValue
                self.alertMessage = LocaleKeys.ResetPassword.alertMessageSuccess.rawValue
            }
            self.showAlert = true
        }
    }
}
