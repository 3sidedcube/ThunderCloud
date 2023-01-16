//
//  DeveloperModeController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/10/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import Foundation
import ThunderRequest
import ThunderTable

///
/// The developer controller is responsible for handling mode switching of storm apps.
///
/// Storm apps have two modes;
///
/// - Dev: Displays content from the CMS that has been published to test
/// - Live: Displays content from the CMS published to live
///
/// In Developer mode the app will switch to a green colour scheme to remind the user that they are in dev mode
public class DeveloperModeController: NSObject {
    
    ///  The shared instance of the developer controller responsible for monitoring switching to dev/live mode
    public static let shared = DeveloperModeController()
    
    /// The base URL of the CMS that will be used to retrieve bundles
    public var baseURL: URL?
    
    /// The original theme before the app was switched into dev mode
    public var originalTheme: Theme?
    
    /// The window which the switch to dev mode is happening in
    private var appWindow: UIWindow?
    
    /// A window to show the UI of dev mode changing in
    private var uiWindow: UIWindow?
    
    /// Whether or not the app is currently displaying developer mode content
    /// 
    /// This DOES NOT reflect the setting in the settings app for whether the app
    /// should be in developer mode, rather whether the developer mode content
    /// is actually being displayed, to check the setting use `devModeEnabled`
    public class var appIsInDevMode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "TSCDevModeEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "TSCDevModeEnabled")
        }
    }
    
    /// Whether or not the app is currently displaying developer mode content
    ///
    /// This DOES NOT reflect whether the app is showing developer content
    /// rather whether the developer mode switch is on or off in the settings
    /// app
    public class var devModeOn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "developer_mode_enabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "developer_mode_enabled")
        }
    }
    
    /// An observer for when the app enters the foreground
    private var backgroundObserver: NSObjectProtocol?
    
    override private init() {
        
        if let apiURL = Storm.API.BaseURL, let appId = Storm.API.AppID {
            baseURL = URL(string: "\(apiURL)/latest/apps/\(appId)/update")
        }
        
        super.init()
        
        if DeveloperModeController.appIsInDevMode {
            configureDevModeAppearance()
        }
        
        if DeveloperModeController.devModeOn {
            self.loginToDeveloperMode()
        }
        
        backgroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            
            // Make sure we have an app ID and app.json before entering/leaving developer mode, now that we have apps
            // which download their bundle rather than being bundled with it.
            guard ContentController.shared.fileExistsInBundle(file: "app.json"), UserDefaults.standard.string(forKey: "TSCAppId") ?? Storm.API.AppID != nil else {
                return
            }
            
            if DeveloperModeController.devModeOn {
                self?.loginToDeveloperMode()
            } else if !DeveloperModeController.devModeOn && DeveloperModeController.appIsInDevMode {
                self?.switchToLive()
            }
            
            if !ContentController.shared.isCheckingForUpdates {
                ContentController.shared.checkForUpdates()
            }
        })
    }
    
    /// Begins the process of switching the app back into dev mode
    public func switchToLive() {
        
        print("<Developer Controls> Switching to live mode")
        
        DeveloperModeController.appIsInDevMode = false
        
        print("<Developer Controls> Clearing cache")
        
        ContentController.shared.cleanoutCache()
        StormLanguageController.shared.reloadLanguagePack()
        ContentController.shared.updateSettingsBundle()
        ContentController.shared.checkForUpdates()
    
        finishSwitching()
    }
    
    /// Switched the app into dev mode
    internal func switchToDev(progressHandler: ContentUpdateProgressHandler?) {
        
        guard let apiBaseURL = Storm.API.BaseURL, let apiVersion = Storm.API.Version, let appId = UserDefaults.standard.string(forKey: "TSCAppId") ?? Storm.API.AppID else {
            
            print("<Developer Controls> [Fatal Error] Please make sure your app is set up with all info.plist values correctly")
            return
        }
        
        print("<Developer Controls> Switching to dev mode")
        print("<Developer Controls> Clearing cache")
        
        progressHandler?(.preparing, 0, 0, nil)
        ContentController.shared.cleanoutCache()
        progressHandler?(.downloading, 0, 0, nil)
        
        guard let url = URL(string: "\(apiBaseURL)/\(apiVersion)/apps/\(appId)/bundle?density=x2&environment=test") else {
            progressHandler?(.downloading, 0, 0, ContentControllerError.invalidUrlProvided)
            return
        }
        
        if let _deltaDirectory = ContentController.shared.deltaDirectory {
            ContentController.shared.downloadPackage(fromURL: url, destinationDirectory: _deltaDirectory, progressHandler: { [weak self] (stage, downloaded, totalSize, error) -> (Void) in
                if let progressHandler = progressHandler {
                    progressHandler(stage, downloaded, totalSize, error)
                }
                
                if stage == .finished {
                    DeveloperModeController.appIsInDevMode = true
                    self?.finishSwitching()
                }
            })
        }
    }
    
    private func finishSwitching() {
        
        OperationQueue.main.addOperation { 
            
            let devModeController = DeveloperModeController.shared
            
//            if DeveloperModeController.appIsInDevMode {
//                devModeController.configureDevModeAppearance()
//            } else {
//                
//                if let currentTheme = devModeController.originalTheme {
//                    ThemeManager.shared.theme = currentTheme
//                }
//                devModeController.stylingHandler?()
//            }
            
            devModeController.refreshHandler(DeveloperModeController.appIsInDevMode)
			
            devModeController.uiWindow?.isHidden = true
            devModeController.uiWindow = nil
        }
    }
    
    /// Presents UI for the user to log into developer mode
    public func loginToDeveloperMode() {
        
        if !DeveloperModeController.appIsInDevMode {
            
            guard let loginViewController = UIStoryboard(name: "Login", bundle: Bundle(for: DeveloperModeController.self)).instantiateInitialViewController() as? StormLoginViewController else { return }
            
            loginViewController.loginReason = "Log in using your Storm login to enter Dev Mode"
            
            let storyboard = UIStoryboard(name: "DeveloperMode", bundle: Bundle(for: DeveloperModeController.self))
            let downloadBundleViewController = storyboard.instantiateInitialViewController()
            loginViewController.successViewController = downloadBundleViewController
            
            loginViewController.completion = { [weak self] (success, cancelled, error) in
                
                guard let welf = self else { return }
                
                
                if cancelled {
                    
                    welf.uiWindow?.isHidden = true
                    welf.uiWindow = nil
                    
                } else if success {
                    
                    if let downloadVC = downloadBundleViewController as? DownloadingStormBundleViewController {
                        
                        downloadVC.startDownloading()
                    }
                }
            }
                
            uiWindow = UIWindow(frame: UIScreen.main.bounds)
            uiWindow?.rootViewController = loginViewController
            uiWindow?.windowLevel = .alert+1
            uiWindow?.isHidden = false
        }
    }
    
    /// Configures dev mode for the current window
    ///
    /// - parameter toWindow: The window that will be refreshed once dev mode is enabled
    /// - parameter currentTheme: The current `TSCTheme` of the app. This will be restored when switching back to live mode
    public func installDeveloperMode(toWindow: UIWindow, currentTheme: Theme?) {
        
        appWindow = toWindow
        originalTheme = currentTheme
        
        if DeveloperModeController.appIsInDevMode {
			
            let theme = DeveloperModeTheme()
            ThemeManager.shared.theme = theme
        }
    }

    /// The callback that refreshes the app once the tranision to developer mode is complete
    ///
    /// By implementing this you are making yourself responsible for switching the app into dev mode
    ///
    /// If your root view controller is not a `TSCAppViewController` overriding this will be necessary
    open var refreshHandler: (_ devMode: Bool) -> (Void) = { (devMode) -> (Void) in
        let appView = StormObjectFactory.createAppViewController()
        let devModeController = DeveloperModeController.shared
        let window = UIApplication.shared.appKeyWindow
        window?.rootViewController = StormObjectFactory.createAppViewController()
        devModeController.appWindow?.rootViewController = appView
    }
    
    /// A callback which can be used to re-theme the app after leaving dev mode.
    ///
    /// This closure should be used to re-apply any custom styling once the user has switched
    /// out of dev mode
    open var stylingHandler: (() -> (Void))? = { () -> (Void) in
        
        OperationQueue.main.addOperation {
            
            let theme = ThemeManager.shared.theme
            
            let navBar = UINavigationBar.appearance()
            navBar.setBackgroundImage(nil, for: .default)
            navBar.barTintColor = theme.mainColor
            
            UIWindow.appearance().tintColor = theme.mainColor
            
            let toolBar = UIToolbar.appearance()
            toolBar.tintColor = theme.mainColor
            
            let tabBar = UITabBar.appearance()
            tabBar.tintColor = theme.mainColor
            
            let switchView = UISwitch.appearance()
            switchView.onTintColor = theme.mainColor
			
            let checkView = CheckView.appearance()
            checkView.tintColor = theme.mainColor
        }
    }
    
    internal func configureDevModeAppearance() {
		
        let theme = DeveloperModeTheme()
        ThemeManager.shared.theme = theme

        let navBar = UINavigationBar.appearance()
        navBar.setBackgroundImage(nil, for: .default)
        navBar.barTintColor = theme.mainColor

        UIWindow.appearance().tintColor = theme.mainColor

        let toolBar = UIToolbar.appearance()
        toolBar.tintColor = theme.mainColor

        let tabBar = UITabBar.appearance()
        tabBar.tintColor = theme.mainColor

        let switchView = UISwitch.appearance()
        switchView.onTintColor = theme.mainColor
		
        let checkView = CheckView.appearance()
        checkView.tintColor = theme.mainColor
    }
}
