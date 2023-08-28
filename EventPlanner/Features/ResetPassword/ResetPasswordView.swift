//
//  ResetPasswordView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 20.08.2023.
//

import SwiftUI

struct ResetPasswordView: View {
    @State var email = ""
    @State var showAlert = false
    @StateObject var viewModel = ResetPasswordViewModel()
    var body: some View {
        VStack{
            Spacer()
            BorderTextField(name: $email, width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.07, placeHolder: LocaleKeys.ResetPassword.resetEmail.rawValue, iconName: "person.fill", keyboardType: .emailAddress)
            Spacer()
            Button{
                showAlert = true
                viewModel.resetPassword(email: email)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.black)
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.07)
                    Text(LocaleKeys.ResetPassword.resetPassword.rawValue)
                        .foregroundColor(.white)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke()
            )

        }
        .padding(.vertical)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle.locale()),
                message: Text(viewModel.alertMessage.locale()),
                dismissButton: .default(Text(LocaleKeys.Login.okButton.rawValue.locale()))
            )
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
