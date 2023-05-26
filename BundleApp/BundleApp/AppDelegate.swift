//
//  AppDelegate.swift
//  BundleApp
//
//  Created by Ben Shutt on 25/05/2023.
//

import UIKit
import ThunderCloud
import CoreLocation

/// This AppDelegate is based around around FA.
///
/// Bundle URL:
/// https://arc.cubeapis.com/latest/apps/25/bundle
///
/// Opted out of `SceneDelegate` with:
/// https://stackoverflow.com/questions/57467003/opt-out-of-uiscenedelegate-swiftui-on-ios
@main
class AppDelegate: TSCAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let launched = super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        enableBaymax(requireStormAuth: false)

        OperationQueue.main.addOperation {
            UIApplication.shared.registerForRemoteNotifications()
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + .seconds(3)
        ) {
            try? BundleHelper.printBundleDirectory()
        }

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            guard let error else { return }
            print(error)
        }
        return launched
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        super.applicationDidEnterBackground(application)
        ContentController.shared.scheduleBackgroundUpdates(
            minimumFetchIntervalRange: (18 * .hour)..<(24 * .hour)
        )
    }

    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        super.application(
            application,
            didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
        )

        // Only request geotargeted if the user didn't skip that screen, OR if they later
        // responded to another location prompt
        StormNotificationHelper.registerPushToken(
            with: deviceToken,
            geoTargeted: CLLocationManager().authorizationStatus != .notDetermined
        )

        // Sync device token if required
        let token = StormNotificationHelper.string(forPushTokenData: deviceToken)
        print("Device token: \(token)")
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        completionHandler()
    }

    override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        super.application(
            application,
            didReceiveRemoteNotification: userInfo,
            fetchCompletionHandler: completionHandler
        )
        print(userInfo)
    }
}
