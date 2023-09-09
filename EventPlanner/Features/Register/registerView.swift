//
//  registerView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 3.07.2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import CustomAlert
import FirebaseAnalytics

struct registerView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @StateObject var viewModel = RegisterViewModel()
    @State private var isKeyboardVisible: Bool = false
    @Binding var showSignIn: Bool
    
    var body: some View {
        VStack(spacing:30){
            Text(LocaleKeys.Register.title.rawValue.locale())
                .font(.system(size: 40, weight: .bold))
                .padding()
            
            RegisterFormView(fullname: $viewModel.fullname, email: $viewModel.email, phoneNumber: $viewModel.phoneNumber, password: $viewModel.password)
                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                        withAnimation {
                            isKeyboardVisible = true
                        }
                    }
            KeyboardHideView(isKeyboardVisible: $isKeyboardVisible)
            
            Button{
                Task{
                    do {
                        try await viewModel.signUp()
                        showSignIn = false
                        AnalyticsManager.shared.logEvent(name: "LoginView_RegisterButtonClicked",params: ["name":viewModel.fullname])
                    } catch {
                        viewModel.isLoading = false
                        viewModel.showAlert = true
                    }
                    
                }
            } label: {
                ButtonDesignView()
            }
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
            .background(
                NavigationLink(
                    destination: MainTabView(showSignInView: $showSignIn),
                     isActive: $viewModel.isSignIn,
                     label: {
                         EmptyView()
                     })
            )
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
                    message: Text(LocaleKeys.Register.error.rawValue.locale()),
                    dismissButton: .default(Text(LocaleKeys.Login.okButton.rawValue.locale())){
                        viewModel.showAlert = false
                        viewModel.isSignIn = false

                    }
                )
            }
        }
        .analyticsScreen(name: "registerView")
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
        return !viewModel.email.isEmpty && viewModel.email.contains("@") && !viewModel.fullname.isEmpty && viewModel.password.count > 5 && (viewModel.phoneNumber.count == 11)
    }
}

struct registerView_Previews: PreviewProvider {
    static var previews: some View {
        registerView( showSignIn: .constant(false))
    }
}

struct RegisterFormView: View {
    @Binding var fullname: String
    @Binding var email: String
    @Binding var phoneNumber: String
    @Binding var password: String
    
    var body: some View {
        Group{
            BorderTextField(name: $fullname, width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.07, placeHolder: LocaleKeys.Register.name.rawValue, iconName: IconItemString.Register.name.rawValue, keyboardType: .default)
            
            BorderTextField(name: $email, width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.07, placeHolder: LocaleKeys.Register.email.rawValue, iconName: IconItemString.Register.email.rawValue, keyboardType: .emailAddress)
            
            BorderTextField(name: $phoneNumber, width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.07, placeHolder: LocaleKeys.Register.phone.rawValue, iconName: IconItemString.Register.phone.rawValue, keyboardType: .phonePad)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .circular)
                    .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.07)
                    .clipped()
                    .foregroundColor(.white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black,lineWidth: 1)
                    )
                HStack{
                    SecureField(LocaleKeys.Login.password.rawValue.locale(), text: $password)
                        .font(.headline)
                        .foregroundColor(.black)
                    Image(systemName: IconItemString.Register.password.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: UIScreen.main.bounds.height * 0.03)
                }
                .padding(.horizontal)
                .frame(width: UIScreen.main.bounds.width * 0.85)
            }
        }
    }
}

struct ButtonDesignView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.black)
                .frame(width: UIScreen.main.bounds.width * 0.85,height: UIScreen.main.bounds.height * 0.07)
            
            Text(LocaleKeys.Register.button.rawValue.locale())
                .foregroundColor(.white)
        }
    }
}

struct KeyboardHideView: View {
    @Binding var isKeyboardVisible : Bool
    var body: some View {
        HStack{
            Spacer()
            if isKeyboardVisible {
                Button{
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    withAnimation {
                        isKeyboardVisible = false
                    }
                }label: {
                    ZStack{
                        Circle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 50,height: 50)
                        Image("keyboard")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.black)
                            .frame(height: 35)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
