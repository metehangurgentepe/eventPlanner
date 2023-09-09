//
//  LoginView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 7.07.2023.
//

import SwiftUI
import CustomAlert
import FirebaseAnalytics

struct LoginView: View {
    @State private var isRegistered = false
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var signInSuccess = false
    @StateObject var authVM = AuthManager()
    @StateObject var viewModel = LoginViewModel()
    @State private var navigateToMustLogin = false
    @Binding var showSignInView: Bool
    @Environment(\.presentationMode) var presentationMode
    

    var body: some View {
        VStack(spacing:30) {
            LogoView()
            
            BorderTextField(name: $viewModel.email, width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.07, placeHolder: LocaleKeys.Login.email.rawValue, iconName: IconItemString.Login.login.rawValue, keyboardType: .emailAddress)
            
            PasswordTextField(viewModel: LoginViewModel())
            
            
            
            Button {
                Task {
                    do{
                        try await viewModel.signIn()
                        showSignInView = false
                        self.presentationMode.wrappedValue.dismiss();                        AnalyticsManager.shared.logEvent(name: "LoginView_LoginButtonClicked")
                    } catch{
                        viewModel.isLoading = false
                        viewModel.showAlert = true
                    }
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.black)
                        .frame(width: UIScreen.main.bounds.width * 0.85,height: UIScreen.main.bounds.height * 0.07)
                    
                    Text(LocaleKeys.Login.button.rawValue.locale())
                        .foregroundColor(.white)
                }
            }
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
            .customAlert(isPresented: $viewModel.isLoading) {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.blue)
                    Text(LocaleKeys.EditEvent.saving.rawValue.locale())
                        .font(.headline)
                }
            } actions: {}
                .alert(isPresented:$viewModel.showAlert) {
                    Alert(
                        title: Text(LocaleKeys.Login.error.rawValue.locale()),
                        message: Text(LocaleKeys.Login.errorMessage.rawValue.locale()),
                        dismissButton: .default(Text(LocaleKeys.Login.okButton.rawValue.locale())){
                            viewModel.showAlert = false
                            viewModel.isSignIn = false
                        }
                    )
                }
            
            GoToRegisterButton(showSignIn: $showSignInView)
            ResetButton()
        }.onOpenURL { url in
            if url.absoluteString.contains("event_id") {
                Task{
                    navigateToMustLogin = true
                }
            }
        }.background(
            NavigationLink(
                destination: MustLoginView(),
                isActive: $navigateToMustLogin,
                label: {EmptyView()})
        )
        
        .analyticsScreen(name: "loginView")
        .navigationBarBackButtonHidden()
        .padding()
    
        
    }
}
extension LoginView : AuthenticationFormProtocol{
    var formIsValid: Bool{
        return !viewModel.email.isEmpty && viewModel.email.contains("@") && viewModel.password.count > 5
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showSignInView: .constant(false))
    }
}

struct GoToRegisterButton: View {
    @Binding var showSignIn: Bool
    var body: some View {
        HStack{
            NavigationLink(destination: registerView(showSignIn: $showSignIn)) {
                Text(LocaleKeys.Login.next.rawValue.locale())
                    .foregroundColor(Color.gray)
                    .fixedSize()
            }
            
            Image(systemName: IconItemString.Login.next.rawValue)
                .imageScale(.small)
                .foregroundColor(.black)
        }
    }
}

struct ResetButton: View {
    var body: some View {
        HStack{
            NavigationLink(destination: ResetPasswordView()) {
                Text(LocaleKeys.Login.reset.rawValue.locale())
                    .foregroundColor(Color.gray)
                    .fixedSize()
            }
        }
    }
}

struct PasswordTextField: View {
    @State var viewModel: LoginViewModel
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .circular)
                .frame(width:UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.07)
                .clipped()
                .foregroundColor(.white.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black,lineWidth: 1)
                )
            
            HStack{
                SecureField(LocaleKeys.Login.password.rawValue.locale(), text: $viewModel.password)
                    .font(.headline)
                    .foregroundColor(.black)
                Image(systemName: IconItemString.Login.password.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: UIScreen.main.bounds.height * 0.03)
            }
            .padding(.horizontal)
            .frame(width: UIScreen.main.bounds.width * 0.85)
        }
    }
}

struct LogoView: View {
    var body: some View {
        Image("Logo")
            .resizable()
            .scaledToFit()
            .aspectRatio(contentMode: .fit)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.3)
    }
}
