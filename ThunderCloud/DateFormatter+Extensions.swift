//
//  DateFormatter+Extensions.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 28/11/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    /// Standard `iso8601` `DateFormatter`
    /// Note milliseconds included, for customization over `dateFormat`, see `iso8601(dateFormat:timeZone:)`
    static var iso8601: DateFormatter {
        return iso8601Formatter(
            dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        )
    }
    
    /// `DateFormatter` has:
    /// - `.iso8601` `Calendar`
    /// - "en_US_POSIX" `Locale`
    /// - Given `timeZone`, defaults to `.current`
    /// - Given `dateFormat`
    static func iso8601Formatter(dateFormat: String, timeZone: TimeZone? = .current) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = dateFormat
        return formatter
    }
    
    /// Local date only `DateFormatter`
    static var localDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        return formatter
    }
}
