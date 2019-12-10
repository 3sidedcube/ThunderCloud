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
    /// Note milliseconds including, for customization over `dateFormat`, see `iso8601(dateFormat:)`
    static let iso8601: DateFormatter = {
        return iso8601Formatter(
            timeZone: TimeZone(secondsFromGMT: 0),
            dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        )
    }()
    
    /// `DateFormatter` has:
    /// - `.iso8601` `Calendar`
    /// - "en_US_POSIX" `Locale`
    /// - Given `timeZone`
    /// - Given `dateFormat`
    static func iso8601Formatter(timeZone: TimeZone?, dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = dateFormat
        return formatter
    }
}
