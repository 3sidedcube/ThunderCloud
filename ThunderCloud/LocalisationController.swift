//
//  LocalisationController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 12/09/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import ThunderRequest

typealias LocalisationFetchCompletion = (_ localisations: [Localisation]?, _ error: Error?) -> Void

typealias LocalisationSaveCompletion = (_ error: Error?) -> Void

typealias LocalisationFetchLanguageCompletion = (_ languages: [LocalisationLanguage], _ error: Error?) -> Void

private typealias LocalisationRefreshCompletion = (_ error: Error?) -> Void

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
	
	private var requestController: TSCRequestController?
	
	private var isReloading = false
	
	private var localisationEditingWindow: UIWindow?
	
	private var loginWindow: UIWindow?
	
	private var localisationsDictionary: [String: [AnyHashable : Any]] = [:]
	
	public override init() {
		
		super.init()
		
		guard let apiVersion = Bundle.main.infoDictionary?["TSCAPIVersion"] as? String else { return }
		guard let baseURL = Bundle.main.infoDictionary?["TSCBaseURL"] as? String else { return }
		guard let appID = Bundle.main.infoDictionary?["TSCAppId"] as? String else { return }
		
		requestController = TSCRequestController(baseAddress: "\(baseURL)/\(apiVersion)/apps/\(appID)")
	}
	
	//MARK: - Public API
	//MARK: -
	
	/// Singleton localisation controller
	static let shared = LocalisationController()
	
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
				
				screenshotObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil, queue: .main, using: { [weak self] (notification) in
					
					guard let strongSelf = self else { return }
					strongSelf.toggleEditing()
				})
				
			default:
				break
			}
		}
	}
	
	/// An array of languages, populated from the CMS.
	var availableLanguages: [LocalisationLanguage]?
	
	/// An array of all the edited localisations, which is cleared every time they are saved to the CMS
	private var editedLocalisations: [Localisation] = []
	
	/// An array of localisations which weren't picked up on when view highlighting occured
	private var additionalLocalisedStrings: [String]?
	
	/// Enables or disables editing mode for the current view
	func toggleEditing() {
		
		// If we're reloading localisations from the CMS don't allow toggle, also if we're displaying an edit view controller don't allow it
		guard !isReloading, localisationEditingWindow == nil, loginWindow == nil else {
			return
		}
		
		editing = !editing
		
		let highestWindow = UIApplication.shared.keyWindow
		guard let visibleViewController = highestWindow?.visibleViewController else { return }
		
		// If user has turned on editing
		if editing {
			
			if TSCAuthenticationController.sharedInstance().isAuthenticated() {
				
				isReloading = true
				showActivityIndicatorWith(title: "Loading Localisations")
				
				reloadLocalisations(completion: { (error) in
					
					guard error == nil else {
						print("<Storm Localisations> Failed to load localisations")
						return
					}
					
					self.toggleEditing(to: true, in: visibleViewController)
				})
				
			} else {
				
				askForLogin(completion: { (loggedIn, cancelled) in
					
					guard loggedIn else { return }
					self.toggleEditing(to: true, in: visibleViewController)
				})
			}
		} else {
			
			isReloading = true
			
			if editedLocalisations.count > 0 {
				saveEditedLocalisations(completion: { (error) in
					guard error == nil else { return }
					print("Saved localisations! :D")
				})
			}
			
			self.toggleEditing(to: false, in: visibleViewController)
		}
	}
	
	private var alertViewIsPresented = false
	
	private var gestureRecognisers: [UITapGestureRecognizer]?
	
	private var visibleViewControllerView: UIView?
	
	private func toggleEditing(to editing: Bool, in viewController: UIViewController) {
		
		alertViewIsPresented = false
		gestureRecognisers = []
		additionalLocalisedStrings = []
		
		// Check for navigation controller, highlight it's views and add a gesture recognizer to it
		if let navigationController = viewController.navigationController, !navigationController.isNavigationBarHidden {
			
			if editing {
				
				localisedSubviews(of: navigationController.navigationBar).forEach({
					$0.view.isUserInteractionEnabled = true
					addHighlight(to: $0.view, withLocalisationKey: $0.localisationKey)
				})
				
				addGestures(to: navigationController.view)
				
			} else {
				
				removeHighlights(from: navigationController.navigationBar.subviews)
				removeGestures(from: navigationController.navigationBar)
			}
		}
		
		// Check for tab bar, highlight it's views and add a gesture recognizer to it
		if let tabController = viewController.tabBarController, !tabController.tabBar.isHidden {
			
			if editing {
				
				localisedSubviews(of: tabController.tabBar).forEach({
					$0.view.isUserInteractionEnabled = true
					addHighlight(to: $0.view, withLocalisationKey: $0.localisationKey)
				})
				
				addGestures(to: tabController.tabBar)
				
			} else {
				
				removeHighlights(from: tabController.tabBar.subviews)
				removeGestures(from: tabController.tabBar)
			}
		}
		
		// See if the displayed view controller is a `UITableViewController`
		if let tableViewController = viewController as? UITableViewController {
			
			if editing {
				
				tableViewController.tableView.reloadData()
				
				localisedHeaderFooters(in: tableViewController).forEach({
					addHighlight(to: $0.view, withLocalisationKey: $0.localisationKey)
				})
			}
			
			tableViewController.tableView.isScrollEnabled = !editing
		}
		
		if editing {
			
			// Get main view controller and highlight it's views
			visibleViewControllerView = viewController.view
			
			localisedSubviews(of: viewController.view).forEach({
				$0.view.isUserInteractionEnabled = true
				addHighlight(to: $0.view, withLocalisationKey: $0.localisationKey)
			})
			
			addGestures(to: viewController.view)
			
		} else {
			
			removeHighlights(from: viewController.view.subviews)
			removeGestures(from: viewController.view)
			
			visibleViewControllerView = nil
		}
		
		if let window = UIApplication.shared.keyWindow, !window.isMember(of: UIWindow.self) { // Does this always mean we're in a UIAlertView or UIActionSheet? I'm not so sure...
			
			if let window = UIApplication.shared.keyWindow {
				localisedSubviews(of: window).forEach({
					additionalLocalisedStrings?.append($0.localisationKey)
				})
			}
		}
		
		isReloading = false
		dismissActivityIndicator()
		
		setMoreButton(hidden: !editing)
	}
	
	private func reloadLocalisations(completion: LocalisationRefreshCompletion) {
		
	}
	
	//MARK: - View Recursion
	
	private func localisedSubviews(of view: UIView) -> [(view: UIView, localisationKey: String)] {
		
		var viewStrings: [(view: UIView, localisationKey: String)] = []
		
		view.enumerateSubviews { (view, stop) in
			
			if let label = view as? LocalisableLabel, let localisationKey = label.localisationKey {
				viewStrings.append((view: label, localisationKey: localisationKey))
			} else if let label = view as? UILabel, let localisationKey = label.text?.localisationKey {
				viewStrings.append((view: label, localisationKey: localisationKey))
			} else if let textView = view as? UITextView, let localisationKey = textView.text?.localisationKey {
				viewStrings.append((view: textView, localisationKey: localisationKey))
			}
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
	
	//MARK: - View highlighting
	
	private func addHighlight(to view: UIView, withLocalisationKey localisationKey: String) {
		
		let highlightView = TSCView(frame: view.bounds)
		highlightView.cornerRadius = 4.0
		highlightView.borderColor = .black
		highlightView.borderWidth = 1.0
		
		if let localisation = CMSLocalisation(for: localisationKey) {
			
			// If any of the localised values (One for each language) has been edited
			if localisation.localisationValues.first(where: { (localisationKeyValue) -> Bool in
				return localisationKeyValue.localisedString == "".localised(with: localisationKey)
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
		
	}
	
	private func addGestures(to: UIView) {
		
	}
	
	private func removeGestures(from: UIView) {
		
	}
	
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
			
			
		}
	}
	
	func reload(localisedView: UIView, inParentView parentView: UIView) {
		
		if let localisableLabel = localisedView as? LocalisableLabel {
			
			let localisationKey = localisableLabel.localisationKey
			localisableLabel.localisationKey = localisationKey
			
		} else if let label = localisedView as? UILabel {
			
			guard let text = label.text, let localisationKey = text.localisationKey else { return }
			
			let newString = text.localised(with: localisationKey)
			label.text = newString
			
			if let button = parentView as? UIButton {
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
	
	//MARK: - Logging in
	//MARK: -
	func askForLogin(completion: TSCStormLoginCompletion?) {
		
		let storyboard = UIStoryboard(name: "Login", bundle: Bundle.init(for: LocalisationController.self))
		let loginViewController = storyboard.instantiateInitialViewController() as! TSCStormLoginViewController
		
		loginViewController.completion = { (success, cancelled) in
			
			self.loginWindow?.isHidden = true
			self.loginWindow = nil
			
			completion?(success, cancelled)
		}
		
		loginWindow = UIWindow(frame: UIScreen.main.bounds)
		loginWindow?.rootViewController = loginViewController
		loginWindow?.windowLevel = UIWindowLevelAlert+1
		loginWindow?.isHidden = false
	}
	
	//MARK: - Fetching/Updating from/with CMS
	//MARK: -
	
	/// Fetches the CMS localisations from the server
	///
	/// - Parameter completion: A closure to be called once the localisations have been fetched
	func fetchLocalisations(completion: LocalisationFetchCompletion?) {
		
	}
	
	/// Saves all edited localisations to the server
	///
	/// - Parameter completion: A closure to be called when the localisations have saved
	func saveEditedLocalisations(completion: LocalisationSaveCompletion?) {
		
	}
	
	/// Fetches the available languages for the app
	///
	/// - Parameter completion: A closure to be called when the languages have been fetched
	func fetchAvailableLanguages(completion: LocalisationFetchLanguageCompletion?) {
		
	}
	
//	/**
//	@abstract Registers a localisation to be saved to CMS. This method adds the TSCLocalisation to self.editedLocalisations if it not already in there.
//	@param localisation The localisations to be registered as edited.
//	*/
//	- (void)registerLocalisationEdited:(Localisation *)localisation;
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
		
	}
	
	//MARK: - Activity View Controllers
	//MARK: -
	
	private var activityIndicatorWindow: UIWindow?
	
	private func showActivityIndicatorWith(title: String) {
		activityIndicatorWindow = UIWindow(frame: UIScreen.main.bounds)
		activityIndicatorWindow?.isHidden = false
		MDCHUDActivityView.start(in: activityIndicatorWindow!, text: title)
	}
	
	private func dismissActivityIndicator() {
		guard let activityIndicatorWindow = activityIndicatorWindow else { return }
		MDCHUDActivityView.finish(in: activityIndicatorWindow)
		self.activityIndicatorWindow = nil
	}
}
