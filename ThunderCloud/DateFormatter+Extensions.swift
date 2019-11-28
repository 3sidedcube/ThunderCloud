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
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return formatter
    }()
}
