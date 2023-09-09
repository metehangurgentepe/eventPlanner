//
//  RegisterViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 27.08.2023.
//

import Foundation
import SwiftUI

@MainActor
final class RegisterViewModel: ObservableObject{
    @ObservedObject var service = AuthManager()
    @Published var email = ""
    @Published var password = ""
    @Published var phoneNumber = ""
    @Published var fullname = ""
    @Published var showAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var isSignIn: Bool = false
    
    func signUp() async throws{
        isLoading = true
        let user = try await service.signUp(fullname: fullname, email: email, password: password, phoneNumber: phoneNumber)
        isLoading = false
        isSignIn = true
    }
   // func 
}
