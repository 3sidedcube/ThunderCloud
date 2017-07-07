//
//  Cell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 30/06/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import ThunderTable
import UserNotifications

@objc(TSCEmbeddedLinksListItemCell)
/// `EmbeddedLinksListItemCell` is a `TableViewCell` that supports embedded links. Each link is displayed as a button.
open class EmbeddedLinksListItemCell: StormTableViewCell {
	
	/// An array of `TSCLink`s to be displayed
	private var _links: [(link: AnyObject, available: Bool)]?
	open var links: [AnyObject]? {
		didSet {
			
			guard let uLinks = links else {
				_links = nil
				return
			}
			
			_links = uLinks.flatMap({ (object) -> (link: AnyObject, available: Bool)? in
				
				guard let link = object as? TSCLink else {
					guard let button = object as? UIButton else {
						return nil
					}
					return (button, true)
				}
				
				// Make the phone URL, and check if we can't open it
				if let url = link.url, url.scheme == "tel", let telephoneURL = URL(string: url.absoluteString.replacingOccurrences(of: "tel", with: "telprompt")), (!UIApplication.shared.canOpenURL(telephoneURL) || TSC_isPad()) {
					
					// We can't make a phone-call
					
					if hideUnavailableLinks {
						return nil
					} else {
						return (link, false)
					}
				}
				
				// Create emergency tel:// link, and see if we can open it
				if link.linkClass == "EmergencyLink", let emergencyNumber = UserDefaults.standard.string(forKey: "emergency_number"), let url = URL(string: "tel://\(emergencyNumber)"), (!UIApplication.shared.canOpenURL(url) || TSC_isPad()) {
					
					// We can't make the call
					if hideUnavailableLinks {
						return nil
					} else {
						return (link, false)
					}
				}
				
				return (link, true)
			})
		}
	}
	
	@IBOutlet weak var embeddedLinksStackView: UIStackView!
	
	@IBOutlet weak var mainStackView: UIStackView!
	
	/// A boolean to determine whether unavailable links should be hidden or not
	/// An unavailable link will be something like a call link on a device that can't make calls
	open var hideUnavailableLinks = false
	
	/// A selector which is called on the target when the row is selected
	open var selector: Selector?
	
	/// An object on which to call the selector when the cell is selected
	open var _target: AnyObject?
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open override func layoutSubviews() {
		
		super.layoutSubviews()
		
		guard let _links = links else { return }
		
		if _links.count > 0 {
			selectionStyle = .none
		}
		
		layoutLinks()
	}
	
	open func layoutLinks() {
		
		embeddedLinksStackView.arrangedSubviews.forEach { (view) in
			guard let inlineButtonView = view as? TSCInlineButtonView else { return }
			embeddedLinksStackView.removeArrangedSubview(inlineButtonView)
		}
		
		guard let links = _links, links.count > 0 else {
			embeddedLinksStackView.isHidden = true
			return
		}
		
		embeddedLinksStackView.isHidden = false
		links.forEach { (linkAvailability) in
			
			// self.links can contain both TSCLink objects and UIButton objects
			let link = linkAvailability.link as? TSCLink
			let embeddedButton = linkAvailability.link as? UIButton
			let inlineButton = TSCInlineButtonView()
			
			// If it's a link, then set up the inline button with a link
			if let _link = link {
				inlineButton.link = _link
				inlineButton.setTitle(link?.title, for: .normal)
			} else if let _button = embeddedButton {
				// If it's a UIButton loop through the button's targets
				_button.allTargets.forEach({ (target) in
					
					// For each target get the actions associated with it for touchUpInside
					guard let actions = _button.actions(forTarget: target, forControlEvent: .touchUpInside) else { return }
					// And for each action returned copy it onto our inlineButton
					actions.forEach({ (action) in
						inlineButton.addTarget(target, action: NSSelectorFromString(action), for: .touchUpInside)
					})
				})
			} else {
				// If we're not a TSCLink or UIButton we don't want to show it in our UI
				return
			}
			
			if let target = _target, let _selector = selector, embeddedButton == nil {
				inlineButton.addTarget(target, action: _selector, for: .touchUpInside)
			} else {
				inlineButton.addTarget(self, action: #selector(handleEmbeddedLink(sender:)), for: .touchUpInside)
			}

			inlineButton.layer.borderWidth = 1.0
			let mainColor = ThemeManager.shared.theme.mainColor
			
			if !linkAvailability.available {
				inlineButton.setTitleColor(mainColor.withAlphaComponent(0.2), for: .normal)
				inlineButton.layer.borderColor = mainColor.withAlphaComponent(0.2).cgColor
				inlineButton.isUserInteractionEnabled = false
			} else {
				inlineButton.setTitleColor(mainColor, for: .normal)
				inlineButton.layer.borderColor = mainColor.cgColor
			}
			
			embeddedLinksStackView.addArrangedSubview(inlineButton)
		}
	}
	
	@objc private func handleEmbeddedLink(sender: TSCInlineButtonView) {
		
		if sender.link.linkClass == "TimerLink" {
			handleTimerLink(with: sender)
			return
		}
		
		parentViewController?.navigationController?.push(sender.link)
	}
	
	private func handleTimerLink(with buttonView: TSCInlineButtonView) {
		
		guard let duration = buttonView.link.duration as? TimeInterval else {
			return
		}
		
		// Setup defaults for monitoring timing
		let userDefaults = UserDefaults.standard
		let timingKey = "__storm_CountdownTimer_\(buttonView.link.hash)"
		
		// Aleready running
		if userDefaults.bool(forKey: timingKey) {
			return
		}
		
		// Set the timer as running in the defaults
		userDefaults.set(true, forKey: timingKey)
		
		let bundle = Bundle(for: EmbeddedLinksListItemCell.self)
		let backgroundTrackImage = UIImage(named: "trackImage", in: bundle, compatibleWith: nil)
		let completionOverlayImage = UIImage(named: "progress", in: bundle, compatibleWith: nil)
		
		let progressView = UIImageView(image: completionOverlayImage)
		buttonView.layer.masksToBounds = true
		
		UIView.transition(with: buttonView, duration: 0.15, options: .transitionCrossDissolve, animations: { 
			buttonView.setBackgroundImage(backgroundTrackImage, for: .normal)
		}, completion: nil)
		
		buttonView.addSubview(progressView)
		buttonView.sendSubview(toBack: progressView)
		
		let initialData: [AnyHashable : Any] = [
			"progressView": progressView,
			"button": buttonView,
			"timeRemaining": duration,
			"timeLimit": duration,
			"link": buttonView.link
		]
		
		Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(updateTimerLink(timer:)), userInfo: initialData, repeats: false)
	}
	
	@objc private func updateTimerLink(timer: Timer) {
		
		// Retrieve data from the timer
		guard let userData = timer.userInfo as? [AnyHashable : Any], var timeRemaining = userData["timeRemaining"] as? TimeInterval, let timeLimit = userData["timeLimit"] as? TimeInterval, let progressView = userData["progressView"] as? UIImageView, let button = userData["button"] as? TSCInlineButtonView, let link = userData["link"] as? TSCLink else {
			return
		}
		
		if timeRemaining == 0 {
			
			if let borderColor = button.layer.borderColor {
				button.setTitleColor(UIColor(cgColor: borderColor), for: .normal)
			}
			timer.invalidate()
			
			let timerKey = "__storm_CountdownTimer_\(link.hash)"
			
			if #available(iOS 10.0, *) {
				
				let notificationContent = UNMutableNotificationContent()
				notificationContent.body = "Countdown complete".localised(with: "_STORM_TIMER_COMPLETE_BODY")
				let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)
				let notification = UNNotificationRequest(identifier: timerKey, content: notificationContent, trigger: trigger)
				
				UNUserNotificationCenter.current().add(notification, withCompletionHandler: nil)
				
			} else {
				
				let localNotification = UILocalNotification()
				localNotification.alertBody = "Countdown complete"
				UIApplication.shared.presentLocalNotificationNow(localNotification)
			}
			
			UIView.transition(with: button, duration: 0.15, options: .transitionCrossDissolve, animations: { 
				progressView.removeFromSuperview()
				button.setTitle("Start Timer".localised(with: "_STORM_TIMER_START_TITLE"), for: .normal)
			}, completion: nil)
			
			UserDefaults.standard.set(false, forKey: timerKey)
			
			return
		}
		
		// Update progress of track image
		let mins = floor(timeRemaining/60)
		let secs = round(timeRemaining - mins/60)
		
		button.setTitle("\(Int(mins)):\(Int(secs))", for: .normal)
		
		let width = button.frame.width * CGFloat((timeLimit - timeRemaining) / timeLimit)
		progressView.frame = CGRect(x: 0, y: 0, width: width, height: button.frame.size.height)
		
		if let titleLabel = button.titleLabel, width >= titleLabel.frame.origin.x {
			button.setTitleColor(.black, for: .normal)
		}
		
		timeRemaining = timeRemaining - 1
		
		let data: [AnyHashable : Any] = [
			"progressView": progressView,
			"button": button,
			"timeRemaining": timeRemaining,
			"timeLimit": timeLimit,
			"link": link
		]
		Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerLink(timer:)), userInfo: data, repeats: false)
	}
}
