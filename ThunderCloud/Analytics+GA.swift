//
//  Analytics+GA.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 26/06/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

/// A structural representation of a google analytics event
public struct GAEvent {
    
    /// The category of the event
    public let category: String
    
    /// The action that occured
    public let action: String?
    
    /// The label of the action
    public let label: String?
    
    /// The value of the event
    public let value: NSNumber?
    
    /// Creates a new GAEvent with the provided parameters
    ///
    /// - Parameters:
    ///   - category: The category of the event
    ///   - action: The action that occurred
    ///   - label: A label to apply to the event
    ///   - value: The value associated with the event
    public init(
        category: String,
        action: String?,
        label: String?,
        value: NSNumber?
    ) {
        self.category = category
        self.action = action
        self.label = label
        self.value = value
    }
    
    /// Initialises a `GAEvent` from a storm standard analytics event
    ///
    /// - Parameter event: The analytics event that occurred
    public init?(_ event: Analytics.Event) {
        
        switch event {
        case .pokemonListItemClick(let item):
            category = "Collect them all"
            action = item.isInstalled ? "Open" : "App Store"
            label = nil
            value = nil
        case .switchLanguage(let pack):
            category = "Language Switching"
            action = "Switch to \(pack.fileName)"
            label = nil
            value = nil
        case .videoPlay(let link):
            category = "Video"
            label = nil
            value = nil
            switch link.linkClass {
            case .external:
                action = "YouTube - \(link.url?.absoluteString ?? "Unknown")"
            case .internal:
                action = "Local - \(link.title ?? "Unknown")"
            default:
                action = nil
                break
            }
        case .call(let numberURL):
            category = "Call"
            action = numberURL.absoluteString
            label = nil
            value = nil
        case .visitURL(let link):
            category = "Visit URL"
            action = link.url?.absoluteString
            label = nil
            value = nil
        case .sms(let recipients, _):
            category = "SMS"
            action = recipients.joined(separator: ",")
            label = nil
            value = nil
        case .shareApp(let activityType, let success):
            // Old analytics setup required the user to finish sharing to send this event
            guard success else { return nil }
            category = "App"
            action = "Share to \(activityType?.rawValue ?? "Unknown")"
            label = nil
            value = nil
        case .emergencyCall(let number):
            category = "Call"
            action = "Custom Emergency Number"
            label = number
            value = nil
        case .spotlightClick(let spotlight):
            category = "Spotlight"
            action = spotlight.link?.url?.absoluteString ?? "Unknown"
            label = nil
            value = nil
        case .appCollectionClick(let appId):
            category = "Collect them all"
            if let launchURL = appId.launchURL, UIApplication.shared.canOpenURL(launchURL) {
                action = "Open"
            } else {
                action = "App Store"
            }
            label = nil
            value = nil
        case .badgeUnlock(_, let earnedBadges):
            category = "Badges"
            action = "\(earnedBadges) of \(BadgeController.shared.badges?.count ?? -1)"
            label = nil
            value = nil
        case .badgeShare(let badge, _):
            category = "Badge"
            action = "Shared \(badge.title ?? "Unknown") badge"
            label = nil
            value = nil
        case .testSelectImageAnswer(_, _, let answer), .testSelectTextAnswer(_, _, let answer):
            category = "Quiz"
            action = "Select Answer"
            label = "\(answer)"
            value = nil
        case .testDeselectImageAnswer(_, _, let answer), .testDeselectTextAnswer(_, _, let answer):
            category = "Quiz"
            action = "Deselect Answer"
            label = "\(answer)"
            value = nil
        case .testWin(let quiz):
            category = "Quiz"
            action = "Won \(quiz.title ?? "Unknown") badge"
            label = nil
            value = nil
        case .testLose(let quiz):
            category = "Quiz"
            action = "Lost \(quiz.title ?? "Unknown") badge"
            label = nil
            value = nil
        case .testReattempt(let quiz):
            category = "Quiz"
            action = "Try again - \(quiz.title ?? "Unknown")"
            label = nil
            value = nil
        case .testShare(let quiz, let activityType, let shared):
            // Old analytics setup required the user to finish sharing to send this event
            guard shared else { return nil }
            category = "Quiz"
            action = "Share \(quiz.title ?? "Unknown") to \(activityType?.rawValue ?? "Unknown")"
            label = nil
            value = nil
        case .testStart(let quiz):
            category = "Quiz"
            action = "Start \(quiz.title ?? "Unknown") quiz"
            label = nil
            value = nil
        default:
            return nil
        }
    }
}
