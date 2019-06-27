//
//  BadgeController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 21/08/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

public let BADGES_CLEARED_NOTIFICATION = NSNotification.Name.init("BadgesClearedNotification")

/// `BadgeController` is a controller for managing badges, loaded from the content controller.
@objc(TSCBadgeController)
open class BadgeController: NSObject {
    
    @objc(sharedController)
    public static let shared = BadgeController()
    
    private var calculatedBadges: [Badge]? {
        guard let badgesFile = ContentController.shared.fileUrl(forResource: "badges", withExtension: "json", inDirectory: "data") else { return nil }
        guard let badgesData = try? Data(contentsOf: badgesFile) else { return nil }
        guard let badgesJSON = (try? JSONSerialization.jsonObject(with: badgesData, options: [])) as? [[AnyHashable : Any]] else { return nil }
        
        return badgesJSON.map({ (badgeDictionary) -> Badge in
            return Badge(dictionary: badgeDictionary)
        })
    }
    
    /// The array of available `Badge` objects from the CMS
    public lazy var badges: [Badge]? = { [unowned self] in
        return self.calculatedBadges
        }()
    
    public var earnedBadges: [Badge]? {
        return badges?.filter({
            guard let id = $0.id else { return false }
            return BadgeController.shared.hasEarntBadge(with: id)
        })
    }
    
    /// Returns the badge object for a specific ID
    ///
    /// - Parameter id: The id to find a badge for
    /// - Returns: The badge for the given ID, or nil if none was found
    @objc public func badge(for id: String) -> Badge? {
        
        guard let badges = badges else { return nil }
        
        return badges.first(where: { (badge) -> Bool in
            return badge.id == id
        })
    }
    
    /// Whether the user has earnt a specific badge
    ///
    /// - Parameter withId: The id for the badge
    /// - Returns: A boolean as to whether the badge is earnt
    @objc public func hasEarntBadge(with id: String?) -> Bool {
        
        guard let id = id else { return false }
        guard let earnedBadgeIds = UserDefaults.standard.array(forKey: "TSCCompletedQuizes") as? [String] else { return false }
        return earnedBadgeIds.contains(id)
    }
    
    /// Marks a badge as either earnt or not-earnt
    ///
    /// - Parameters:
    ///   - badge: The badge to mark as earnt or not-earnt
    ///   - earnt: Whether the badge was earned or not
    public func mark(badge: Badge, earnt: Bool) {
        
        guard let badgeId = badge.id else { return }
        
        var earnedBadges = UserDefaults.standard.array(forKey: "TSCCompletedQuizes") as? [String] ?? []
        
        if earnt && !hasEarntBadge(with: badgeId) {
            earnedBadges.append(badgeId)
        } else if !earnt, let removeIndex = earnedBadges.index(of: badgeId) {
            earnedBadges.remove(at: removeIndex)
        }
        
        UserDefaults.standard.set(earnedBadges, forKey: "TSCCompletedQuizes")
        
        NotificationCenter.default.sendAnalyticsHook(.badgeUnlock(badge, earnedBadges.count))
    }
    
    /// Resets all the user's earned badges
    public func clearEarnedBadges() {
        
        UserDefaults.standard.set(nil, forKey: "TSCCompletedQuizes")
        NotificationCenter.default.post(name: BADGES_CLEARED_NOTIFICATION, object: nil)
    }
    
    /// Reloads self.badges from storm data files
    @objc public func reloadBadgeData() {
        badges = calculatedBadges
    }
}
