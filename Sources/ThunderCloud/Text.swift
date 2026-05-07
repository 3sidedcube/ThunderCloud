//
//  Text.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 13/12/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

/// Storm text
public struct Text: Codable {
    
    /// Text content
    public var content: String
    
    /// Map `content` key to Storm `String` value
    public var contentValue: String? {
        return StormLanguageController.shared.string(forKey: content)
    }
}
