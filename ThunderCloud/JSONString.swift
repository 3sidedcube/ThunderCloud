//
//  JSONString.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/04/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation

/// A dummy protocol to make string initialiser from JSON objects more type-safe
protocol JSONEncodable {
    
}

extension Dictionary: JSONEncodable where Key: StringProtocol, Value: Any {
    
}

extension Array: JSONEncodable where Element: JSONEncodable {
    
}

extension String {
    
    /// Initialises a new string from a root JSON object (dictionary or array)
    /// - Parameters:
    ///   - jsonObject: The object to convert to a string
    ///   - options: Set of options to use when stringifying
    init?(_ jsonObject: JSONEncodable, options: JSONSerialization.WritingOptions = [.prettyPrinted]) {
        guard let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: options) else {
            return nil
        }
        guard let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        self = string
    }
}
