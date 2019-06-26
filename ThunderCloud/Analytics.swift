//
//  Analytics.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

public extension NotificationCenter {
    
    func sendAnalyticsHook(_ event: Analytics.Event) {
        NotificationCenter.default.post(
            name: .analyticsHook,
            object: nil,
            userInfo: [
                Analytics.NotificationEventKey: event
            ]
        )
    }
    
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

public struct Analytics {

    static let NotificationEventKey = "event"
    
    static let NotificationScreenViewKey = "screenView"
    
    public struct ScreenView {
        
        let screenName: String
        
        let navigationController: UINavigationController?
    }
    
    public enum Event {
        case appCollectionClick(AppIdentity)
        case badgeShare(Badge, (from: String, destination: UIActivity.ActivityType?, shared: Bool))
        case badgeUnlock(Badge, Int)
        case call(String)
        case custom(String, [AnyHashable : Any])
        case emergencyCall(String?)
        case pokemonListItemClick(PokemonListItem)
        case shareApp(UIActivity.ActivityType?, Bool)
        case sms([String])
        case spotlightClick(Spotlight)
        case switchLanguage(LanguagePack)
        case testLose(Quiz)
        case testShare(Quiz, UIActivity.ActivityType?, Bool)
        case testStart(Quiz)
        case testRestart(Quiz)
        case testWin(Quiz)
        case testSelectImageAnswer(Quiz?, ImageSelectionQuestion, (answer: Int, screenName: String))
        case testDeselectImageAnswer(Quiz?, ImageSelectionQuestion, (answer: Int, screenName: String))
        case testSelectTextAnswer(Quiz?, TextSelectionQuestion, (answer: Int, screenName: String))
        case testDeselectTextAnswer(Quiz?, TextSelectionQuestion, (answer: Int, screenName: String))
        case videoPlay(StormLink)
        case visitURL(StormLink)
    }
}

public extension NSNotification.Name {
    static let analyticsHook = NSNotification.Name.init("TSCAnalyticsHookNotification")
}

public extension Notification {
    
    var analyticsEvent: Analytics.Event? {
        return userInfo?[Analytics.NotificationEventKey] as? Analytics.Event
    }
    
    var screenView: Analytics.ScreenView? {
        return userInfo?[Analytics.NotificationScreenViewKey] as? Analytics.ScreenView
    }
}
