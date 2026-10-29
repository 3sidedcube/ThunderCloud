//
//  DateFormatter+Extensions.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 28/11/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

extension DateFormatter {
    
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
