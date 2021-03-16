//
//  Sharable.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 16/03/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import Foundation

/// An entity which can create `[ShareItem]`
public protocol Shareable {

    /// Create `ShareItem`s with a default message if required
    /// 
    /// - Parameter defaultMessage: `String`  default share message
    func shareItems(defaultMessage: String) -> [ShareItem]
}
