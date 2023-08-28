//
//  LoginViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 27.08.2023.
//

import Foundation
import SwiftUI



@MainActor
final class LoginViewModel: ObservableObject{
    @Published var email = ""
    @Published var password = ""
    @StateObject var service = AuthManager()
    @Published var showAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var isSignIn: Bool = false

    func signIn() async{
        isLoading = true
        do{
            let user = try await service.signInVM(email: email, password: password)
            isLoading = false
            isSignIn = true
            service.currentUser = user
        } catch{
            isLoading = false
            showAlert = true
            isSignIn = false
        }
    }
}
