//
//  NavigationController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 10/10/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import SafariServices
import MessageUI
import StoreKit
import ThunderTable
import AVKit

// MARK: - NavigationBarDataSource

/// Any `UIViewController` can comply to this delegate. The extension provided in this file uses this method to style the navigation bar
public protocol NavigationBarDataSource {
    
    @available(iOS 13.0, *)
    var navigationBarStandardAppearance: UINavigationBarAppearance { get }
    
    @available(iOS 13.0, *)
    var navigationBarCompactAppearance: UINavigationBarAppearance { get }
    
    @available(iOS 13.0, *)
    var navigationBarScrollEdgeAppearance: UINavigationBarAppearance { get }
}

public extension NavigationBarDataSource {
    
    var navigationBarBackgroundImage: UIImage? {
        return nil
    }
    
    var navigationBarShadowImage: UIImage? {
        return nil
    }
    
    var navigationBarIsTranslucent: Bool {
        return true
    }
    
    var navigationBarIsOpaque: Bool {
        return false
    }
    
    var navigationBarAlpha: CGFloat {
        return 1.0
    }
    
    var navigationBarTintColor: UIColor? {
        return ThemeManager.shared.theme.navigationBarTintColor
    }
    
    var navigationBarBackgroundColor: UIColor? {
        return ThemeManager.shared.theme.navigationBarBackgroundColor
    }
    
    var navigationBarTitleTextAttributes: [NSAttributedString.Key : Any]? {
        return nil
    }
    
    @available(iOS 13.0, *)
    var navigationBarStandardAppearance: UINavigationBarAppearance {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = ThemeManager.shared.theme.navigationBarBackgroundColor
        
        let button = UIBarButtonItemAppearance(style: .plain)
        button.normal.titleTextAttributes = [.foregroundColor: ThemeManager.shared.theme.navigationBarTintColor]
        appearance.buttonAppearance = button
        
        appearance.titleTextAttributes = [.foregroundColor: ThemeManager.shared.theme.navigationBarTintColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: ThemeManager.shared.theme.navigationBarTintColor]
        
        return appearance
    }
    
    @available(iOS 13.0, *)
    var navigationBarCompactAppearance: UINavigationBarAppearance {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = ThemeManager.shared.theme.navigationBarBackgroundColor
        
        let button = UIBarButtonItemAppearance(style: .plain)
        button.normal.titleTextAttributes = [.foregroundColor: ThemeManager.shared.theme.navigationBarTintColor]
        appearance.buttonAppearance = button
        
        appearance.titleTextAttributes = [.foregroundColor: ThemeManager.shared.theme.navigationBarTintColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: ThemeManager.shared.theme.navigationBarTintColor]
        
        return appearance
    }
    
    @available(iOS 13.0, *)
    var navigationBarScrollEdgeAppearance: UINavigationBarAppearance {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = ThemeManager.shared.theme.navigationBarBackgroundColor
        
        let button = UIBarButtonItemAppearance(style: .plain)
        button.normal.titleTextAttributes = [.foregroundColor: ThemeManager.shared.theme.navigationBarTintColor]
        appearance.buttonAppearance = button
        
        appearance.titleTextAttributes = [.foregroundColor: ThemeManager.shared.theme.navigationBarTintColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: ThemeManager.shared.theme.navigationBarTintColor]
        
        return appearance
    }
}

public extension UINavigationController {
    
    /// Returns a shared instance of `UINavigationController`
    static let shared: UINavigationController = UINavigationController()
    
    /// Performs an action depending on the `StormLink` type
    ///
    /// - Parameter link: A `StormLink` to decide which action to perform
    func push(link: StormLink) {
        
        if let appDelegate = UIApplication.shared.delegate as? TSCAppDelegate, !appDelegate.linkIsSafelisted(link) {
            print("[Storm] Tried to push \(link.url?.absoluteString ?? "??") which is not a safelisted link")
            return
        }
        
        let pathExtension = link.url?.pathExtension
        let scheme = link.url?.scheme
        let host = link.url?.host
        
        if scheme == "mailto", let url = link.url, UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        } else if scheme == "itunes", let url = link.url {
            
            handleITunes(url: url)
            
        } else if (pathExtension == "json" || scheme == "app") && link.linkClass == .internal {
            
            handlePage(link: link)
            
        } else if Video.supportedVideoFormats.contains(pathExtension ?? "") {
            
            handleVideo(link: link)
            
        } else if scheme == "http" || scheme == "https" || (link.url != nil && link.url!.absoluteString.hasPrefix("www")) {
            
            handleWeb(link: link)
            
        } else if link.linkClass == .sms {
            
            handleSMS(link: link)
            
        } else if link.linkClass == .native, let destination = link.destination {
            
            if let handler = StormGenerator.shared.nativeLinkHandler, handler(destination, self) {
                return
            }
            
            guard let viewController = StormGenerator.viewController(nativePageName: destination) else {
                return
            }
            
            let keyWindow = UIApplication.shared.appKeyWindow
            let isIPad = UIDevice.current.userInterfaceIdiom == .pad
            if let splitViewController = keyWindow?.rootViewController as? SplitViewController, isIPad {
                
                splitViewController.setRightViewController(viewController, from: self)
                //                splitViewController.show(viewController, sender: self)
                
            } else if viewController is UINavigationController {
                
                present(viewController, animated: true, completion: nil)
                
            } else {
                
                show(viewController: viewController, animated: true)
            }
            
        } else if scheme == "tel", let url = link.url {
            
            let urlString = url.absoluteString.replacingOccurrences(of: "tel", with: "telprompt")
            guard let telephoneUrl = URL(string: urlString) else { return }
            
            if UIApplication.shared.canOpenURL(telephoneUrl) {
                UIApplication.shared.open(telephoneUrl, options: [:], completionHandler: nil)
            }
            
            NotificationCenter.default.sendAnalyticsHook(.call(url))
            
        } else if link.linkClass == .share {
            
            handleShare(link: link)
            
        } else if link.linkClass == .emergency {
            
            handleEmergencyLink()
            
        } else if link.linkClass == .app {
            
            handleApp(link: link)
            
            // Fallback if all else fails to pushing storm page from cache
        } else if pathExtension == "json" || host == "pages" {
            
            handlePage(link: link)
        }
    }
    
    //MARK: -
    //MARK: Link handlers!
    
    private func handleITunes(url: URL) {
        
        guard let host = url.host, let iTunesIdentifier = Int(host) else { return }
        
        UINavigationBar.appearance().tintColor = ThemeManager.shared.theme.primaryLabelColor
        
        let viewController = SKStoreProductViewController()
        viewController.delegate = self
        
        viewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: iTunesIdentifier], completionBlock: nil)
        
        // Notify we will present a system `UIViewController`
        NotificationCenter.default.post(sender: self, present: true, systemViewController: viewController)
        
        present(viewController, animated: true, completion: nil)
    }
    
    private func handleWeb(link: StormLink) {
        
        if link.linkClass == .uri {
            
            guard let url = link.url else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        } else {
            var navigationController = self

            // Attempt to access the key window's right-most navigation controller.
            // This resolves an issue on iPad where the SFSafariViewController is not presented correctly.
            // We do need to make sure this VC is part of the navigation stack, as on certain
            // size class iPhones this is non-nil but not part of the window (detail VC hidden in portrait)
            let keyWindow = UIApplication.shared.appKeyWindow
            if let rightMostNavigationController = keyWindow?.rightMostNavigationController, rightMostNavigationController.view.window != nil {
                navigationController = rightMostNavigationController
            }

            var url: URL?

            if let linkUrl = link.url, linkUrl.scheme == "http" || linkUrl.scheme == "https" {
                url = linkUrl
            } else if let linkUrl = link.url {
                url = URL(string: "https://\(linkUrl.absoluteString)")
            }
            
            guard let _url = url else { return }
            
            let safariViewController = SFSafariViewController(url: _url)
            safariViewController.delegate = navigationController
            safariViewController.view.tintColor = ThemeManager.shared.theme.mainColor
            
            safariViewController.preferredControlTintColor = ThemeManager.shared.theme.titleTextColor
            safariViewController.preferredBarTintColor = ThemeManager.shared.theme.navigationBarBackgroundColor
            
            // Notify we will present a system `UIViewController`
            NotificationCenter.default.post(
                sender: self,
                present: true,
                systemViewController: safariViewController
            )
            
            navigationController.present(safariViewController, animated: true, completion: nil)
        }
        
        NotificationCenter.default.sendAnalyticsHook(.visitURL(link))
    }
    
    private func handlePage(link: StormLink) {
        
        guard let url = link.url else { return }
        
        var viewController: UIViewController?
        var quiz: Quiz?
        
        if let _quiz = StormGenerator.quiz(for: url) {
            quiz = _quiz
            viewController = _quiz.questionViewController()
            NotificationCenter.default.sendAnalyticsHook(.testStart(_quiz))
        } else {
            viewController = StormGenerator.viewController(URL: url)
        }
        
        guard let _viewController = viewController else { return }
        
        _viewController.hidesBottomBarWhenPushed = shouldHideBottomBarWhenPushed()
        
        let keyWindow = UIApplication.shared.appKeyWindow
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        
        // Workaround for tabbed navigation nesting
        if let tabbedPageCollection = viewController as? TabbedPageCollection, parent is TabbedPageCollection {
            
            let viewArray = tabbedPageCollection.viewControllers?.compactMap({ (viewController) -> UIViewController? in
                return (viewController as? UINavigationController)?.viewControllers.first
            }) ?? []
            
            let viewControllerClass = StormObjectFactory.shared.class(for: NSStringFromClass(NavigationTabBarViewController.self)) as? NavigationTabBarViewController.Type ?? NavigationTabBarViewController.self
            
            let tabBarViewController = viewControllerClass.init(viewControllers: viewArray, tabBarPlacement: .belowNavigationBar)
            
            pushViewController(tabBarViewController, animated: true)
            
        } else if isIPad {
            
            if quiz != nil {
                
                let navigationController = UINavigationController(rootViewController: _viewController)
                navigationController.modalPresentationStyle = .formSheet
                
                guard let visibleViewController = keyWindow?.visibleViewController else {
                    return
                }
                
                if let visibleNavigation = visibleViewController.navigationController, visibleViewController.presentingViewController != nil {
                    
                    visibleNavigation.show(viewController: _viewController, animated: true)
                    
                } else if let splitViewController = keyWindow?.rootViewController as? SplitViewController, isIPad {
                    
                    splitViewController.setRightViewController(_viewController, from: self)
                    
                } else {
                    
                    present(navigationController, animated: true, completion: nil)
                }
                
            } else {
                
                guard let visibleViewController = keyWindow?.visibleViewController else {
                    return
                }
                
                if let visibleNavigation = visibleViewController.navigationController, visibleViewController.presentingViewController != nil {
                    
                    visibleNavigation.show(viewController: _viewController, animated: true)
                    
                } else if let splitViewController = keyWindow?.rootViewController as? SplitViewController, isIPad {
                    
                    splitViewController.setRightViewController(_viewController, from: self)
                    
                } else {
                    
                    show(viewController: _viewController, animated: true)
                }
            }
            
        } else {
            
            pushViewController(_viewController, animated: true)
        }
    }
    
    private func handleVideo(link: StormLink) {
        
        guard let videoURL = ContentController.shared.url(forCacheURL: link.url) else { return }
        
        let viewController = LoopableAVPlayerViewController()
        let video = AVPlayer(url: videoURL)
        viewController.player = video
        
        viewController.loopVideo = link.attributes.contains("loopable")
        
        present(viewController, animated: true) {
            video.play()
        }
        
        NotificationCenter.default.sendAnalyticsHook(.videoPlay(link))
    }
    
    private func handleSMS(link: StormLink) {
    
        if MFMessageComposeViewController.canSendText() {
            // Define explicit appearance changes
            UIBarButtonItem.appearance().setTitleTextAttributes([
                .foregroundColor : UIColor.systemBlue
            ], for: .normal)
            
            let controller = MFMessageComposeViewController()
            controller.body = link.body
            controller.recipients = link.recipients
            controller.messageComposeDelegate = self
            
            // Notify we will present a system `UIViewController`
            NotificationCenter.default.post(sender: self, present: true, systemViewController: controller)
            
            present(controller, animated: true, completion: nil)
            
            NotificationCenter.default.sendAnalyticsHook(.sms(link.recipients ?? [], link.body))
        }
    }
    
    private func handleShare(link: StormLink) {
        
        guard let body = link.body else { return }
        
        let shareController = UIActivityViewController(activityItems: [body], applicationActivities: nil)
        shareController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            
            NotificationCenter.default.sendAnalyticsHook(.shareApp(activityType, completed))
        }
        
        let keyWindow = UIApplication.shared.appKeyWindow
        
        shareController.popoverPresentationController?.sourceView = keyWindow
        if let keyWindow = keyWindow {
            shareController.popoverPresentationController?.sourceRect = CGRect(x: keyWindow.center.x, y: keyWindow.frame.maxY, width: 100, height: 100)
        }
        shareController.popoverPresentationController?.permittedArrowDirections = .up
        
        if let splitViewController = keyWindow?.rootViewController as? SplitViewController {
            
            if UIApplication.shared.appStatusBarOrientation.isLandscape {
                
                splitViewController.present(shareController, animated: true, completion: nil)
                
            } else {
                
                splitViewController.primaryViewController.present(shareController, animated: true, completion: nil)
            }
            
        } else {
            
            present(shareController, animated: true, completion: nil)
        }
    }
    
    private func handleEmergencyLink() {
        
        guard let emergencyNumber = UserDefaults.standard.string(forKey: "emergency_number") else {
            
            let noNumberAlertController = UIAlertController(
                title: "No Emergency Number".localised(with: "_EMERGENCY_NUMBER_MISSING"),
                message: "You have not set an emergency number. Please configure your emergency number below".localised(with: "_EMERGENCY_NUMBER_DESCRIPTION"),
                preferredStyle: .alert)
            
            noNumberAlertController.addAction(UIAlertAction(
                title: "Cancel".localised(with: "_BUTTON_CANCEL"),
                style: .cancel,
                handler: nil))
            
            noNumberAlertController.addAction(UIAlertAction(
                title: "Save".localised(with: "_BUTTON_SAVE"),
                style: .default,
                handler: { (action) in
                    
                    guard let textField = noNumberAlertController.textFields?.first else { return }
                    UserDefaults.standard.set(textField.text, forKey: "emergency_number")
            }
            ))
            
            noNumberAlertController.addTextField(configurationHandler: { (textField) in
                textField.keyboardType = .phonePad
            })
            
            present(noNumberAlertController, animated: true, completion: nil)
            
            return
        }
        
        let callNumberAlertController = UIAlertController(title: emergencyNumber, message: nil, preferredStyle: .alert)
        
        callNumberAlertController.addAction(UIAlertAction(
            title: "Cancel".localised(with: "_BUTTON_CANCEL"),
            style: .cancel,
            handler: nil))
        
        callNumberAlertController.addAction(UIAlertAction(
            title: "Call".localised(with: "_BUTTON_CALL"),
            style: .default,
            handler: { (action) in
                
                NotificationCenter.default.sendAnalyticsHook(.emergencyCall(emergencyNumber))
                
                guard let telURL = URL(string: "tel://\(emergencyNumber)") else { return }
                UIApplication.shared.open(telURL, options: [:], completionHandler: nil)
        }
        ))
        
        callNumberAlertController.addAction(UIAlertAction(
            title: "Edit".localised(with: "_BUTTON_EDIT"),
            style: .default, handler: { (action) in
                self.handleEditEmergencyNumber()
        }
        ))
        
        present(callNumberAlertController, animated: true, completion: nil)
    }
    
    private func handleApp(link: StormLink) {
        
        guard let app = link.appIdentity else { return }
        
        guard let destination = link.destination, let launcher = app.launchURL, let url = URL(string: launcher.absoluteString + destination), UIApplication.shared.canOpenURL(url) else {
            
            guard let itunesId = app.iTunesId, let appURL = URL(string: "itms-apps://itunes.apple.com/app/id" + itunesId) else {
                return
            }
            
            // Take user to the app store
            let switchAppAlertController = UIAlertController(
                title: "Open app store?".localised(with: "_ALERT_OPENAPPSTORE_TITLE"),
                message: "We will now take you to the app store to download this app".localised(with: "_ALERT_OPENAPPSTORE_MESSAGE"),
                preferredStyle: .alert)
            
            switchAppAlertController.addAction(UIAlertAction(
                title: "Dismiss".localised(with: "_ALERT_OPENAPPSTORE_BUTTON_CANCEL"),
                style: .cancel,
                handler: nil))
            
            switchAppAlertController.addAction(UIAlertAction(
                title: "Open".localised(with: "_ALERT_OPENAPPSTORE_BUTTON_OK"),
                style: .default, handler: { (action) in
                    NotificationCenter.default.sendAnalyticsHook(.appLink(link, app))
                    UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            }
            ))
            
            present(switchAppAlertController, animated: true, completion: nil)
            
            return
        }
        
        let switchAppAlertController = UIAlertController(
            title: "Switching Apps".localised(with: "_ALERT_APPSWITCH_TITLE"),
            message: "We are now switching apps".localised(with: "_ALERT_APPSWITCH_MESSAGE"),
            preferredStyle: .alert)
        
        switchAppAlertController.addAction(UIAlertAction(
            title: "Dismiss".localised(with: "_ALERT_APPSWITCH_BUTTON_CANCEL"),
            style: .cancel,
            handler: nil))
        
        switchAppAlertController.addAction(UIAlertAction(
            title: "OK".localised(with: "_ALERT_APPSWITCH_BUTTON_OK"),
            style: .default,
            handler: { (action) in
                NotificationCenter.default.sendAnalyticsHook(.appLink(link, app))
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        ))
        
        present(switchAppAlertController, animated: true, completion: nil)
    }
    
    //MARK: -
    //MARK: - Helper methods
    
    private func handleEditEmergencyNumber() {
        
        let editNumberAlertController = UIAlertController(
            title: "Edit Emergency Number".localised(with: "_EMERGENCY_NUMBER_EDIT_TITLE"),
            message: "Please edit your emergency number".localised(with: "_EDIT_EMERGENCY_NUMBER_DESCRIPTION"),
            preferredStyle: .alert)
        
        editNumberAlertController.addAction(UIAlertAction(
            title: "Cancel".localised(with: "_BUTTON_CANCEL"),
            style: .cancel, handler: nil))
        editNumberAlertController.addAction(UIAlertAction(
            title: "Save".localised(with: "_BUTTON_SAVE"),
            style: .default,
            handler: { (action) in
                
                guard let textField = editNumberAlertController.textFields?.first else { return }
                UserDefaults.standard.set(textField.text, forKey: "emergency_number")
        }
        ))
        
        editNumberAlertController.addTextField { (textField) in
            textField.keyboardType = .phonePad
        }
        
        present(editNumberAlertController, animated: true, completion: nil)
    }
    
    internal func show(viewController: UIViewController, animated: Bool) {
        let keyWindow = UIApplication.shared.appKeyWindow
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        
        if let splitViewController = keyWindow?.rootViewController as? SplitViewController {
            
            if keyWindow?.visibleViewController?.presentingViewController != nil || !isIPad {
                super.show(viewController, sender: self)
            } else {
                splitViewController.setRightViewController(viewController, from: self)
            }
            
        } else {
            
            super.show(viewController, sender: self)
            
        }
    }
    
    private func setNeedsNavigationAppearanceUpdate(in viewController: UIViewController, animated: Bool) {
        
        guard let navigationBarDataSource = viewController as? NavigationBarDataSource else { return }
        
        let duration = animated ? 0.25 : 0.0
        
        let defaultNavigationBar = UINavigationBar.appearance()
        
        if #available(iOS 13.0, *) {
            
            UIView.animate(withDuration: duration) {
                
                viewController.navigationItem.standardAppearance = navigationBarDataSource.navigationBarStandardAppearance
                viewController.navigationItem.scrollEdgeAppearance = navigationBarDataSource.navigationBarScrollEdgeAppearance
                viewController.navigationItem.compactAppearance = navigationBarDataSource.navigationBarCompactAppearance
            }
            
        } else {
            
            let backgroundImage = navigationBarDataSource.navigationBarBackgroundImage ?? defaultNavigationBar.backgroundImage(for: .default)
            let shadowImage = navigationBarDataSource.navigationBarShadowImage ?? defaultNavigationBar.shadowImage
            let isTranslucent = navigationBarDataSource.navigationBarIsTranslucent
            let tintColor = navigationBarDataSource.navigationBarTintColor
            let backgroundColor = navigationBarDataSource.navigationBarBackgroundColor
            let titleAttributes = navigationBarDataSource.navigationBarTitleTextAttributes
            let isOpaque = navigationBarDataSource.navigationBarIsOpaque
            
            UIView.animate(withDuration: duration) { [weak self] in
                
                self?.navigationBar.subviews.first?.alpha = navigationBarDataSource.navigationBarAlpha
                self?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
                self?.navigationBar.shadowImage = shadowImage
                self?.navigationBar.isTranslucent = isTranslucent
                self?.navigationBar.isOpaque = isOpaque
                self?.navigationBar.tintColor = tintColor
                self?.navigationBar.barTintColor = backgroundColor
                self?.navigationBar.titleTextAttributes = titleAttributes
            }
        }
    }
    
    /// # Context
    /// If a `UIViewController` is being pushed on the navigation controller stack and we
    /// do not want the tab bar at the bottom of the screen we set
    /// `hidesBottomBarWhenPushed = true`.
    ///
    /// # Issue
    /// Given a `UINavigationController`, in a `UITabBarController`,  with a
    /// viewController stack like:
    /// - `rootViewController`
    /// - `viewController1`
    /// - `viewController2`
    /// where want the tab bar hidden for both `viewController1` and `viewController2` but not
    /// on the `rootViewController`.
    /// Then the correct implementation would be to set `hidesBottomBarWhenPushed = true`
    /// on and before pushing `viewController1`. We don't need to set it also
    /// for `viewController2`.
    ///
    /// If we also set `hidesBottomBarWhenPushed = true` for `viewController2` then
    /// calling `popToRootViewController` from `viewController2` would pop back
    /// to `rootViewController` but the tab bar would still be hidden.
    ///
    /// # Solution
    /// Before pushing a `UIViewController` which wants the tab bar hidden, set
    /// `hidesBottomBarWhenPushed` to the `return` of this.
    /// This function checks to see if there is another `UIViewController` in the navigation
    /// controller stack (before the to be pushed) which has `hidesBottomBarWhenPushed = true`
    func shouldHideBottomBarWhenPushed() -> Bool {
        return !viewControllers.contains { $0.hidesBottomBarWhenPushed }
    }
    
    //MARK: -
    //MARK: - Public API

    /// Reloads the navigation bar appearance. Used if a view needs to switch between transparency e.g. when scrolling down a view you might want the navigation bar to become opaque
    ///
    /// - Parameter animated: Whether the appearance update should be animated
    func setNeedsNavigationBarAppearanceUpdate(animated: Bool) {
        setNeedsNavigationAppearanceUpdate(in: topViewController ?? self, animated: animated)
    }
}
