//
//  ContentView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 3.07.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var isRegistered = false
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var signInSuccess = false
    @EnvironmentObject var authVM : AuthManager
    
    var body: some View {
        Group{
            if authVM.userSession != nil{
                MainTabView()
            } else{
                LoginView()
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
