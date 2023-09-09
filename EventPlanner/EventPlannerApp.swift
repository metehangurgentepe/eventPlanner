//
//  EventPlannerApp.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 3.07.2023.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.Message_ID"
    
    func application(_ application: UIApplication,
                             didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        //Push Notification
        
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
       // Messaging.messaging().apnsToken = deviceToken
        
        Messaging.messaging().isAutoInitEnabled = true


    return true
  }
}

@main
struct EventPlannerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authVM = AuthManager()
    @StateObject var eventVM = EventViewModel()
    @StateObject var locationManager = LocationManager()
    @StateObject var annotationStore = AnnotationStore()

    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        print(url)
        return true
    }
    

   
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
        @EnvironmentObject var authVM : AuthManager
        @EnvironmentObject var eventVM : EventViewModel
        var body: some View {
            NavigationView{
                SplashView()
            }.navigationViewStyle(StackNavigationViewStyle())

        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{
      // Receive displayed notifications for iOS 10 devices.
      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // ...

        // Print full message.
        print(userInfo)

        // Change this to your preferred presentation option
        return [[.alert, .sound]]
      }

      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo

        // ...

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print full message.
        print(userInfo)
      }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      return UIBackgroundFetchResult.newData
    }

}
extension AppDelegate: MessagingDelegate{
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        if let token = fcmToken {
            // FCM token'ını cihazda saklama örneği
            UserDefaults.standard.set(token, forKey: "FCMToken")
            UserDefaults.standard.synchronize()
            
            // Token'ın başarıyla kaydedildiğini doğrulama
            if let savedToken = UserDefaults.standard.string(forKey: "FCMToken") {
                print("Token successfully saved in UserDefaults: \(savedToken)")
            } else {
                print("Token couldn't be saved.")
            }
        } else {
            print("FCM token is nil.")
        }

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: Gerekirse token'ı sunucuya gönder.
        // Not: Bu geri çağrı her uygulama başlatıldığında ve yeni bir token oluşturulduğunda tetiklenir.
    }

}

