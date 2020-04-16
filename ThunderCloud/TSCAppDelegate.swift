//
//  TSCAppDelegate.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 24/08/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import UserNotifications
import ThunderBasics
import ThunderRequest
import ThunderTable
import Baymax
import CoreSpotlight
import BackgroundTasks

@UIApplicationMain
/// A root app delegate which sets up your window and push notifications e.t.c.
open class TSCAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

	/// The main window of the app
	open var window: UIWindow?
    
    /// A window for presenting login UI
    private var loginWindow: UIWindow?
	
	/// Whether to show push notifications when the app is in the foreground
	public var foregroundNotificationOptions: UNNotificationPresentationOptions? = [.alert, .badge, .sound]
    
    static let appStateCategory = "AppState"
	
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        baymax_log("application:DidFinishLaunchingWithOptions with keys: \(launchOptions?.keys.map({ $0.rawValue }).description ?? "[]")", subsystem: Logger.stormSubsystem, category: TSCAppDelegate.appStateCategory, type: .info)
                
		UNUserNotificationCenter.current().delegate = self
				
        setupRootWindow()
		setupSharedUserAgent()
        
        if let remoteNotification = launchOptions?[.remoteNotification] as? [String : Any], let aps = remoteNotification["aps"] as? [AnyHashable : Any] {
            
            baymax_log("App was launched by remote notification:\n\(String(remoteNotification) ?? "Unable to Parse")", subsystem: Logger.stormSubsystem, category: "PushNotifications", type: .info)
            let launchedByContentPush = aps.keys.count == 1 && aps["content-available"] as? Int == 1
            
            ContentController.shared.appLaunched(checkForUpdates: !launchedByContentPush)
            if launchedByContentPush {
                ContentController.shared.downloadBundle(forNotification: remoteNotification) { (_) in
                    
                }
            }
            
        } else {
            
            ContentController.shared.appLaunched()
        }
        
        let accessibilityNotifications: [Notification.Name] = [
            UIAccessibility.darkerSystemColorsStatusDidChangeNotification,
            UIAccessibility.assistiveTouchStatusDidChangeNotification,
            UIAccessibility.boldTextStatusDidChangeNotification,
            UIAccessibility.grayscaleStatusDidChangeNotification,
            UIAccessibility.guidedAccessStatusDidChangeNotification,
            UIAccessibility.invertColorsStatusDidChangeNotification,
            UIAccessibility.reduceMotionStatusDidChangeNotification,
            UIAccessibility.reduceTransparencyStatusDidChangeNotification
        ]
        
        accessibilityNotifications.forEach { (notificationName) in
            NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: .main, using: { [weak self] (_) in
                guard let this = self else { return }
                this.configureAppAppearance()
            })
        }
		
		DeveloperModeController.shared.installDeveloperMode(toWindow: window!, currentTheme: Theme())
		
		// Register errors
        ErrorOverrides.register(
            overrideDescription: "Failed to load page".localised(with: "_STREAMINGPAGE_FAILED_TITLE"),
            recoverySuggestion: "We were unable to find the page for this notification".localised(with: "_STREAMINGPAGE_FAILED_RECOVERYSUGGESTION"),
            forDomain: "ThunderCloud.streamingError",
            code: 1
        )
				
		return true
	}
    
    /// Sets up the app's window with `AppViewController` as it's root view controller
    public func setupRootWindow() {
        
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        
        let appVCClass: AppViewController.Type = StormObjectFactory.shared.class(for: String(describing: AppViewController.self)) as? AppViewController.Type ?? AppViewController.self
        window?.rootViewController = appVCClass.init()
        window?.makeKeyAndVisible()
    }
    
    //MARK: -
    //MARK: - App State
    //MARK: -
    open func applicationWillTerminate(_ application: UIApplication) {
        baymax_log("applicationWillTerminate", subsystem: Logger.stormSubsystem, category: TSCAppDelegate.appStateCategory, type: .info)
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
        baymax_log("applicationDidBecomeActive", subsystem: Logger.stormSubsystem, category: TSCAppDelegate.appStateCategory, type: .info)
    }
    
    open func applicationWillResignActive(_ application: UIApplication) {
        baymax_log("applicationWillResignActive", subsystem: Logger.stormSubsystem, category: TSCAppDelegate.appStateCategory, type: .info)
    }
    
    open func applicationDidEnterBackground(_ application: UIApplication) {
        baymax_log("applicationDidEnterBackground", subsystem: Logger.stormSubsystem, category: TSCAppDelegate.appStateCategory, type: .info)
    }
    
    open func applicationDidFinishLaunching(_ application: UIApplication) {
        baymax_log("applicationDidFinishLaunching", subsystem: Logger.stormSubsystem, category: TSCAppDelegate.appStateCategory, type: .info)
    }
    
    open func applicationWillEnterForeground(_ application: UIApplication) {
        
        baymax_log("applicationWillEnterForeground", subsystem: Logger.stormSubsystem, category: TSCAppDelegate.appStateCategory, type: .info)
        guard ContentController.shared.newContentAvailableOnNextForeground else {
            return
        }
        baymax_log("New content available since last launch, resetting application root window", subsystem: Logger.stormSubsystem, category: "ContentController", type: .info)
        setupRootWindow()
    }
    
    //MARK: -
    //MARK: - Background downloads
    //MARK: -
        
    open func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        ContentController.shared.handleEventsForBackgroundURLSession(session: identifier, completionHandler: completionHandler)
    }
    
    open func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        setupSharedUserAgent()
        ContentController.shared.appLaunched(checkForUpdates: false)
        ContentController.shared.performBackgroundFetch(completionHandler: completionHandler)
    }
	
	//MARK: -
	//MARK: - Push notifications
	//MARK: -
	
	open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		StormNotificationHelper.registerPushToken(with: deviceToken)
	}
    
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        baymax_log("Push notification received, checking if it's a `content-available` push:\n\(String(userInfo) ?? "Unable to Parse")", subsystem: Logger.stormSubsystem, category: "ContentController", type: .debug)
        guard let aps = userInfo["aps"] as? [AnyHashable : Any], let contentAvailable = aps["content-available"] as? Int, contentAvailable == 1 else { return }
        baymax_log("content-available == 1 sending notification off to `ContentController`", subsystem: Logger.stormSubsystem, category: "ContentController", type: .debug)
        // Have to call this here, because for a content-available push `application(_ application:, didFinishLaunchingWithOptions:)` is not called!
        setupSharedUserAgent()
        // Order is important here as sometimes second function can cause it's own app refresh but if this happens the first call will block it!
        ContentController.shared.downloadBundle(forNotification: userInfo, fetchCompletionHandler: completionHandler)
        ContentController.shared.appLaunched(checkForUpdates: false)
    }

	@discardableResult open func handleNotificationResponse(for notification: UNNotification, response: UNNotificationResponse?, fromLaunch: Bool) -> Bool {
		
		// Make sure the action wasn't dismissing the notification
		guard response?.actionIdentifier != UNNotificationDismissActionIdentifier else {
			return false
		}
		
		guard let payload = notification.request.content.userInfo["payload"] as? [AnyHashable : Any], let url = payload["url"] as? String else { return false }
		
		// Call handleNotificationResponse(for:response:fromLaunch) every second if we are presenting
		guard window?.rootViewController?.presentedViewController == nil else {
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
				self.handleNotificationResponse(for: notification, response: response, fromLaunch: fromLaunch)
			}
			return true
		}
		
		return handleContentNotificationFor(cacheURL: url)
	}
	
	open func handleContentNotificationFor(cacheURL: String) -> Bool {
		
		if Bundle.main.infoDictionary?["TSCStreamingBaseURL"] as? String != nil {
			
			// Stream the page
			if let window = window {
                HUDActivityView.addHUDWith(identifier: "ThunderCloud_ContentNotification", to: window)
			}
			
			let streamingController = StreamingPagesController()
			streamingController.fetchStreamingPage(cacheURLString: cacheURL, completion: { (stormViewController, error) in
				
				OperationQueue.main.addOperation {
					
					guard let window = self.window else { return }
					
                    HUDActivityView.removeHUDWith(identifier: "ThunderCloud_ContentNotification", in: window)
					
					if let error = error, let rootViewController = window.rootViewController {
                        UIAlertController.present(error: error, in: rootViewController)
					}
					
					guard let viewController = stormViewController else { return }
					
					viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissStreamedPage))
					let navController = UINavigationController(rootViewController: viewController)
					window.rootViewController?.present(navController, animated: true, completion: nil)
				}
			})
			
			return true
			
		} else {
			
			// Load the page locally
			guard let pageURL = URL(string: cacheURL) else {
				return false
			}
			
			guard let viewController = StormGenerator.viewController(URL: pageURL) else { return false }
			
			viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: viewController, action: #selector(UIViewController.dismissAnimated))
			let navController = UINavigationController(rootViewController: viewController)
			window?.rootViewController?.present(navController, animated: true, completion: nil)
			
			return true
		}
	}
	
	open func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		
		let application = UIApplication.shared
		
		handleNotificationResponse(for: response.notification, response: response, fromLaunch: application.applicationState == .inactive || application.applicationState == .background)
		
		completionHandler()
	}
	
	open func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        guard !notification.request.identifier.starts(with: "contentcontroller_") else {
            completionHandler(.alert)
            return
        }
		
		if let foregroundOptions = foregroundNotificationOptions {
			completionHandler(foregroundOptions)
			return
		}
		
		handleNotificationResponse(for: notification, response: nil, fromLaunch: false)
		completionHandler([])
	}
	
	//MARK: -
	//MARK: - Spotlight indexing
	//MARK: -
    
    open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
		
		guard let searchableItemIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String, searchableItemIdentifier.contains(".json") else {
			return false
		}
		
		guard let url = URL(string: "caches://pages/\(searchableItemIdentifier)") else { return false }
		
		if let quiz = StormGenerator.quiz(for: url), let questionViewController = quiz.questionViewController() {
			
			let navController = UINavigationController(rootViewController: questionViewController)
			window?.rootViewController?.present(navController, animated: true, completion: nil)
			return true
		}
		
		guard let stormViewController = StormGenerator.viewController(URL: url) else { return false }

		guard let listPage = stormViewController as? ListPage else {
			return false
		}
		
		listPage.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: listPage, action: #selector(UIViewController.dismissAnimated))
		let navController = UINavigationController(rootViewController: listPage)
		window?.rootViewController?.present(navController, animated: true, completion: nil)
		
		return true
	}
	
	//MARK: -
	//MARK: - Helpers
	//MARK: -
    
    open func configureAppAppearance() {
        
        // Custom navigation bar background
        let navigationBar = UINavigationBar.appearance()
        navigationBar.tintColor = ThemeManager.shared.theme.navigationBarTintColor
        navigationBar.barTintColor = ThemeManager.shared.theme.navigationBarBackgroundColor
        
        // Text attributes
        var titleBarAttributes = navigationBar.titleTextAttributes ?? [:]
        titleBarAttributes[NSAttributedString.Key.foregroundColor] = ThemeManager.shared.theme.navigationBarTintColor
        navigationBar.titleTextAttributes = titleBarAttributes
        
        if #available(iOS 11.0, *) {
            navigationBar.largeTitleTextAttributes = titleBarAttributes
        }
        
        // Tab bar tint
        UITabBar.appearance().tintColor = ThemeManager.shared.theme.mainColor
        
        // Toast Notifications
        let appearanceToast = ToastView.appearance()
        appearanceToast.backgroundColor = ThemeManager.shared.theme.mainColor
        appearanceToast.textColour = ThemeManager.shared.theme.navigationBarTintColor
    }
	
	public func setupSharedUserAgent() {
		RequestController.sharedUserAgent = Storm.UserAgent
	}
	
	@objc private func dismissStreamedPage() {
		window?.rootViewController?.dismiss(animated: true, completion: nil)
		StreamingPagesController.cleanUp()
	}
	
	/// A function which tells the application whether a particular link is whitelisted by the application
	///
	/// For security concious projects this should be overriden in your AppDelegate subclass to whitelist or
	/// blacklist certain urls from either being presented/shown/pushed in the `push(link:)` method of our UINavigationController extension
	///
	/// - Parameter link: The link to check for whether is whitelisted
	/// - Returns: A boolean as to whether the url is whitelisted by the app
	@objc open func linkIsWhitelisted(_ url: StormLink) -> Bool {
		return true
	}
    
    /// Enables Baymax diagnostics window for the current project, protected by storm login
    /// - Parameter requireStormAuth: Whether to require the user to login to storm to access!
    public func enableBaymax(requireStormAuth: Bool = true) {
        
        guard let window = window else { return }
        
        DiagnosticsManager.shared.register(provider: ThunderCloudService())
        
        guard requireStormAuth else {
            DiagnosticsManager.shared.attach(to: window)
            return
        }
        
        DiagnosticsManager.shared.attach(to: window) { [weak self] (authCallback) in
            
            guard let self = self else { return }
            
            let storyboard = UIStoryboard(name: "Login", bundle: Bundle.init(for: LocalisationController.self))
            let loginViewController = storyboard.instantiateInitialViewController() as! StormLoginViewController
            loginViewController.loginReason = "Log in to access Diagnostics [BETA]"
            
            loginViewController.completion = { [weak self] (success, cancelled, error) in
                guard let self = self else { return }
                self.loginWindow?.isHidden = true
                self.loginWindow = nil
                authCallback(success)
            }
            
            self.loginWindow = UIWindow(frame: UIScreen.main.bounds)
            self.loginWindow?.rootViewController = loginViewController
            self.loginWindow?.windowLevel = .alert + 1
            self.loginWindow?.isHidden = false
        }
    }
}
