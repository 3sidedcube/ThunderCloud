//
//  Cell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 30/06/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable
import UserNotifications

/// `EmbeddedLinksListItemCell` is a `TableViewCell` that supports embedded links. Each link is displayed as a button.
open class EmbeddedLinksListItemCell: StormTableViewCell {
    
    @IBOutlet open weak var contentStackView: UIStackView!
    
    /// An array of `TSCLink`s to be displayed
    private var _links: [(link: AnyObject, available: Bool)]?
    open var links: [AnyObject]? {
        didSet {
            
            defer {
                if embeddedLinksStackView != nil {
                    layoutLinks()
                }
            }
            
            guard let uLinks = links else {
                _links = nil
                return
            }
            
            _links = uLinks.compactMap({ (object) -> (link: AnyObject, available: Bool)? in
                
                guard let link = object as? StormLink else {
                    guard let button = object as? UIButton else {
                        return nil
                    }
                    return (button, true)
                }
                
                // Make the phone URL, and check if we can't open it
                if let url = link.url, url.scheme == "tel", let telephoneURL = URL(string: url.absoluteString.replacingOccurrences(of: "tel", with: "telprompt")), (!UIApplication.shared.canOpenURL(telephoneURL) || UI_USER_INTERFACE_IDIOM() == .pad) {
                    
                    // We can't make a phone-call
                    
                    if hideUnavailableLinks {
                        return nil
                    } else {
                        return (link, false)
                    }
                }
                
                // Create emergency tel:// link, and see if we can open it
                if link.linkClass == .emergency, let emergencyNumber = UserDefaults.standard.string(forKey: "emergency_number"), let url = URL(string: "tel://\(emergencyNumber)"), (!UIApplication.shared.canOpenURL(url) || UI_USER_INTERFACE_IDIOM() == .pad) {
                    
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
    
    @IBOutlet public weak var embeddedLinksStackView: UIStackView!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    /// A boolean to determine whether unavailable links should be hidden or not
    /// An unavailable link will be something like a call link on a device that can't make calls
    open var hideUnavailableLinks = false
    
    /// A selector which is called on the target when the row is selected
    open var selector: Selector?
    
    /// An object on which to call the selector when the cell is selected
    open var _target: AnyObject?
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        guard let links = links else { return }
        
        if links.count > 0 {
            selectionStyle = .none
        }
    }
    
    open func layoutLinks() {
        
        embeddedLinksStackView?.arrangedSubviews.forEach { (view) in
            guard let inlineButtonView = view as? InlineButtonView else { return }
            embeddedLinksStackView.removeArrangedSubview(inlineButtonView)
            inlineButtonView.removeFromSuperview()
        }
        
        guard let _links = _links, _links.count > 0 else {
            embeddedLinksStackView.isHidden = true
            return
        }
        
        embeddedLinksStackView.isHidden = false
        _links.forEach { (linkAvailability) in
            
            // self.links can contain both TSCLink objects and UIButton objects
            let link = linkAvailability.link as? StormLink
            let embeddedButton = linkAvailability.link as? UIButton
            let inlineButtonViewClass: InlineButtonView.Type = StormObjectFactory.shared.class(for: String(describing: InlineButtonView.self)) as? InlineButtonView.Type ?? InlineButtonView.self
            let inlineButton = inlineButtonViewClass.init()
            
            // If it's a link, then set up the inline button with a link
            if let _link = link {
                inlineButton.link = _link
                inlineButton.setTitle(link?.title, for: .normal)
                if _link.linkClass == .timer {
                    // Check if we need to restart the timer (If it's already running)
                    updateTimerLink(with: inlineButton)
                }
            } else if let button = embeddedButton {
                // If it's a UIButton loop through the button's targets
                button.allTargets.forEach({ (target) in
                    
                    // For each target get the actions associated with it for touchUpInside
                    guard let actions = button.actions(forTarget: target, forControlEvent: .touchUpInside) else { return }
                    // And for each action returned copy it onto our inlineButton
                    actions.forEach({ (action) in
                        inlineButton.addTarget(target, action: NSSelectorFromString(action), for: .touchUpInside)
                    })
                })
            } else {
                // If we're not a TSCLink or UIButton we don't want to show it in our UI
                return
            }
            
            if let target = _target, let selector = selector, embeddedButton == nil {
                inlineButton.addTarget(target, action: selector, for: .touchUpInside)
            } else {
                inlineButton.addTarget(self, action: #selector(handleEmbeddedLink(sender:)), for: .touchUpInside)
            }
            
            inlineButton.isAvailable = linkAvailability.available
            
            embeddedLinksStackView.addArrangedSubview(inlineButton)
        }
    }
    
    @objc private func handleEmbeddedLink(sender: InlineButtonView) {
        
        guard let link = sender.link else { return }
        
        if link.linkClass == .timer {
            handleTimerLink(with: sender)
            return
        }
        
        parentViewController?.navigationController?.push(link: link)
    }
    
    private var timerTimer: Timer?
    
    private func updateTimerLink(with buttonView: InlineButtonView) {
        
        guard let link = buttonView.link else {
            return
        }
        
        // Setup defaults for monitoring timing
        let userDefaults = UserDefaults.standard
        let timingKey = "__storm_CountdownTimer_\(link.id ?? ObjectIdentifier(link).hashValue)"
        
        // If we have a date in UserDefaults for this timer, then it's running
        if let startDateString = userDefaults.string(forKey: timingKey), let startDate = Date(ISO8601String: startDateString) {
            // startDate is always in
            let timeSinceStartedTimer = Date().timeIntervalSince(startDate)
            if timeSinceStartedTimer < (link.duration ?? 0) {
                updateTimerLink(link, button: buttonView, remaining: (link.duration ?? 0) - timeSinceStartedTimer, timeLimit: link.duration ?? 0)
            } else {
                // Otherwise nil the date in the user defaults
                userDefaults.set(nil, forKey: timingKey)
                buttonView.stopTimer()
                cancelTimerNotificationFor(link: link)
            }
        } else {
            // Redraw to non-running state just incase (re-use e.t.c)
            buttonView.stopTimer()
            cancelTimerNotificationFor(link: link)
        }
    }
    
    private func handleTimerLink(with buttonView: InlineButtonView) {
        
        guard let link = buttonView.link, let duration = link.duration else {
            return
        }
        
        // Setup defaults for monitoring timing
        let userDefaults = UserDefaults.standard
        let timingKey = "__storm_CountdownTimer_\(link.id ?? ObjectIdentifier(link).hashValue)"
        
        // Already running
        if userDefaults.string(forKey: timingKey) != nil {
            timerTimer?.invalidate()
            timerTimer = nil
            buttonView.stopTimer()
            userDefaults.set(nil, forKey: timingKey)
            cancelTimerNotificationFor(link: link)
            return
        }
        
        scheduleTimerNotificationFor(link: link)
        
        // Set the timer as running in the defaults
        userDefaults.set(Date().ISO8601String(withLocale: true), forKey: timingKey)
        
        let initialData: [AnyHashable : Any] = [
            "button": buttonView,
            "timeRemaining": duration,
            "timeLimit": duration,
            "link": link
        ]
        buttonView.startTimer()
        
        timerTimer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(updateTimerLink(timer:)), userInfo: initialData, repeats: false)
    }
    
    @objc private func updateTimerLink(timer: Timer) {
        
        // Retrieve data from the timer
        guard let userData = timer.userInfo as? [AnyHashable : Any], let timeRemaining = userData["timeRemaining"] as? TimeInterval, let timeLimit = userData["timeLimit"] as? TimeInterval, let button = userData["button"] as? InlineButtonView, let link = userData["link"] as? StormLink else {
            return
        }
        
        // Update link UI and logic
        updateTimerLink(link, button: button, remaining: timeRemaining, timeLimit: timeLimit)
    }
    
    private func updateTimerLink(_ link: StormLink, button: InlineButtonView, remaining timeRemaining: TimeInterval, timeLimit: TimeInterval) {
        
        button.setTimeRemaining(timeRemaining, totalCountdown: timeLimit)
        
        let timerKey = "__storm_CountdownTimer_\(link.id ?? ObjectIdentifier(link).hashValue)"
        
        // If timer is finished
        if timeRemaining == 0 {
            
            // Stop the NSTimer
            timerTimer?.invalidate()
            timerTimer = nil
            
            // Remove timer start date from user defaults
            UserDefaults.standard.set(nil, forKey: timerKey)
            
            return
        }
        
        // Trigger again with new data in 1 second
        let remaining = timeRemaining - 1
        
        let data: [AnyHashable : Any] = [
            "button": button,
            "timeRemaining": remaining,
            "timeLimit": timeLimit,
            "link": link
        ]
        
        timerTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerLink(timer:)), userInfo: data, repeats: false)
    }
    
    private func scheduleTimerNotificationFor(link: StormLink) {
        
        guard let duration = link.duration, duration > 0 else { return }
        
        let timingKey = "__storm_CountdownTimer_\(link.id ?? ObjectIdentifier(link).hashValue)"
        
        // Send notification letting user know their timer has finished
        let notificationContent = UNMutableNotificationContent()
        notificationContent.body = "Countdown complete".localised(with: "_STORM_TIMER_COMPLETE_BODY")
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let notification = UNNotificationRequest(identifier: timingKey, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(notification, withCompletionHandler: nil)
    }
    
    private func cancelTimerNotificationFor(link: StormLink) {
        
        let timingKey = "__storm_CountdownTimer_\(link.id ?? ObjectIdentifier(link).hashValue)"
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [timingKey])
    }
}
