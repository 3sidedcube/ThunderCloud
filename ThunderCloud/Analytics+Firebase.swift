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
        case .pokemonListItemClick(let item):
            event = "appCollectionClick"
            parameters = [
                "installed": NSNumber(booleanLiteral: item.isInstalled),
                "name": item.name?.firebaseSafe ?? "unknown"
            ]
        case .appCollectionClick(let item):
            event = "appCollectionClick"
            parameters = [
                "installed": item.launchURL != nil && UIApplication.shared.canOpenURL(item.launchURL!),
                "name": item.name?.firebaseSafe ?? "unknown"
            ]
        case .videoPlay(let link):
            event = "videoPlay"
            parameters = [
                "local": NSNumber(booleanLiteral: link.linkClass == .internal),
                "name": link.title?.firebaseSafe ?? "unknown",
                "url": link.url?.absoluteString.firebaseSafe ?? "unknown"
            ]
        case .testStart(let quiz):
            event = "testStart"
            parameters = [
                "name": quiz.title?.firebaseSafe ?? "unknown",
                "id": quiz.id?.firebaseSafe ?? "unknown"
            ]
        case .testWin(let quiz):
            event = "testWin"
            parameters = [
                "name": quiz.title?.firebaseSafe ?? "unknown",
                "id": quiz.id?.firebaseSafe ?? "unknown"
            ]
        case .testLose(let quiz):
            event = "testLose"
            parameters = [
                "name": quiz.title?.firebaseSafe ?? "unknown",
                "id": quiz.id?.firebaseSafe ?? "unknown",
                "correct": NSNumber(value: quiz.questions?.filter({ $0.isCorrect }).count ?? 0),
                "incorrect": NSNumber(value: quiz.questions?.filter({ !$0.isCorrect }).count ?? 0)
            ]
        case .testReattempt(let quiz):
            event = "testReattempt"
            parameters = [
                "name": quiz.title?.firebaseSafe ?? "unknown",
                "id": quiz.id?.firebaseSafe ?? "unknown"
            ]
        case .testSelectImageAnswer(let quiz, let question, let option):
            event = "testSelectImageAnswer"
            parameters = [
                "quiz_name": quiz?.title?.firebaseSafe ?? "unknown",
                "quiz_id": quiz?.id?.firebaseSafe ?? "unknown",
                "answer": NSNumber(value: option),
                "question": NSNumber(value: quiz?.questions?.firstIndex(where: { $0.questionNumber == question.questionNumber }) ?? 0)
            ]
        case .testDeselectImageAnswer(let quiz, let question, let option):
            event = "testDeselectImageAnswer"
            parameters = [
                "quiz_name": quiz?.title?.firebaseSafe ?? "unknown",
                "quiz_id": quiz?.id?.firebaseSafe ?? "unknown",
                "answer": NSNumber(value: option),
                "question": NSNumber(value: quiz?.questions?.firstIndex(where: { $0.questionNumber == question.questionNumber }) ?? 0)
            ]
        case .testSelectTextAnswer(let quiz, let question, let option):
            event = "testSelectTextAnswer"
            parameters = [
                "quiz_name": quiz?.title?.firebaseSafe ?? "unknown",
                "quiz_id": quiz?.id?.firebaseSafe ?? "unknown",
                "answer": NSNumber(value: option),
                "question": NSNumber(value: quiz?.questions?.firstIndex(where: { $0.questionNumber == question.questionNumber }) ?? 0)
            ]
        case .testDeselectTextAnswer(let quiz, let question, let option):
            event = "testDeselectTextAnswer"
            parameters = [
                "quiz_name": quiz?.title?.firebaseSafe ?? "unknown",
                "quiz_id": quiz?.id?.firebaseSafe ?? "unknown",
                "answer": NSNumber(value: option),
                "question": NSNumber(value: quiz?.questions?.firstIndex(where: { $0.questionNumber == question.questionNumber }) ?? 0)
            ]
        case .badgeShare(let badge, let shareInfo):
            event = "badgeShare"
            parameters = [
                "name": badge.title?.firebaseSafe ?? "unknown",
                "id": badge.id?.firebaseSafe ?? "unknown",
                "from": shareInfo.from.firebaseSafe,
                "destination": shareInfo.destination?.rawValue.firebaseSafe ?? "unknown",
                "complete": NSNumber(value: shareInfo.shared)
            ]
        case .testShare(let quiz, let activity, let shared):
            event = "badgeShare"
            parameters = [
                "name": (quiz.badge?.title ?? quiz.title ?? "unknown").firebaseSafe,
                "id": quiz.badge?.id?.firebaseSafe ?? "unknown",
                "from": "quizcompletion",
                "destination": activity?.rawValue.firebaseSafe ?? "unknown",
                "complete": NSNumber(value: shared)
            ]
        case .visitURL(let link):
            event = "visitURL"
            parameters = [
                "url": link.url?.absoluteString.firebaseSafe ?? "unknown",
                "internal": NSNumber(value: link.linkClass != .uri)
            ]
        case .call(let url):
            event = "call"
            parameters = [
                "number": url.lastPathComponent.firebaseSafe
            ]
        case .sms(let recipients, let body):
            event = "sms"
            parameters = [
                "recipients": recipients.joined(separator: "_").firebaseSafe,
                "body": body?.firebaseSafe ?? ""
            ]
        case .emergencyCall(let number):
            event = "emergencyCall"
            parameters = [
                "number": number?.firebaseSafe ?? "unknown"
            ]
        case .shareApp(let activity, let shared):
            event = "shareApp"
            parameters = [
                "destination": activity?.rawValue.firebaseSafe ?? "unknown",
                "complete": NSNumber(value: shared)
            ]
        case .spotlightClick(let spotlight):
            event = "spotlightClick"
            parameters = [
                "url": spotlight.link?.url?.absoluteString.firebaseSafe ?? "unknown"
            ]
        case .badgeUnlock(let badge, let unlocked):
            event = "earnBadge"
            parameters = [
                "total": NSNumber(value: BadgeController.shared.badges?.count ?? 0),
                "earnt": NSNumber(value: unlocked),
                "id": badge.id?.firebaseSafe ?? "unknown",
                "name": badge.title?.firebaseSafe ?? "unknown"
            ]
        case .switchLanguage(let language):
            event = "switchLanguage"
            parameters = [
                "language": language.fileName.firebaseSafe,
                "locale_id": language.locale.identifier.firebaseSafe
            ]
        default:
            return nil
        }
    }
}
