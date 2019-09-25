//
//  Analytics+Firebase.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 27/06/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

public extension String {
    /// Makes a string safe for firebase
    ///
    /// Changes to contain 1 to 40 alphanumeric characters or underscores, and to start with an alphabetic character.
    var firebaseSafe: String {
        
        // Change all whitespace characters and new line characters to spaces
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        let allowedSet = CharacterSet.alphanumerics
        let whitespaceCondensedSelf = components.filter { !$0.isEmpty }.joined(separator: " ").trimmingCharacters(in: allowedSet.inverted)
        
        
        // Remove any spaces or hyphens and replace with underscore
        let spaceStrings: [Character] = [" ", "-", "–", "—", "+", "."]
        
        var firebaseString = String(whitespaceCondensedSelf.enumerated().compactMap { (index, element) -> Character? in
            if spaceStrings.contains(element) {
                return "_"
            }
            guard element.isLetter || element.isNumber || element == "_" else {
                return nil
            }
            return element
        }).lowercased()
        
        // Trim any `_` as the string must start with alphanumeric
        firebaseString = firebaseString.trimmingCharacters(in: CharacterSet(charactersIn: "_"))
        
        // Only return first 40 characters as this is all firebase supports!
        return String(firebaseString.prefix(40))
    }
}

fileprivate extension Bool {
    /// Converts to a readable string for use as a firebase parameter
    var firebaseValue: String {
        return self ? "true" : "false"
    }
}

/// A structural representation of a firebase analytics event
public struct FirebaseEvent {
    
    /// The event name, must be < 40 alphanumerical characters (or '_') and start with an alphabetical character.
    public let event: String
    
    /// The event parameters, values must be `String` or `NSNumber`, keys must be < 40 alphanumerical characters (or '_') and start with an alphabetical character.
    public let parameters: [String : Any]
    
    /// Initialises a new Firebase event with the given parameters
    ///
    /// - Parameters:
    ///   - event: The event that occured
    ///   - parameters: Parameters to send with the event
    public init(event: String, parameters: [String : Any] = [:]) {
        self.event = event
        self.parameters = parameters
    }
    
    /// Initialises a `FirebaseEvent` from a storm standard analytics event
    ///
    /// - Parameter event: The analytics event that occurred
    public init?(_ analyticsEvent: Analytics.Event) {
        
        switch analyticsEvent {
        case .appLink(let link, let appId):
            event = "appLink"
            parameters = [
                "installed": (appId.launchURL != nil && UIApplication.shared.canOpenURL(appId.launchURL!)).firebaseValue,
                "name": link.identifier ?? appId.identifier ?? appId.name ?? "unknown"
            ]
        case .pokemonListItemClick(let item):
            event = "appCollectionClick"
            parameters = [
                "installed": item.isInstalled.firebaseValue,
                "name": item.name ?? "unknown"
            ]
        case .appCollectionClick(let item):
            event = "appCollectionClick"
            parameters = [
                "installed": (item.launchURL != nil && UIApplication.shared.canOpenURL(item.launchURL!)).firebaseValue,
                "name": item.name ?? "unknown"
            ]
        case .videoPlay(let link):
            event = "videoPlay"
            parameters = [
                "local": (link.linkClass == .internal).firebaseValue,
                "name": link.title ?? "unknown",
                "url": link.url?.absoluteString ?? "unknown"
            ]
        case .testStart(let quiz):
            event = "testStart"
            parameters = [
                "name": quiz.title ?? "unknown",
                "id": quiz.id ?? "unknown"
            ]
        case .testWin(let quiz):
            event = "testWin"
            parameters = [
                "name": quiz.title ?? "unknown",
                "id": quiz.id ?? "unknown"
            ]
        case .testLose(let quiz):
            event = "testLose"
            parameters = [
                "name": quiz.title ?? "unknown",
                "id": quiz.id ?? "unknown",
                "correct": NSNumber(value: quiz.questions?.filter({ $0.isCorrect }).count ?? 0),
                "incorrect": NSNumber(value: quiz.questions?.filter({ !$0.isCorrect }).count ?? 0)
            ]
        case .testReattempt(let quiz):
            event = "testReattempt"
            parameters = [
                "name": quiz.title ?? "unknown",
                "id": quiz.id ?? "unknown"
            ]
        case .testSelectImageAnswer(let quiz, let question, let option):
            event = "testSelectImageAnswer"
            parameters = [
                "quiz_name": quiz?.title ?? "unknown",
                "quiz_id": quiz?.id ?? "unknown",
                "answer": NSNumber(value: option),
                "question": NSNumber(value: quiz?.questions?.firstIndex(where: { $0.questionNumber == question.questionNumber }) ?? 0)
            ]
        case .testDeselectImageAnswer(let quiz, let question, let option):
            event = "testDeselectImageAnswer"
            parameters = [
                "quiz_name": quiz?.title ?? "unknown",
                "quiz_id": quiz?.id ?? "unknown",
                "answer": NSNumber(value: option),
                "question": NSNumber(value: quiz?.questions?.firstIndex(where: { $0.questionNumber == question.questionNumber }) ?? 0)
            ]
        case .testSelectTextAnswer(let quiz, let question, let option):
            event = "testSelectTextAnswer"
            parameters = [
                "quiz_name": quiz?.title ?? "unknown",
                "quiz_id": quiz?.id ?? "unknown",
                "answer": NSNumber(value: option),
                "question": NSNumber(value: quiz?.questions?.firstIndex(where: { $0.questionNumber == question.questionNumber }) ?? 0)
            ]
        case .testDeselectTextAnswer(let quiz, let question, let option):
            event = "testDeselectTextAnswer"
            parameters = [
                "quiz_name": quiz?.title ?? "unknown",
                "quiz_id": quiz?.id ?? "unknown",
                "answer": NSNumber(value: option),
                "question": NSNumber(value: quiz?.questions?.firstIndex(where: { $0.questionNumber == question.questionNumber }) ?? 0)
            ]
        case .badgeShare(let badge, let shareInfo):
            event = "badgeShare"
            parameters = [
                "name": badge.title ?? "unknown",
                "id": badge.id ?? "unknown",
                "from": shareInfo.from,
                "destination": shareInfo.destination?.rawValue ?? "unknown",
                "complete": shareInfo.shared.firebaseValue
            ]
        case .testShare(let quiz, let activity, let shared):
            event = "badgeShare"
            parameters = [
                "name": quiz.badge?.title ?? quiz.title ?? "unknown",
                "id": quiz.badge?.id ?? "unknown",
                "from": "quizcompletion",
                "destination": activity?.rawValue ?? "unknown",
                "complete": shared.firebaseValue
            ]
        case .visitURL(let link):
            event = "visitURL"
            parameters = [
                "url": link.url?.absoluteString ?? "unknown",
                "internal": (link.linkClass != .uri).firebaseValue
            ]
        case .call(let url):
            event = "call"
            parameters = [
                "number": url.host ?? "unknown"
            ]
        case .sms(let recipients, let body):
            event = "sms"
            parameters = [
                "recipients": recipients.joined(separator: ", "),
                "body": body ?? ""
            ]
        case .emergencyCall(let number):
            event = "emergencyCall"
            parameters = [
                "number": number ?? "unknown"
            ]
        case .shareApp(let activity, let shared):
            event = "shareApp"
            parameters = [
                "destination": activity?.rawValue ?? "unknown",
                "complete": shared.firebaseValue
            ]
        case .spotlightClick(let spotlight):
            event = "spotlightClick"
            parameters = [
                "url": spotlight.link?.url?.absoluteString ?? "unknown"
            ]
        case .badgeUnlock(let badge, let unlocked):
            event = "earnBadge"
            parameters = [
                "total": NSNumber(value: BadgeController.shared.badges?.count ?? 0),
                "earnt": NSNumber(value: unlocked),
                "id": badge.id ?? "unknown",
                "name": badge.title ?? "unknown"
            ]
        case .switchLanguage(let language):
            event = "switchLanguage"
            parameters = [
                "language": language.fileName,
                "locale_id": language.locale.identifier
            ]
        default:
            return nil
        }
    }
}
