//
//  JSONString.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/04/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation

extension String {
    
    /// Initialises a new string from a root JSON object (dictionary or array)
    /// - Parameters:
    ///   - jsonObject: The object to convert to a string
    ///   - options: Set of options to use when stringifying
    init?(_ jsonObject: Any, options: JSONSerialization.WritingOptions = [.prettyPrinted]) {
        guard JSONSerialization.isValidJSONObject(jsonObject) else {
            return nil
        }
        guard let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: options) else {
            return nil
        }
        guard let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        self = string
    }
}
