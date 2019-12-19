//
//  BadgeDB.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 10/12/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

/// Define `Badge` uniqueIdentifier
typealias BadgeId = String

/// The `Date` the badge was earnt
typealias DateEarned = Date

/// Map `BadgeId` unique identifier to corresponding `DateEarned`
typealias BadgeMap = [BadgeId: DateEarned]

// MARK: - BadgeDB

/// `Badge` database
final class BadgeDB {
   
    /// Key in the user defaults to save `BadgeMap`
    private static let userDefaultsKey = "com.3sidedcube.BadgeDb"
    
    /// Shared `BadgeDB` instance
    static let shared = BadgeDB()
    
    /// Serial `DispatchQueue` for writing to `UserDefaults`.
    /// Asynchronous work will happen off the calling thread, so a request to asynchronously write the data,
    /// from the main thread, would happen on a background thread.
    /// As it's synchronous, previous write requests would have to finish before the next is started
    private let writeQueue = DispatchQueue(label: "com.3sidedcube.BadgeDb.write")
    
    /// Manage in memory `BadgeMap`
    private var map: BadgeMap {
        didSet {
            writeAsync()
        }
    }
    
    /// Read data into `map`
    private init() {
        map = BadgeDB.read() ?? BadgeMap() // Will not call didSet
        synchronize()
    }
    
    // MARK: - Get/Set
    
    /// Get `DateEarned` for given `BadgeId`
    func get(badgeId: BadgeId) -> DateEarned? {
        return map[badgeId]
    }
    
    /// Set given `DateEarned` for given `BadgeId`.
    /// Set to `nil` to remove
    func set(badgeId: BadgeId, date: DateEarned?) {
        map[badgeId] = date
    }
    
    // MARK: - Synchronize
    
    /// Synchronize earned dates with earned badges - ideally move both into a single database
    func synchronize() {
        // Get earned badges
        var earnedBadges = BadgeController.shared.earnedBadges ?? []
        
        // Expire badges
        // Getting the `expirableAchievement` will invoke an expiry check, disregard the result
        _ = earnedBadges.compactMap { $0.expirableAchievement }
        
        // Refetch earned badges
        earnedBadges = BadgeController.shared.earnedBadges ?? []
        let earnedIds = earnedBadges.compactMap { $0.id }
        
        // Map db to update, want to fire a single `didSet` at the end
        var updatedMap = map
        
        // Remove badges that do not exist in the earnedBadges
        updatedMap = updatedMap.filter { earnedIds.contains($0.key) }
        
        // Set earnedDate to now for badges which have been previously earnt but not saved in db (e.g. migration)
        let now = Date()
        earnedIds.forEach {
            if updatedMap[$0] == nil {
                updatedMap[$0] = now
            }
        }
        
        // Sync database
        map = updatedMap
    }
    
    // MARK: - FileManagement
    
    /// Read `db` from `UserDefaults`
    private static func read() -> BadgeMap? {
        return UserDefaults.standard.object(forKey: BadgeDB.userDefaultsKey) as? BadgeMap
    }
    
    /// Write `db` to `UserDefaults` on `writeQueue`
    private func writeAsync() {
        // `map` instance
        let mapToWrite = map
        
        writeQueue.async {
            UserDefaults.standard.set(mapToWrite, forKey: BadgeDB.userDefaultsKey)
        }
    }
}
