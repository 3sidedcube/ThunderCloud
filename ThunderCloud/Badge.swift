//
//  Badge.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 21/08/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// Keys for `Badge` properties from `Dictionary`
/// TODO: Consider migration to `Codable`
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
}

/// `Badge` is a model representation of a storm badge object
open class Badge: NSObject, StormObjectProtocol
{
    /// Fixed constants for `Badge`
    private struct Constants
    {
        /// Date format for `dateFrom` and `dateUntil`
        static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        /// Start time string for `Date`
        static let startTime = "00:00:00.000"
        
        /// End time string for `Date`
        static let endTime = "23:59:59.999"
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
    
    /// Inclusive start date of the badge
    public let dateFrom: Date?
    
    /// Exclusive end date of the badge
    public let dateUntil: Date?
    
    // MARK: - Computed
    
    /// The badge's icon, to be displayed in any badge scrollers e.t.c.
    open lazy var icon: StormImage? = { [unowned self] in
        return StormGenerator.image(fromJSON: iconObject)
    }()
    
    /// Local `DateFormatter` has:
    /// - `.iso8601` `Calendar`
    /// - "en_US_POSIX" `Locale`
    /// - Local `TimeZone`
    fileprivate static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }()
    
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
        
        /// campaign
        campaign = dictionary.value(for: .campaign)
        
        /// dateFrom - use start of day for time
        dateFrom = dictionary.date(for: .dateFrom, timeString: Constants.startTime)
        
        /// dateUntil - use end of day for time
        dateUntil = dictionary.date(for: .dateUntil, timeString: Constants.endTime)
        
        super.init()
    }
}

// MARK: - Extensions

fileprivate extension Dictionary where Key == AnyHashable, Value: Any {
    
    /// Quick helper to get a value by key `BadgeKey` and attempt to cast it as `T`
    func value<T>(for key: BadgeKey) -> T? {
        return self[key.rawValue] as? T
    }
    
    /// Invoke `value(for:)` and convert to `Date` via `DateFormatter.iso8601(dateFormat:)`
    func date(for key: BadgeKey, timeString: String) -> Date? {
        guard let dateString: String = value(for: key) else {
            return nil
        }
        return Badge.dateFormatter.date(from: "\(dateString)T\(timeString)")
    }
}
