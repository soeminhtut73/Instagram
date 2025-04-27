//
//  AppDelegate.swift
//  Instagram
//
//  Created by S M H  on 06/12/2024.
//

import UIKit
import Firebase
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let appearance = UIBarButtonItem.appearance()
        appearance.tintColor = .black
        
        FirebaseApp.configure()
        
//        UNUserNotificationCenter.current().delegate = self
//        
//        UNUserNotificationCenter.current().getNotificationSettings { settings in
//            
//            if settings.authorizationStatus == .authorized {
//                print("Debug: Notification authorized, good to go.")
//            } else {
//                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//                UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
//                    if let error = error {
//                        print("Error requesting notification authorization: \(error)")
//                    }
//                    // Optionally, handle the "granted" status here
//                    print("Debug: Apn register success : \(granted)")
//                }
//            }
//        }
        
        // Register with APNs
//        application.registerForRemoteNotifications()
        
        // Set Firebase Messaging delegate
//        Messaging.messaging().delegate = self
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate {
    
    // Called when registration with APNs succeeds
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // Pass the device token to Firebase Messaging
//        Messaging.messaging().apnsToken = deviceToken
//        
//        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
//        let token = tokenParts.joined()
        
        
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
//        guard let token = fcmToken else { return }
//        
//        let saveToken = UserDefaultManager.shared.deviceToken
//        
//        if saveToken != token {
//            UserDefaultManager.shared.deviceToken = token
//            print("Debug: New APNs device token saved: \(token)")
//        } else {
//            print("Debug: APNs token unchanged, skipping save.")
//        }
    }

    // Called when registration fails
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Debug: Failed to register for remote notifications: \(error)")
    }
}

extension AppDelegate {
    // This method is called when a notification is delivered while the app is in the foreground
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
//        print("Debug: Foreground notification: \(userInfo)")
//        // You can choose how to present the notification (alert, badge, sound)
//        completionHandler([.badge, .sound])
//    }
    
    // This method is called when the user interacts with the notification (taps it)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        print("Debug: Notification tapped: \(userInfo)")
//        // Handle navigation or other actions here
//        completionHandler()
    }
}

