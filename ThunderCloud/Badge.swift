//
//  Badge.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 21/08/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// Keys for `Badge` properties from `Dictionary`
enum BadgeKey: String {
    case completion
    case how
    case shareMessage
    case title
    case id
    case icon
    case campaign
    case dateFrom
    case dateUntil
    case validFor
}

/// `Badge` is a model representation of a storm badge object
open class Badge: NSObject, StormObjectProtocol
{
    // MARK: - Static
    
    /// Fixed constants for `Badge`
    private struct Constants
    {
        /// Format for date
        static let dateFormat = "yyyy-MM-dd"
        
        /// Format for time
        static let timeFormat = "HH:mm:ss.SSS"
        
        /// Date format for `dateFrom` and `dateUntil`
        static let dateTimeFormat = dateFormat + "'T'" + timeFormat
        
        /// Start time string for `Date`
        static let startOfDay = "00:00:00.000"
        
        /// End time string for `Date`
        static let endOfDay = "23:59:59.999"
    }
    
    /// Get `Date` using a **local** `DateFormatter`.
    /// Must provide a `dateString` and a `timeString`.
    fileprivate static func date(dateString: String?, timeString: String) -> Date? {
        guard let dateString = dateString else {
            return nil
        }
        
        let formatter = DateFormatter.iso8601Formatter(
            dateFormat: Constants.dateTimeFormat, timeZone: TimeZone.current)
        
        return formatter.date(from: "\(dateString)T\(timeString)")
    }
    
    // MARK: - Properties
    
    /// A string of text that is displayed when the badge is unlocked
    public let completionText: String?
    
    /// A string of text which informs the user how to unlock the badge
    public let howToEarnText: String?
    
    /// The text that is used when the user shares the badge
    public let shareMessage: String?
    
    /// The title of the badge
    public let title: String?
    
    /// The unique identifier for the badge
    public let id: String?
    
    /// A `Dictionary` representation of the badge's icon, this can be converted to a `TSCImage` to return the `UIImage` representation of the icon
    private var iconObject: Any?
    
    /// Campaign flag on the badge
    public let campaign: Bool?
    
    /// Date the badge starts as a **local** date
    public let dateFrom: String?
    
    /// Date the badge ends as a **local** date
    public let dateUntil: String?
    
    /// Number of days since a badge was achieved should it be valid before before it expires
    public let validFor: Int?
    
    // MARK: - Computed
    
    /// The badge's icon, to be displayed in any badge scrollers e.t.c.
    open lazy var icon: StormImage? = { [unowned self] in
        return StormGenerator.image(fromJSON: iconObject)
    }()
    
    /// Inclusive start date of the badge in **local** time
    public var startDate: Date? {
        return Badge.date(dateString: dateFrom, timeString: Constants.startOfDay)
    }
    
    /// Inclusive end date of the badge in **local** time
    public var endDate: Date? {
        return Badge.date(dateString: dateUntil, timeString: Constants.endOfDay)
    }
    
    // MARK: - Init
    
    required public init(dictionary: [AnyHashable : Any]) {
        
        if let completionTextDictionary = dictionary[BadgeKey.completion.rawValue] as? [AnyHashable : Any] {
            completionText = StormLanguageController.shared.string(for: completionTextDictionary)
        } else {
            completionText = nil
        }
        
        if let howToEarnTextDictionary = dictionary[BadgeKey.how.rawValue] as? [AnyHashable : Any] {
            howToEarnText = StormLanguageController.shared.string(for: howToEarnTextDictionary)
        } else {
            howToEarnText = nil
        }
        
        if let shareMessageDictionary = dictionary[BadgeKey.shareMessage.rawValue] as? [AnyHashable : Any] {
            shareMessage = StormLanguageController.shared.string(for: shareMessageDictionary)
        } else {
            shareMessage = nil
        }
        
        if let titleDictionary = dictionary[BadgeKey.title.rawValue] as? [AnyHashable : Any] {
            title = StormLanguageController.shared.string(for: titleDictionary)
        } else {
            title = nil
        }
        
        if let intId = dictionary[BadgeKey.id.rawValue] as? Int {
            id = "\(intId)"
        } else if let stringId = dictionary[BadgeKey.id.rawValue] as? String {
            id = stringId
        } else {
            id = nil
        }

        iconObject = dictionary[BadgeKey.icon.rawValue]
        
        campaign = dictionary.value(for: .campaign)
        
        /// dateFrom - use start of day for time
        dateFrom = dictionary.value(for: .dateFrom)
        
        /// dateUntil - use end of day for time
        dateUntil = dictionary.value(for: .dateUntil)
        
        validFor = dictionary.value(for: .validFor)
        
        super.init()
    }
}

// MARK: - Extensions

fileprivate extension Dictionary where Key == AnyHashable, Value: Any {
    
    /// Quick helper to get a value by key `BadgeKey` and attempt to cast it as `T`
    func value<T>(for key: BadgeKey) -> T? {
        return self[key.rawValue] as? T
    }
}
