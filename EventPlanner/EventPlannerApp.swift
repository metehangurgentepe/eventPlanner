//
//  EventPlannerApp.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 3.07.2023.
//

import SwiftUI
import FirebaseCore
import MapKit

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct EventPlannerApp: App {
    @StateObject var authVM = AuthViewModel()
    @StateObject var eventVM = EventViewModel()
    @StateObject var locationManager = LocationManager()
    @StateObject var annotationStore = AnnotationStore()
    
    

   

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(authVM)
                .environmentObject(eventVM)
                .environmentObject(locationManager)
                .environmentObject(annotationStore)
        }
    }
    struct AppView: View {
        @EnvironmentObject var authVM: AuthViewModel
        @EnvironmentObject var eventVM : EventViewModel
        var body: some View {
            if authVM.userSession != nil {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

