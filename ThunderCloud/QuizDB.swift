//
//  BadgeDB.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 10/12/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation
import SQLite3

/// Define `Quiz` uniqueIdentifier
typealias QuizId = String

/// Map unique identifier for `Quiz` (`QuizId`) to a `QuizElement`
typealias QuizDb = [QuizId: QuizElement]

// MARK: - QuizElement

/// Properties of `Quiz` to persist in db
struct QuizElement: Codable {
    
    /// `Date` the `Quiz` was completed by the user
    var dateTimeStamp: Date
}

// MARK: - QuizDbManager

/// `Quiz` database
final class QuizDbManager {
    
    /// Filename for the database file
    private static let dbFilename = "quizDb.plist"
    
    /// Shared `QuizDbManager` instance
    static let shared = QuizDbManager()
    
    /// Serial queue for database updates
    private let queue = DispatchQueue(label: "com.3sidedcube.quizDb")
    
    /// Manage in memory `QuizDb`
    private var db = QuizDb() {
        didSet {
            writeAsync()
        }
    }
    
    /// Read db
    private init() {
        db = (try? QuizDbManager.read()) ?? QuizDb()
    }
    
    // MARK: - Get/Set
    
    /// Get `QuizElement` for given `quizId`
    func get(quizId: QuizId) -> QuizElement? {
        return db[quizId]
    }
    
    /// Set given `element` for given `quizId`
    func set(quizId: QuizId, element: QuizElement) {
        db[quizId] = element
    }
    
    // MARK: - FileManagement
    
    /// Write `db` from file
    private static func read() throws -> QuizDb {
        // Get URL to read from
        let url = try QuizDbManager.dbURL()
        
        // Get data to read
        let data = try Data(contentsOf: url, options: [])
        
        // Read the data
        return try PropertyListDecoder().decode(QuizDb.self, from: data)
    }
    
    /// Write `db` to file on `queue`
    private func writeAsync() {
        
        // Value of db instance
        let dbToWrite = db
        
        queue.async {
            do {
                // Get data to write
                let data = try PropertyListEncoder().encode(dbToWrite)
                
                // Get URL to write to
                let url = try QuizDbManager.dbURL()
                
                // Write the data
                try data.write(to: url, options: .atomic)
                
            } catch {
                debugPrint("[ERROR] Failed to save quizDb: \(error)")
            }
        }
    }
    
    /// `URL` of the `db` file
    private static func dbURL() throws -> URL {
        let fm = FileManager.default
        let folder = try fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)
        
        return folder.appendingPathComponent(dbFilename)
    }
}


