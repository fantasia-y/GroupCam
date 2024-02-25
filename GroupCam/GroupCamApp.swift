//
//  GroupCamApp.swift
//  GroupCam
//
//  Created by Gordon on 23.02.24.
//

import SwiftUI
import PushNotifications
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        PushNotifications.shared.start(instanceId: Secrets.pusherInstance)
        PushNotifications.shared.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotifications.shared.registerDeviceToken(deviceToken)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushNotifications.shared.handleNotification(userInfo: userInfo)

        completionHandler(.noData)
    }
}

@main
struct GroupCamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var colorSchemeSetting = ColorSchemeSetting()
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            AuthenticatedView() {
                GetStartedView()
            } content: {
                ContentView()
            }
            .preferredColorScheme(colorSchemeSetting.colorScheme)
            .environmentObject(colorSchemeSetting)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                if let userDefaults = UserDefaults(suiteName: "group.dev.gordonkirsch.OneCam") {
                    userDefaults.set(0, forKey: "badgeCount")
                }
                UNUserNotificationCenter.current().setBadgeCount(0)
            }
            PersistenceController.shared.save()
        }
    }
}

