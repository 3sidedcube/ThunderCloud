//
//  Analytics.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

public extension NotificationCenter {
    
    /// Call this function to send an analytics event using `NotificationCenter`
    /// which can be consumed by a user of the `ThunderCloud` framework
    ///
    /// - Parameter event: The analytics event that occured
    func sendAnalyticsHook(_ event: Analytics.Event) {
        NotificationCenter.default.post(
            name: .analyticsHook,
            object: nil,
            userInfo: [
                Analytics.NotificationEventKey: event
            ]
        )
    }
    
    /// Call this function to send a screen view event using `NotificationCenter`
    /// which can be consumed by a user of the `ThunderCloud` framework
    ///
    /// - Parameter screenView: The analytics event that occured
    func sendAnalyticsScreenView(_ screenView: Analytics.ScreenView) {
        NotificationCenter.default.post(
            name: .analyticsHook,
            object: nil,
            userInfo: [
                Analytics.NotificationScreenViewKey: screenView
            ]
        )
    }
}

/// A container struct for typealiasing of analytics events
public struct Analytics {

    static let NotificationEventKey = "event"
    
    static let NotificationScreenViewKey = "screenView"
    
    /// A structural representation of a screen view
    public struct ScreenView {
        
        /// The screen name of the screen that was viewed
        public let screenName: String?
        
        /// The navigation stack which the screen was viewed in
        public let navigationController: UINavigationController?
        
        /// Initialiser for a screen view with given parameters
        ///
        /// - Parameters:
        ///   - screenName: The name of the screen that was viewed
        ///   - navigationController: The current navigation stack when the screen was viewed
        public init(screenName: String?, navigationController: UINavigationController?) {
            self.screenName = screenName
            self.navigationController = navigationController
        }
    }
    
    /// An enum representation of Storm analytic events
    ///
    /// - appLink: An app link was opened by the user. Sends the `AppIdentity` and `StormLink` which was selected.
    /// - appCollectionClick: An app was clicked within an app collection list item. Sends the `AppIdentity` which was selected.
    /// - badgeShare: A badge was shared from somewhere in the app. Sends the badge, and information about where from and to the badge was shared.
    /// - badgeUnlock: A badge was unlocked by the user. Sends the badge, and the number of badges the user has unlocked (Post unlock).
    /// - call: A call link was clicked by the user. Sends the url which was called.
    /// - custom: A custom event happened. This is best utilised when consumers of this library want to send their own events.
    /// - emergencyCall: An emergency call link was clicked by the user. Sends the number which was called.
    /// - pokemonListItemClick: An app was clicked within a pokemon list item. Sends the `PokemonListItem` which was selected.
    /// - shareApp: The app was shared by the user. Sends the activity type it was shared to and whether the share was completed or cancelled.
    /// - sms: An SMS link was clicked by the user. Sends the list of recipients and body of the message.
    /// - spotlightClick: A spotlight was clicked by the user. Sends the spotlight which was clicked.
    /// - switchLanguage: The user completed a language switch. Sends the language that the user switched to.
    /// - testLose: A quiz was completed incorrectly. Sends the quiz the user finished.
    /// - testShare: A badge was shared from the quiz completion screen. Sends the quiz, where the user shared to and whether they completed sharing it.
    /// - testStart: A quiz was begun. Sends the quiz.
    /// - testReattempt: A quiz was restarted from the quiz failure screen. Sends the quiz that was restarted.
    /// - testWin: A quiz was completed sucessfully. Sends the quiz.
    /// - testSelectImageAnswer: An answer was selected on an image select question in a quiz. Sends the quiz, the question which was selected and the index of that answer.
    /// - testDeselectImageAnswer: An answer was deselected on an image select question in a quiz. Sends the quiz, the question which was selected and the index of that answer.
    /// - testSelectTextAnswer: An answer was selected on a text select question in a quiz. Sends the quiz, the question which was selected and the index of that answer.
    /// - testDeselectTextAnswer: An answer was deselected on a text select question in a quiz. Sends the quiz, the question which was selected and the index of that answer.
    /// - videoPlay: A video began playing. Sends the link to the video.
    /// - visitURL: A url was visited. Sends the link of the url.
    public enum Event {
        case appLink(StormLink, AppIdentity)
        case appCollectionClick(AppIdentity)
        case badgeShare(Badge, (from: String, destination: UIActivity.ActivityType?, shared: Bool))
        case badgeUnlock(Badge, Int)
        case call(URL)
        case custom(String, [AnyHashable : Any])
        case emergencyCall(String?)
        case pokemonListItemClick(PokemonListItem)
        case shareApp(UIActivity.ActivityType?, Bool)
        case sms([String], String?)
        case spotlightClick(SpotlightObjectProtocol)
        case switchLanguage(LanguagePack)
        case testLose(Quiz)
        case testShare(Quiz, UIActivity.ActivityType?, Bool)
        case testStart(Quiz)
        case testReattempt(Quiz)
        case testWin(Quiz)
        case testSelectImageAnswer(Quiz?, ImageSelectionQuestion, Int)
        case testDeselectImageAnswer(Quiz?, ImageSelectionQuestion, Int)
        case testSelectTextAnswer(Quiz?, TextSelectionQuestion, Int)
        case testDeselectTextAnswer(Quiz?, TextSelectionQuestion, Int)
        case videoPlay(StormLink)
        case visitURL(StormLink)
    }
}

public extension NSNotification.Name {
    /// Used to listen for analytics hooks sent by the `ThunderCloud` library. These will either have a non-nil `Notification.analyticsEvent` or `Notification.screenView` which can be used to send analytics to an analytics SDK or API.
    static let analyticsHook = NSNotification.Name.init("TSCAnalyticsHookNotification")
}

public extension Notification {
    
    /// The analytics event which triggered this `Notification`
    var analyticsEvent: Analytics.Event? {
        return userInfo?[Analytics.NotificationEventKey] as? Analytics.Event
    }
    
    /// The screen view which triggered this `Notification`
    var screenView: Analytics.ScreenView? {
        return userInfo?[Analytics.NotificationScreenViewKey] as? Analytics.ScreenView
    }
}
