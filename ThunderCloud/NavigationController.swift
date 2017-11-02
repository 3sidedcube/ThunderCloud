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

public extension UINavigationController {
	
	/// Returns a shared instance of `UINavigationController`
	public static let shared: UINavigationController = UINavigationController()
	
	/// Performs an action depending on the `StormLink` type
	///
	/// - Parameter link: A `StormLink` to decide which action to perform
	public func push(link: StormLink) {
		
		let pathExtension = link.url?.pathExtension
		let scheme = link.url?.scheme
		let host = link.url?.host
		
		if scheme == "mailto", let url = link.url, UIApplication.shared.canOpenURL(url) {
			
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
			
		} else if scheme == "itunes", let url = link.url {
			
			handleITunes(url: url)
			
		} else if pathExtension == "json" || scheme == "app" && link.linkClass != .native {
			
			handlePage(link: link)
			
		} else if pathExtension == "mp4" {
			
			handleVideo(link: link)
			
		} else if scheme == "http" || scheme == "https" || (link.url != nil && link.url!.absoluteString.hasPrefix("www")) {
			
			if host == "www.youtube.com" {
				handleYouTubeVideo(link: link)
			} else {
				handleWeb(link: link)
			}
			
		} else if link.linkClass == .sms {
			
			handleSMS(link: link)
			
		} else if link.linkClass == .native, let destination = link.destination {
			
			if let handler = StormGenerator.shared.nativeLinkHandler, handler(destination, self) {
				return
			}
			
			guard let viewController = StormGenerator.viewController(nativePageName: destination) else {
				return
			}
			
			if let splitViewController = UIApplication.shared.keyWindow?.rootViewController as? SplitViewController, UI_USER_INTERFACE_IDIOM() == .pad {
				
				splitViewController.show(viewController, sender: self)
				
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
			
			NotificationCenter.default.sendStatEventNotification(category: "Call", action: url.absoluteString, label: nil, value: nil, object: nil)
			
		} else if link.linkClass == .share {
			
			handleShare(link: link)
			
		} else if link.linkClass == .emergency {
			
			handleEmergencyLink()
			
		} else if link.linkClass == .app {
			
			handleApp(link: link)
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
		
		present(viewController, animated: true, completion: nil)
	}
	
	private func handleWeb(link: StormLink) {
		
		if link.linkClass == .uri {
			
			guard let url = link.url else { return }
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
			
		} else {
			
			if #available(iOS 9, *) {
				
				var url: URL?
				
				if let linkUrl = link.url, linkUrl.scheme == "http" || linkUrl.scheme == "https" {
					url = linkUrl
				} else if let linkUrl = link.url {
					url = URL(string: "https://\(linkUrl.absoluteString)")
				}
				
				guard let _url = url else { return }
				
				let safariViewController = SFSafariViewController(url: _url)
				safariViewController.delegate = self
				safariViewController.view.tintColor = ThemeManager.shared.theme.mainColor
				
				if #available(iOS 10, *) {
					safariViewController.preferredControlTintColor = ThemeManager.shared.theme.titleTextColor
					safariViewController.preferredBarTintColor = ThemeManager.shared.theme.navigationBarBackgroundColor
				}
				
				present(safariViewController, animated: true, completion: nil)
				
			} else if let url = link.url {
				
				guard let webViewController = TSCWebViewController(url: url) else {
					return
				}
				webViewController.hidesBottomBarWhenPushed = true
				
				show(viewController: webViewController, animated: true)
			}
		}
		
		guard let url = link.url else { return }
		NotificationCenter.default.sendStatEventNotification(category: "Visit URL", action: url.absoluteString, label: nil, value: nil, object: nil)
	}
	
	private func handlePage(link: StormLink) {
		
		guard let url = link.url else { return }
		guard let viewController = StormGenerator.viewController(URL: url) else { return }
		
		viewController.hidesBottomBarWhenPushed = true
		
		// Workaround for tabbed navigation nesting
		if let tabbedPageCollection = viewController as? TabbedPageCollection, parent is TabbedPageCollection {
			
			let viewArray = tabbedPageCollection.viewControllers?.flatMap({ (viewController) -> UIViewController? in
				return (viewController as? UINavigationController)?.viewControllers.first
			}) ?? []
			
			let viewControllerClass = StormObjectFactory.shared.class(for: NSStringFromClass(NavigationTabBarViewController.self)) as? NavigationTabBarViewController.Type ?? NavigationTabBarViewController.self
			
			let tabBarViewController = viewControllerClass.init(viewControllers: viewArray, tabBarPlacement: .belowNavigationBar)
			
			pushViewController(tabBarViewController, animated: true)
			
		} else if UI_USER_INTERFACE_IDIOM() == .pad {
			
			if let quizPage = viewController as? TSCQuizPage {
				
				if let title = quizPage.title {
					NotificationCenter.default.sendStatEventNotification(category: "Quiz", action: "Start \(title) quiz", label: nil, value: nil, object: nil)
				}
				
				let navigationController = UINavigationController(rootViewController: viewController)
				navigationController.modalPresentationStyle = .formSheet
				
				guard let visibleViewController = UIApplication.shared.keyWindow?.visibleViewController else {
					return
				}
				
				if let visibleNavigation = visibleViewController.navigationController, visibleViewController.presentingViewController != nil {
					
					visibleNavigation.show(viewController: viewController, animated: true)
					
				} else if let splitViewController = UIApplication.shared.keyWindow?.rootViewController as? SplitViewController, UI_USER_INTERFACE_IDIOM() == .pad {
					
					splitViewController.setRightViewController(viewController, from: self)
					
				} else {
					
					present(navigationController, animated: true, completion: nil)
				}
				
			} else {
				
				guard let visibleViewController = UIApplication.shared.keyWindow?.visibleViewController else {
					return
				}
				
				if let visibleNavigation = visibleViewController.navigationController, visibleViewController.presentingViewController != nil {
					
					visibleNavigation.show(viewController: viewController, animated: true)
					
				} else if let splitViewController = UIApplication.shared.keyWindow?.rootViewController as? SplitViewController, UI_USER_INTERFACE_IDIOM() == .pad {
					
					splitViewController.setRightViewController(viewController, from: self)
					
				} else {
					
					show(viewController: viewController, animated: true)
				}
			}
			
		} else {
			
			pushViewController(viewController, animated: true)
		}
	}
	
	private func handleVideo(link: StormLink) {
		
		guard let videoURL = ContentController.shared.url(forCacheURL: link.url) else { return }
		
		let viewController = TSCMediaPlayerViewController()
		let video = AVPlayer(url: videoURL)
		viewController.player = video
		
		viewController.loop = link.attributes.contains("loopable")
		
		present(viewController, animated: true, completion: nil)
		
		NotificationCenter.default.sendStatEventNotification(category: "Video", action: "Local - \(link.title ?? "?")", label: nil, value: nil, object: nil)
	}
	
	private func handleYouTubeVideo(link: StormLink) {
		
		guard let url = link.url else {
			handleWeb(link: link)
			return
		}
		
		YouTubeController.loadVideo(for: url) { [weak self] (videoURL, error) in
			
			guard let strongSelf = self else { return }
			
			guard let videoURL = videoURL else {
				
				if let controllerError = error as? YouTubeControllerError {
					
					switch controllerError {
					case .failedCreatingURLComponents:
						fallthrough
					case .invalidURL:
						strongSelf.handleWeb(link: link)
					default:
						break
					}
				}
				
				let errorController = UIAlertController(
					title: "An error has occured".localised(with: "_ALERT_YOUTUBEERROR_TITLE"),
					message: "Sorry, we are unable to play this video. Please try again",
					preferredStyle: .alert)
				
				errorController.addAction(UIAlertAction(
					title: "Okay".localised(with: "_ALERT_YOUTUBEERROR_BUTTON_OKAY"),
					style: .cancel,
					handler: nil))
				
				errorController.addAction(UIAlertAction(
					title: "Retry".localised(with: "_ALERT_YOUTUBEERROR_BUTTON_RETRY"),
					style: .default,
					handler: { (action) in
						strongSelf.handleYouTubeVideo(link: link)
					}
				))
				
				strongSelf.present(errorController, animated: true, completion: nil)
				
				return
			}
			
			let mediaViewController = TSCMediaPlayerViewController()
			let videoPlayer = AVPlayer(url: videoURL)
			mediaViewController.player = videoPlayer
			strongSelf.present(mediaViewController, animated: true, completion: nil)
			NotificationCenter.default.sendStatEventNotification(category: "Video", action: "YouTube - \(link.url?.absoluteString ?? "?")", label: nil, value: nil, object: nil)
		}
	}
	
	private func handleSMS(link: StormLink) {
		
		let controller = MFMessageComposeViewController()
		if MFMessageComposeViewController.canSendText() {
			
			controller.body = link.body
			controller.recipients = link.recipients
			controller.messageComposeDelegate = self
			controller.navigationBar.tintColor = navigationBar.tintColor
			
			present(controller, animated: true, completion: nil)
			
			guard let recipients = link.recipients else { return }
			NotificationCenter.default.sendStatEventNotification(category: "SMS", action: recipients.joined(separator: ","), label: nil, value: nil, object: nil)
		}
	}
	
	private func handleShare(link: StormLink) {
		
		guard let body = link.body else { return }
		
		let shareController = UIActivityViewController(activityItems: [body], applicationActivities: nil)
		shareController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
			
			guard let activityType = activityType, completed else { return }
			NotificationCenter.default.sendStatEventNotification(category: "App", action: "Share to \(activityType.rawValue)", label: nil, value: nil, object: nil)
		}
		
		let keyWindow = UIApplication.shared.keyWindow
		
		shareController.popoverPresentationController?.sourceView = keyWindow
		if let keyWindow = keyWindow {
			shareController.popoverPresentationController?.sourceRect = CGRect(x: keyWindow.center.x, y: keyWindow.frame.maxY, width: 100, height: 100)
		}
		shareController.popoverPresentationController?.permittedArrowDirections = .up
		
		if let splitViewController = UIApplication.shared.keyWindow?.rootViewController as? SplitViewController {
			
			if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
				
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
				
				NotificationCenter.default.sendStatEventNotification(category: "Call", action: "Custom Emergency Number", label: emergencyNumber, value: nil, object: nil)
				
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
			style: .cancel,
			handler: { (action) in
				
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
	
	private func show(viewController: UIViewController, animated: Bool) {
		
		if let splitViewController = UIApplication.shared.keyWindow?.rootViewController as? SplitViewController {
			
			if UIApplication.shared.keyWindow?.visibleViewController.presentingViewController != nil || UI_USER_INTERFACE_IDIOM() != .pad {
				super.show(viewController, sender: self)
			} else {
				splitViewController.setRightViewController(viewController, from: self)
			}
			
		} else {
			
			super.show(viewController, sender: self)
			
		}
	}
	
	private func setNeedsNavigationAppearanceUpdate(in viewController: UIViewController, animated: Bool) {
		
		guard let navigationBarDataSource = viewController as? TSCNavigationBarDataSource else { return }
		guard let hidden = navigationBarDataSource.shouldHideNavigationBar?() else { return }
		
		let duration = animated ? 0.25 : 0.0
		let alpha: CGFloat = hidden ? 0.0 : 1.0
		
		UIView.animate(withDuration: duration) {
			self.navigationBar.subviews.first?.alpha = alpha
		}
	}
	
	//MARK: -
	//MARK: - Public API
	
	/// Pushes a `TSCMultiVideoPlayerViewController` player on to the screen with an array of `Video` objects
	///
	/// - Parameter videos: An array of video objects
	public func push(videos: [Video]) {
		
		let videoPlayer = MultiVideoPlayerViewController(videos: videos)
		let videoPlayerNav = UINavigationController(rootViewController: videoPlayer)
		present(videoPlayerNav, animated: true, completion: nil)
	}
	
	/// Reloads the navigation bar appearance. Used if a view needs to switch between transparency e.g. when scrolling down a view you might want the navigation bar to become opaque
	///
	/// - Parameter animated: Whether the appearance update should be animated
	public func setNeedsNavigationBarAppearanceUpdate(animated: Bool) {
		setNeedsNavigationAppearanceUpdate(in: topViewController ?? self, animated: animated)
	}
}

extension UINavigationController: SFSafariViewControllerDelegate {
	
	public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		controller.dismissAnimated()
	}
}

extension UINavigationController: MFMessageComposeViewControllerDelegate {
	public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
		controller.dismissAnimated()
	}
}

extension UINavigationController: SKStoreProductViewControllerDelegate {
	
	public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
		
		UINavigationBar.appearance().tintColor = ThemeManager.shared.theme.navigationBarTintColor
		viewController.dismissAnimated()
	}
}
