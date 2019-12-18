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

/// Map unique identifier `BadgeId` to corresponding `BadgeElement`
typealias BadgeMap = [BadgeId: BadgeElement]

// MARK: - BadgeElement

/// Properties of `Badge` to persist in db
struct BadgeElement: Codable {
    
    /// `Date` the `Badge` was earned by the user
    var dateEarned: Date
}

// MARK: - BadgeDB

/// `Badge` database
final class BadgeDB {
    
    /// Filename for the database file
    private static let dbFilename = "BadgeDb.plist"
    
    /// Shared `BadgeDbManager` instance
    static let shared = BadgeDB()
    
    /// Serial queue for database updates
    private let queue = DispatchQueue(label: "com.3sidedcube.BadgeDb")
    
    /// Manage in memory `BadgeMap`
    private var map: BadgeMap {
        didSet {
            writeAsync()
        }
    }
    
    /// Read data into `map`
    private init() {
        map = (try? BadgeDB.read()) ?? BadgeMap()
    }
    
    // MARK: - Get/Set
    
    /// Get `BadgeElement` for given `badgeId`
    func get(badgeId: BadgeId) -> BadgeElement? {
        return map[badgeId]
    }
    
    /// Set given `element` for given `badgeId`
    func set(badgeId: BadgeId, element: BadgeElement?) {
        map[badgeId] = element
    }
    
    // MARK: - Synchronize
    
    /// Ensure we un-earn badges which have expired
    func expireBadges() {
        // Getting the `expirableAchievement` will invoke an expiry check, disregard the result
        _ = BadgeController.shared.earnedBadges?.compactMap { $0.expirableAchievement }
    }
    
    /// Synchronize earned dates with earned badges - ideally move both into a single database
    func synchronize() {
        // Expire badges
        expireBadges()
        
        // Get earned badges
        let earnedBadges = BadgeController.shared.earnedBadges ?? []
        let earnedIds = earnedBadges.compactMap { $0.id }
        
        // Syncronize about current time
        let now = Date()
        
        // Map db to update, want to fire a single `didSet` at the end
        var updatedMap = map
        
        // Remove badges that do not exist in the earnedBadges
        updatedMap = updatedMap.filter { earnedIds.contains($0.key) }
        
        // Set earnedDate to now for badges which have been previously earnt but not saved in db (e.g. migration)
        earnedIds.forEach {
            if updatedMap[$0] == nil {
                updatedMap[$0] = BadgeElement(dateEarned: now)
            }
        }
        
        // Sync database
        map = updatedMap
    }
    
    // MARK: - FileManagement
    
    /// Write `db` from file
    private static func read() throws -> BadgeMap {
        // Get URL to read from
        let url = try BadgeDB.dbURL()
        
        // Return now if the file does not exist
        if !FileManager.default.fileExists(atPath: url.path) {
            return BadgeMap()
        }
        
        // Get data to read
        let data = try Data(contentsOf: url, options: [])
        
        // Read the data
        return try PropertyListDecoder().decode(BadgeMap.self, from: data)
    }
    
    /// Write `db` to file on `queue`
    private func writeAsync() {
        
        // `map` instance
        let mapToWrite = map
        
        queue.async {
            do {
                // Get data to write
                let data = try PropertyListEncoder().encode(mapToWrite)
                
                // Get URL to write to
                let url = try BadgeDB.dbURL()
                
                // Write the data
                try data.write(to: url, options: .atomic)
                
            } catch {
                debugPrint("[ERROR] Failed to save BadgeDb: \(error)")
            }
        }
    }
    
    /// `URL` of the `db` file
    private static func dbURL() throws -> URL {
        let folder = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        return folder.appendingPathComponent(dbFilename)
    }
}
