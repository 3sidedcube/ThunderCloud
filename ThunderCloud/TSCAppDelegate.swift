//
//  TSCAppDelegate.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 24/08/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import UserNotifications
import ThunderRequest

@UIApplicationMain
/// A root app delegate which sets up your window and push notifications e.t.c.
open class TSCAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

	/// The main window of the app
	public var window: UIWindow?
	
	/// Whether to show push notifications when the app is in the foreground
	public var foregroundNotificationOptions: UNNotificationPresentationOptions? = [.alert, .badge, .sound]
	
	open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		
		UNUserNotificationCenter.current().delegate = self
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.backgroundColor = .white
		
		window?.rootViewController = TSCAppViewController()
		window?.makeKeyAndVisible()
		
		setupSharedUserAgent()
		
		DeveloperModeController.shared.installDeveloperMode(toWindow: window!, currentTheme: Theme())
		
		// Register errors
		TSCErrorRecoveryAttempter.registerOverrideDescription(
			"Failed to load page".localised(with: "_STREAMINGPAGE_FAILED_TITLE"),
			recoverySuggestion: "We were unable to find the page for this notification".localised(with: "_STREAMINGPAGE_FAILED_RECOVERYSUGGESTION"),
			forDomain: "ThunderCloud.streamingError",
			code: 1)
				
		return true
	}
	
	//MARK: -
	//MARK: - Push notifications
	//MARK: -
	
	open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		StormNotificationHelper.registerPushToken(with: deviceToken)
	}

	open func handleNotificationResponse(for notification: UNNotification, response: UNNotificationResponse?, fromLaunch: Bool) -> Bool {
		
		// Make sure the action wasn't dismissing the notification
		guard response?.actionIdentifier != UNNotificationDismissActionIdentifier else {
			return false
		}
		
		guard let payload = notification.request.content.userInfo["payload"] as? [AnyHashable : Any] else { return false }
		guard let url = payload["url"] as? String else { return false }
		
		// Call handleNotificationResponse(for:response:fromLaunch) every second if we are presenting
		if window?.rootViewController?.presentedViewController != nil {
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
				_ = self.handleNotificationResponse(for: notification, response: response, fromLaunch: fromLaunch)
			}
			
		} else {
			
			return handleContentNotificationFor(cacheURL: url)
		}
		
		return true
	}
	
	open func handleContentNotificationFor(cacheURL: String) -> Bool {
		
		if Bundle.main.infoDictionary?["TSCStreamingBaseURL"] as? String != nil {
			
			// Stream the page
			if let _window = window {
				MDCHUDActivityView.start(in: _window)
			}
			
			let streamingController = StreamingPagesController()
			streamingController.fetchStreamingPage(cacheURLString: cacheURL, completion: { (stormViewController, error) in
				
				OperationQueue.main.addOperation {
					
					guard let _window = self.window else { return }
					
					MDCHUDActivityView.finish(in: _window)
					
					if let _error = error {
						UIAlertController.presentError(_error, in: _window.rootViewController!)
					}
					
					guard let viewController = stormViewController else { return }
					
					viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissStreamedPage))
					let navController = UINavigationController(rootViewController: viewController)
					_window.rootViewController?.present(navController, animated: true, completion: nil)
				}
			})
			
			return true
			
		} else {
			
			// Load the page locally
			guard let pageURL = URL(string: cacheURL) else {
				return false
			}
			
			guard let viewController = TSCStormViewController.viewController(with: pageURL) as? UIViewController else { return false }
			
			viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: viewController, action: #selector(UIViewController.dismissAnimated))
			let navController = UINavigationController(rootViewController: viewController)
			window?.rootViewController?.present(navController, animated: true, completion: nil)
			
			return true
		}
	}
	
	public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		
		let application = UIApplication.shared
		_ = handleNotificationResponse(for: response.notification, response: response, fromLaunch: application.applicationState == .inactive || application.applicationState == .background)
		
		completionHandler()
	}
	
	open func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		
		if let foregroundOptions = foregroundNotificationOptions {
			completionHandler(foregroundOptions)
			return
		}
		
	    _ = handleNotificationResponse(for: notification, response: nil, fromLaunch: false)
		completionHandler([])
	}
	
	//MARK: -
	//MARK: - Spotlight indexing
	//MARK: -
	
	open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
		
		guard let searchableItemIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String, searchableItemIdentifier.contains(".json") else {
			return false
		}
		
		guard let url = URL(string: "caches://pages/\(searchableItemIdentifier)") else { return false }
		
		guard let stormViewController = TSCStormViewController.viewController(with: url) else { return false }

		if let listPage = stormViewController as? ListPage {
			
			listPage.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: listPage, action: #selector(UIViewController.dismissAnimated))
			let navController = UINavigationController(rootViewController: listPage)
			window?.rootViewController?.present(navController, animated: true, completion: nil)
			
			return true
			
		} else if let quizPage = stormViewController as? TSCQuizPage {
			
			let navController = UINavigationController(rootViewController: quizPage)
			window?.rootViewController?.present(navController, animated: true, completion: nil)
			
			return true
		}
		
		return false
	}
	
	//MARK: -
	//MARK: - Helpers
	//MARK: -
	
	public func setupSharedUserAgent() {
		
		TSCRequestController.setUserAgent(TSCStormConstants.userAgent())
	}
	
	@objc private func dismissStreamedPage() {
		window?.rootViewController?.dismiss(animated: true, completion: nil)
		StreamingPagesController.cleanUp()
	}
}
