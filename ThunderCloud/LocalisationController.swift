//
//  LocalisationController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 12/09/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import ThunderBasics
import ThunderRequest

typealias LocalisationFetchCompletion = (_ localisations: [Localisation]?, _ error: Error?) -> Void

typealias LocalisationSaveCompletion = (_ error: Error?) -> Void

typealias LocalisationFetchLanguageCompletion = (_ languages: [LocalisationLanguage]?, _ locales: [LocalisationLocale]?, _ error: Error?) -> Void

private typealias LocalisationRefreshCompletion = (_ error: Error?) -> Void

extension UIView {
	
	var localisation: (text: String?, localisationKey: String)? {
		get {
			
			if let label = self as? LocalisableLabel, let localisationKey = label.localisationKey {
				return (text: label.text, localisationKey: localisationKey)
			} else if let label = self as? UILabel, let localisationKey = label.text?.localisationKey {
				return (text: label.text, localisationKey: localisationKey)
			} else if let textView = self as? UITextView, let localisationKey = textView.text?.localisationKey {
				return (text: textView.text, localisationKey: localisationKey)
			} else {
				return nil
			}
		}
		set {}
	}
}

@objc(TSCLocalisationController)
/// A Controller for managing CMS localisations
/// Can be used to fetch localisations from the current CMS, Update localisations on the CMS, discover available languages in the CMS.
public class LocalisationController: NSObject {
	
	enum EditActivationMode {
		/// No event will cause activation, you must call `toggleEditing` to toggle editing on/off
		case none
		/// Shake the device to enable localisation editing
		case shakeDevice
		///  Take a screenshot to enable localisation editing
		case takeScreenshot
		///  Swipe left with two fingers to enable localisation editing
		case twoFingerLeftSwipe
	}
	
	//MARK: - Private API
	//MARK: -
	
	private var requestController: RequestController?
	
	private let authenticationController = AuthenticationController()
	
	private var isReloading = false
	
	private var loginWindow: UIWindow?
	
	internal var localisationsDictionary: [String: [AnyHashable : Any]] = [:]
	
	private var localisations: [Localisation]?
	
	public override init() {
		
		super.init()
		
		guard let apiVersion = Bundle.main.infoDictionary?["TSCAPIVersion"] as? String else { return }
		guard let baseAddress = Bundle.main.infoDictionary?["TSCBaseURL"] as? String else { return }
		guard let appID = UserDefaults.standard.string(forKey: "TSCAppId") ?? API_APPID else { return }
        guard let baseURL = URL(string: "\(baseAddress)/\(apiVersion)/apps/\(appID)") else { return }
        
        requestController = RequestController(baseURL: baseURL)
	}
	
	//MARK: - Public API
	//MARK: -
	
	/// Singleton localisation controller
	@objc(sharedController)
	public static let shared = LocalisationController()
	
	/// Whether the user is currently editing localisations
	var editing = false
	
	private var activationGesture: UIGestureRecognizer?
	
	private var screenshotObserver: Any?
	
	/// Defines how the user can activate localisation editing
	var activationMode: EditActivationMode = .shakeDevice {
		didSet {
			
			if let activationGesture = activationGesture {
				UIApplication.shared.keyWindow?.removeGestureRecognizer(activationGesture)
				self.activationGesture = nil
			}
			
			if let screenshotObserver = screenshotObserver {
				NotificationCenter.default.removeObserver(screenshotObserver)
				self.screenshotObserver = nil
			}
			
			switch activationMode {
			case .twoFingerLeftSwipe:
				
				let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(toggleEditing))
				UIApplication.shared.keyWindow?.addGestureRecognizer(swipeGestureRecognizer)
				swipeGestureRecognizer.numberOfTouchesRequired = 2
				swipeGestureRecognizer.direction = .left
				activationGesture = swipeGestureRecognizer
				
				break
			case .takeScreenshot:
				
                screenshotObserver = NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: .main, using: { [weak self] (notification) in
					
					guard let strongSelf = self else { return }
					strongSelf.toggleEditing()
				})
				
			default:
				break
			}
		}
	}
	
	@objc public func localisationDictionary(forKey: String) -> [AnyHashable : Any]? {
		return localisationsDictionary[forKey]
	}
	
	/// An array of languages, populated from the CMS.
	var availableLanguages: [LocalisationLanguage]?
    
    /// An array of locales, populated from the CMS.
    var availableLocales: [LocalisationLocale]?
	
	/// An array of all the edited localisations, which is cleared every time they are saved to the CMS
	private var editedLocalisations: [Localisation]?
	
	/// An array of localisations which weren't picked up on when view highlighting occured
	@objc public var additionalLocalisedStrings: [String]?
	
	/// Enables or disables editing mode for the current view
	@objc public func toggleEditing() {
		
		// If we're reloading localisations from the CMS don't allow toggle, also if we're displaying an edit view controller don't allow it
		guard !isReloading, localisationEditingWindow == nil, loginWindow == nil else {
			return
		}
		
		editing = !editing
		
		let highestWindow = UIApplication.shared.keyWindow
		guard let visibleViewController = highestWindow?.visibleViewController else { return }
		
		// If user has turned on editing
		if editing {
			
			isReloading = true
			
			if let authentication = authenticationController.authentication, !authentication.hasExpired {
				
				showActivityIndicatorWith(title: "Loading Localisations")
				
				reloadLocalisations(completion: { (error) in
					
					guard error == nil else {
						
						self.editing = false
						self.isReloading = false
						self.dismissActivityIndicator()
						print("<Storm Localisations> Failed to load localisations")
						return
					}
					
					self.perform(action: .enableEditing, in: visibleViewController)
				})
				
			} else {
				
				askForLogin(completion: { (loggedIn, cancelled, error) in
					
					guard loggedIn, !cancelled else {
						
						// If the user cancelled login, hide the login window otherwise we got an error but we
                        // want to allow the user to try again!
						if cancelled {
                            
							self.editing = false
							self.isReloading = false
							self.dismissActivityIndicator()
                            
                            self.loginWindow?.isHidden = true
                            self.loginWindow = nil
                        }
                        
						return
					}
					
                    self.loginWindow?.isHidden = true
                    self.loginWindow = nil
					self.showActivityIndicatorWith(title: "Loading Localisations")
					
					self.reloadLocalisations(completion: { (error) in
						
						guard error == nil else {
							
							self.isReloading = false
							self.editing = false
							self.dismissActivityIndicator()
							print("<Storm Localisations> Failed to load localisations")
							return
						}
						
						self.perform(action: .enableEditing, in: visibleViewController)
					})
				})
			}
			
		} else {
			
			isReloading = true
			
			if let editedLocalisations = editedLocalisations, editedLocalisations.count > 0 {
				saveEditedLocalisations(completion: { (error) in
					guard error == nil else { return }
					print("Saved localisations! :D")
				})
			}
			
			perform(action: .disableEditing, in: visibleViewController)
		}
	}
	
	private var alertViewIsPresented = false
	
	private var gestureRecognisers: [UITapGestureRecognizer]?
	
	private var visibleViewControllerView: UIView?
	
	private enum ViewControllerAction {
		case enableEditing
		case disableEditing
		case reloadViews
	}
	
	private func perform(action: ViewControllerAction, in viewController: UIViewController) {
		
		alertViewIsPresented = false
		
		if action == .enableEditing {
			gestureRecognisers = []
			additionalLocalisedStrings = []
		}
		
		// Check for navigation controller, highlight it's views and add a gesture recognizer to it
		
		var localisedViews: [(view: UIView, localisationKey: String)] = []
		var gesturesViews: [UIView] = []
		
		if let navigationController = viewController.navigationController, !navigationController.isNavigationBarHidden {
			
			localisedViews.append(contentsOf: localisedSubviews(of: navigationController.navigationBar))
			gesturesViews.append(navigationController.navigationBar)
		}
		
		// Check for tab bar, highlight it's views and add a gesture recognizer to it
		if let tabController = viewController.tabBarController, !tabController.tabBar.isHidden {
			
			localisedViews.append(contentsOf: localisedSubviews(of: tabController.tabBar))
			gesturesViews.append(tabController.tabBar)
		}
		
		// See if the displayed view controller is a `UITableViewController`
		if let tableViewController = viewController as? UITableViewController {
			
			tableViewController.tableView.reloadData()
			
			localisedHeaderFooters(in: tableViewController).forEach({
				
				if let view = $0.view {
					localisedViews.append((view: view, localisationKey: $0.localisationKey))
				} else if action == .enableEditing {
					additionalLocalisedStrings?.append($0.localisationKey)
				}
			})
			
			tableViewController.tableView.isScrollEnabled = action != .enableEditing
		}
		
		// Get main view controller and highlight it's views
		visibleViewControllerView = viewController.view
		
		localisedViews.append(contentsOf: localisedSubviews(of: viewController.view))
		gesturesViews.append(viewController.view)
		
		switch action {
		case .enableEditing:
			
			visibleViewControllerView = viewController.view
			
			localisedViews.forEach({
				$0.view.isUserInteractionEnabled = true
				addHighlight(to: $0.view, withLocalisationKey: $0.localisationKey)
			})
			gesturesViews.forEach({
				addGestures(to: $0)
			})
			
			if let window = UIApplication.shared.keyWindow, !window.isMember(of: UIWindow.self) { // Does this always mean we're in a UIAlertView or UIActionSheet? I'm not so sure...
				
				if let window = UIApplication.shared.keyWindow {
					localisedSubviews(of: window).forEach({
						additionalLocalisedStrings?.append($0.localisationKey)
					})
				}
			}
			
			break
		case .disableEditing:
			
			visibleViewControllerView = nil
			gesturesViews.forEach({
				removeGestures(from: $0)
				removeHighlights(from: $0.subviews)
			})
			
			break
		case .reloadViews:
			
			localisedViews.forEach({
				reload(localisedView: $0.view)
			})
			
			break
		}
		
		isReloading = false
		dismissActivityIndicator()
		
		if action != .reloadViews {
			setMoreButton(hidden: action != .enableEditing)
		}
	}
	
	private func reloadLocalisations(completion: @escaping LocalisationRefreshCompletion) {
		
        if let authorization = authenticationController.authentication, !authorization.hasExpired {
            requestController?.sharedRequestHeaders["Authorization"] = authorization.token
        }
		
		fetchAvailableLanguages { (languages, locales, error) in
			
			if let error = error {
				completion(error)
			} else {
				self.fetchLocalisations(completion: { (localisations, error) in
					completion(error)
				})
			}
		}
	}
	
	//MARK: - View Recursion
	
	private func localisedSubviews(of view: UIView) -> [(view: UIView, localisationKey: String)] {
		
		var viewStrings: [(view: UIView, localisationKey: String)] = []
		
		view.enumerateSubviews { (view, stop) in
			
			guard let localisation = view.localisation else { return }
			viewStrings.append((view: view, localisationKey: localisation.localisationKey))
		}
		
		return viewStrings
	}
	
	private func localisedHeaderFooters(in tableViewController: UITableViewController)  -> [(view: UIView?, localisationKey: String)] {
		
		var viewStrings: [(view: UIView?, localisationKey: String)] = []
		guard let tableView = tableViewController.tableView else {
			return []
		}
		
		for index in 0..<tableView.numberOfSections {
			
			if let headerView = tableView.delegate?.tableView?(tableView, viewForHeaderInSection: index) {
				
				let viewKeys = localisedSubviews(of: headerView)
				viewKeys.forEach({ viewStrings.append((view: $0.view, localisationKey: $0.localisationKey)) })
			}
			
			if let headerTitle = tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: index), let localisationKey = headerTitle.localisationKey {
				
				viewStrings.append((view: nil, localisationKey: localisationKey))
			}
			
			if let footerView = tableView.delegate?.tableView?(tableView, viewForFooterInSection: index) {
				
				let viewKeys = localisedSubviews(of: footerView)
				viewKeys.forEach({ viewStrings.append((view: $0.view, localisationKey: $0.localisationKey)) })
			}
			
			if let footerTitle = tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: index), let localisationKey = footerTitle.localisationKey {
				
				viewStrings.append((view: nil, localisationKey: localisationKey))
			}
		}
		
		return viewStrings
	}
	
	var navigationBarLocalisations: [(text: String?, localisationKey: String)] = []
	
	func findLocalisationKeys(in subviews: [UIView]) {
		
		subviews.forEach { (view) in
			
			guard let localisation = view.localisation else {
				if view != visibleViewControllerView {
					findLocalisationKeys(in: view.subviews)
				}
				return
			}
			
			navigationBarLocalisations.append(localisation)
		}
	}
	
	//MARK: - View highlighting
	
	private func addHighlight(to view: UIView, withLocalisationKey localisationKey: String) {
		
		let highlightView = TSCView(frame: view.bounds)
		highlightView.cornerRadius = 4.0
		highlightView.borderColor = .black
		highlightView.borderWidth = 1.0
		
		if let localisation = CMSLocalisation(for: localisationKey) {
			
			// If any of the localised values (One for each language) has been edited
			if localisation.localisationValues.first(where: { (localisationKeyValue) -> Bool in
				return localisationKeyValue.localisedString != "".localised(with: localisationKey)
			}) != nil {
				highlightView.backgroundColor = .orange
			} else {
				highlightView.backgroundColor = .green
			}
			
		} else {
			
			highlightView.backgroundColor = .red
		}
		
		highlightView.alpha = 0.2
		highlightView.tag = 635355756
		highlightView.isUserInteractionEnabled = false
		view.addSubview(highlightView)
	}
	
	private func removeHighlights(from: [UIView]) {
		
		from.forEach { (view) in
			
			if view.tag == 635355756 {
				view.removeFromSuperview()
			}
			
			if view.localisation != nil {
				view.isUserInteractionEnabled = false
			}
			removeHighlights(from: view.subviews)
		}
	}
	
	/// Important to keep track, so we don't accidentally remove other gesture
	/// recognizers the user might need!
	private var gestureRecognizers: [UIGestureRecognizer] = []
	
	private func addGestures(to view: UIView) {
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentLocalisationEditViewController(sender:)))
		view.isUserInteractionEnabled = true
		tapGesture.delegate = self
		gestureRecognizers.append(tapGesture)
		view.addGestureRecognizer(tapGesture)
	}
	
	private func removeGestures(from view: UIView) {
		
		view.gestureRecognizers?.filter({
			gestureRecognizers.contains($0)
		}).forEach({
			view.removeGestureRecognizer($0)
		})
	}
	
	func redrawViewsWithEditedLocalisations() {
		
		editedLocalisations?.forEach({ (localisation) in
			
			localisationsDictionary[localisation.localisationKey] = localisation.serialisableRepresentation
		})
		
		guard let visibleViewController = UIApplication.shared.keyWindow?.visibleViewController else { return }
		
		perform(action: .reloadViews, in: visibleViewController)
	}
	
	func reload(localisedView: UIView) {
		
		if let localisableLabel = localisedView as? LocalisableLabel {
			
			let localisationKey = localisableLabel.localisationKey
			localisableLabel.localisationKey = localisationKey
			
		} else if let label = localisedView as? UILabel {
			
			guard let text = label.text, let localisationKey = text.localisationKey else { return }
			
			let newString = text.localised(with: localisationKey)
			label.text = newString
			
			if let button = localisedView.superview as? UIButton {
				button.setTitle(newString, for: .normal)
			}
			
		} else if let localisableButton = localisedView as? LocalisableButton {
			
			let localisationKey = localisableButton.localisationKey
			localisableButton.localisationKey = localisationKey
			
		} else if let textView = localisedView as? UITextView {
			
			guard let text = textView.text, let localisationKey = text.localisationKey else { return }
			textView.text = text.localised(with: localisationKey)
		}
	}
	
	//MARK: - Presenting editing
	//MARK: -
	
	private var moreButton: UIButton?
	
	private func setMoreButton(hidden: Bool) {
		
		if hidden {
			
			UIView.animate(withDuration: 1.0, animations: {
				self.moreButton?.alpha = 0.0
			}, completion: { (finished) in
				if finished {
					self.moreButton?.removeFromSuperview()
				}
			})
			
		} else {
			
			let mainWindow = UIApplication.shared.keyWindow
			let button = UIButton(frame: CGRect(x: 8, y: UIApplication.shared.statusBarFrame.height + 6, width: 44, height: 44))
			button.alpha = 0.0
			button.addTarget(self, action: #selector(showMoreInfo), for: .touchUpInside)
			
			let buttonImage = UIImage(named: "localisations-morebutton", in: Bundle.init(for: LocalisationController.self), compatibleWith: nil)
			button.setImage(buttonImage, for: .normal)
			
			mainWindow?.addSubview(button)
            mainWindow?.bringSubviewToFront(button)
			
			moreButton = button
			
			UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.8, options: [], animations: {
				button.alpha = 1.0
			})
		}
	}
	
	fileprivate var localisationEditingWindow: UIWindow?
	
	@objc private func presentLocalisationEditViewController(sender: UITapGestureRecognizer) {
		
		let touchPoint = sender.location(in: sender.view)
		guard let view = sender.view?.hitTest(touchPoint, with: nil) else { return }
		
		if let localisation = view.localisation {
			presentLocalisationEditViewControllerFor(localisationKey: localisation.localisationKey)
			return
		}
		
		guard let navBar = sender.view as? UINavigationBar else { return }
		
		navigationBarLocalisations = []
		findLocalisationKeys(in: navBar.subviews)
		
		let alert = UIAlertController(title: "Choose a localisation", message: "Pick one of the strings below to edit it's localisation in the CMS", preferredStyle: .actionSheet)
		
		navigationBarLocalisations.forEach { (localisation) in
			
			alert.addAction(UIAlertAction(title: localisation.text ?? localisation.localisationKey, style: .default, handler: { (action) in
				self.presentLocalisationEditViewControllerFor(localisationKey: localisation.localisationKey)
			}))
		}
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		UIApplication.shared.keyWindow?.visibleViewController?.present(alert, animated: true, completion: nil)
	}
	
	private func presentLocalisationEditViewControllerFor(localisationKey: String) {
		
		let editViewController: LocalisationEditViewController
		
		if let localisation = CMSLocalisation(for: localisationKey)
{
			editViewController = LocalisationEditViewController(withLocalisation: localisation)
		} else {
			editViewController = LocalisationEditViewController(withKey: localisationKey)
		}
		
		editViewController.delegate = self
		let navigationController = UINavigationController(rootViewController: editViewController)
		
		navigationController.navigationBar.tintColor = .black
		navigationController.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black
		]
		navigationController.navigationBar.setBackgroundImage(nil, for: .default)
		navigationController.navigationBar.barTintColor = .white
		
		localisationEditingWindow = UIWindow(frame: UIScreen.main.bounds)
		localisationEditingWindow?.rootViewController = navigationController
        localisationEditingWindow?.windowLevel = .alert+1
		localisationEditingWindow?.isHidden = false
		
		localisationEditingWindow?.transform = CGAffineTransform(translationX: 0, y: localisationEditingWindow!.frame.height)
		
		UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {
			self.localisationEditingWindow?.transform = .identity
		}, completion: nil)
	}
	
	fileprivate var needsRedraw = false
	
	@objc func showMoreInfo() {
		
		let explanationViewController = LocalisationExplanationViewController()
		
		explanationViewController.dismissHandler = { [weak self] in
			
			guard let strongSelf = self else { return }
			
			strongSelf.localisationEditingWindow?.isHidden = true
			strongSelf.localisationEditingWindow = nil
			
			if strongSelf.needsRedraw {
				strongSelf.redrawViewsWithEditedLocalisations()
			}
		}
		
		localisationEditingWindow = UIWindow(frame: UIScreen.main.bounds)
		localisationEditingWindow?.rootViewController = explanationViewController
        localisationEditingWindow?.windowLevel = .alert
		localisationEditingWindow?.isHidden = false
	}
	
	//MARK: - Saving localisations
	//MARK: -
	
	func add(editedLocalisation: Localisation) {
		
		if var editedLocalisations = editedLocalisations {
			
			if let index = editedLocalisations.index(where: { $0.localisationKey == editedLocalisation.localisationKey }) {
				editedLocalisations[index] = editedLocalisation
			} else {
				editedLocalisations.append(editedLocalisation)
			}
			
			self.editedLocalisations = editedLocalisations
			
		} else {
			
			editedLocalisations = [editedLocalisation]
		}
		
		// Because we are letting the user add new keys to the CMS, we need to make sure they can't add them multiple times
		guard let localisations = localisations else { return }
		
		if localisations.index(where: { $0.localisationKey == editedLocalisation.localisationKey }) == nil {
			self.localisations?.append(editedLocalisation)
		}
	}
	
	/// Saves all edited localisations to the server
	///
	/// - Parameter completion: A closure to be called when the localisations have saved
	func saveEditedLocalisations(completion: LocalisationSaveCompletion?) {
		
		guard let editedLocalisations = editedLocalisations else {
			completion?(LocalisationControllerError.noLocalisationsEdited)
			return
		}
		
		var body: [AnyHashable : Any] = [:]
		
		editedLocalisations.forEach { (editedLocalisation) in
			
			body[editedLocalisation.localisationKey] = editedLocalisation.serialisableRepresentation
			self.localisationsDictionary[editedLocalisation.localisationKey] = editedLocalisation.serialisableRepresentation
		}
		
		let payload = [
			"strings": body
		]
		self.editedLocalisations = nil
		
		showActivityIndicatorWith(title: "Saving")
		
        requestController?.request("native", method: .PUT, body: JSONRequestBody(body)) { (response, error) in
			
			if let error = error {
				
				// If we error when saving, add them back into the array to save later
				self.editedLocalisations = editedLocalisations
				completion?(error)
			} else {
				self.dismissActivityIndicator()
				completion?(nil)
			}
		}
	}
	
	//MARK: - Logging in
	//MARK: -
	func askForLogin(completion: StormLoginViewController.LoginCompletion?) {
		
		let storyboard = UIStoryboard(name: "Login", bundle: Bundle.init(for: LocalisationController.self))
		let loginViewController = storyboard.instantiateInitialViewController() as! StormLoginViewController
		loginViewController.loginReason = "Log in to your Storm account to start editing localisations"
		
		loginViewController.completion = { (success, cancelled, error) in
			
			completion?(success, cancelled, error)
		}
		
		loginWindow = UIWindow(frame: UIScreen.main.bounds)
		loginWindow?.rootViewController = loginViewController
        loginWindow?.windowLevel = .alert+1
		loginWindow?.isHidden = false
	}
	
	//MARK: - Fetching/Updating from/with CMS
	//MARK: -
	
	/// Fetches the CMS localisations from the server
	///
	/// - Parameter completion: A closure to be called once the localisations have been fetched
	func fetchLocalisations(completion: LocalisationFetchCompletion?) {
		
        requestController?.request("native", method: .GET) { (response, error) in
            
			if let error = error {
				completion?(nil, error)
				return
			}
			
			let localisations = response?.dictionary?.compactMap({ (keyValue) -> Localisation? in
				guard let dictionary = keyValue.value as? [AnyHashable : Any] else { return nil }
				guard let key = keyValue.key as? String else { return nil }
				return Localisation(dictionary: dictionary, key: key)
			})
			
			self.localisations = localisations
			completion?(localisations, nil)
		}
	}
	
	/// Fetches the available languages for the app
	///
	/// - Parameter completion: A closure to be called when the languages have been fetched
	func fetchAvailableLanguages(completion: LocalisationFetchLanguageCompletion?) {
		
        requestController?.request("languages", method: .GET) { [weak self] (response, error) in
            
            guard let this = self else { return }
            
			if let error = error {
                
                guard (error as NSError).code == 404, let self = self else {
                    
                    completion?(nil, nil, error)
                    return
                }
                
                this.requestController?.request("locales", method: .GET) { [weak this] (localesResponse, localesError) in
                    
                    if let localesError = localesError {
                        completion?(nil, nil, localesError)
                        return
                    }
                    
                    guard let responseArray = localesResponse?.array as? [[AnyHashable : Any]] else {
                        completion?(nil, nil, nil)
                        return
                    }
                    
                    let locales = responseArray.map({
                        LocalisationLocale(dictionary: $0)
                    })
                    
                    this?.availableLocales = locales
                    completion?(nil, locales, nil)
                }
                
                return
			}
			
			guard let responseDictionary = response?.array as? [[AnyHashable : Any]] else {
				completion?(nil, nil, nil)
				return
			}
			
			let languages = responseDictionary.map({
				LocalisationLanguage(dictionary: $0)
			})
			
            this.availableLanguages = languages
			completion?(languages, nil, nil)
		}
	}
//
//	/**
//	@abstract Looks up the human readable language name for a code in the CMS's configured languages
//	@param key The language key to be used when looking up the localised language name
//	*/
//	- (NSString *)localisedLanguageNameForLanguageKey:(NSString *)key;
//
//	/**
//	@abstract Returns a language object for a CMS language code
//	@param key The language key to be used when looking up the language
//	*/
//	- (LocalisationLanguage *)languageForLanguageKey:(NSString *)key;
//
//	/**
//	@abstract If the user has edited strings in the CMS this will return the string they have saved
//	@param key The localisation key to be used to find the readable string
//	*/
//	- (NSDictionary *)localisationDictionaryForKey:(NSString *)key;
//
	
	/// Returns the CMS localisation for a key
	///
	/// - Parameter localisationKey: The key to return the localisation object for
	/// - Returns: An optional Localisation
	public func CMSLocalisation(for localisationKey: String) -> Localisation? {
		
		return localisations?.first(where: {
			$0.localisationKey == localisationKey
		})
	}
	
	//MARK: - Activity View Controllers
	//MARK: -
	
	private var activityIndicatorWindow: UIWindow?
	
	private func showActivityIndicatorWith(title: String) {
		activityIndicatorWindow = UIWindow(frame: UIScreen.main.bounds)
		activityIndicatorWindow?.isHidden = false
        HUDActivityView.addHUDWith(identifier: "ThunderCloud_LocalisationController", to: activityIndicatorWindow!, withText: title)
	}
	
	private func dismissActivityIndicator() {
		guard let activityIndicatorWindow = activityIndicatorWindow else { return }
        HUDActivityView.removeHUDWith(identifier: "ThunderCloud_LocalisationController", in: activityIndicatorWindow)
		self.activityIndicatorWindow = nil
	}
}


//MARK: - UIGestureRecognizerDelegate
//MARK: -
extension LocalisationController: UIGestureRecognizerDelegate {
	
	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return false
	}
}

//MARK: - LocalisationEditViewControllerDelegate
//MARK: -
extension LocalisationController: LocalisationEditViewControllerDelegate {
	
	public func editingCancelled(in viewController: LocalisationEditViewController) {
		
		UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {
			
			self.localisationEditingWindow?.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
			
		}) { (finished) in
			
			if finished {
				
				self.localisationEditingWindow?.resignKey()
				self.localisationEditingWindow?.isHidden = true
				self.localisationEditingWindow = nil
			}
		}
	}
	
	public func editingSaved(in viewController: LocalisationEditViewController?) {
		
		guard viewController != nil else {
			needsRedraw = true
			return
		}
		
		UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {
			
			self.localisationEditingWindow?.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
			
		}) { (finished) in
			
			if finished {
				
				self.localisationEditingWindow?.resignKey()
				self.localisationEditingWindow?.isHidden = true
				self.localisationEditingWindow = nil
			}
		}
		
		redrawViewsWithEditedLocalisations()
	}
}

/// An enum containing potential errors when dealing with localisation controller
enum LocalisationControllerError: Error, LocalizedError {
	
	/// No localisations have been edited
	case noLocalisationsEdited
}
