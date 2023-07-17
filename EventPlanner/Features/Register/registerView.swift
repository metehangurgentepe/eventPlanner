//
//  registerView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 3.07.2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

struct registerView: View {
    @ObservedObject private var authViewModel = AuthViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var fullname = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var showAlert = false
    @EnvironmentObject var authVM : AuthViewModel
    var body: some View {
        VStack{
            Text(LocaleKeys.Register.title.rawValue.locale())
                .font(.system(size: 40, weight: .bold))
                .padding()
            TextField(LocaleKeys.Register.name.rawValue.locale(), text: $fullname)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(15)
                    .padding()
            TextField(LocaleKeys.Register.email.rawValue.locale(), text: $email)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(15)
                    .padding()
            TextField(LocaleKeys.Register.phone.rawValue.locale(), text: $phoneNumber)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(15)
                    .padding()
            SecureField(LocaleKeys.Register.password.rawValue.locale(), text: $password)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(15)
                    .padding()
            
            Button{
                Task{
                    print(email+fullname)
                  try await authVM.signUp(fullname: fullname, email: email, password: password,phoneNumber: phoneNumber)
                }
            } label: {
                Text(LocaleKeys.Register.button.rawValue.locale())
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
            //.disabled(formIsValid)
           // .opacity(formIsValid ? 1.0 : 0.5)
            .padding()
            .foregroundColor(.white)
            .background(Color.purple)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .padding()
          /*  .alert(isPresented: Binding(
                get: { authVM.signUpError != nil },
                set: { _ in }
            )) {
                Alert(
                    title: Text("Sign Up Error"),
                    message: Text(authVM.signUpError?.localizedDescription ?? ""),
                    dismissButton: .default(Text("OK"))
                )
            }*/
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
    private var backButton: some View {
           Button(action: {
               // Handle back button action here
               presentationMode.wrappedValue.dismiss()
           }) {
               HStack {
                   Image(systemName: IconItemString.Register.back.rawValue)
                   Text(LocaleKeys.Register.back.rawValue.locale())
               }
           }
       }
}
extension registerView : AuthenticationFormProtocol{
    var formIsValid: Bool{
        return !email.isEmpty && email.contains("@") && !fullname.isEmpty && password.count > 5
    }
}

struct registerView_Previews: PreviewProvider {
    static var previews: some View {
        registerView()
    }
}
