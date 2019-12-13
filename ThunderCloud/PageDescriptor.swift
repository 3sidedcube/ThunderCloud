//
//  PageDescriptor.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 13/12/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

/// Describes a Storm page
public struct PageDescriptor: Codable {

    /// The name of the badge
    public var name: String?
    
    /// Source
    /// E.g. cache://pages/23345.json
    public var src: String
    
    /// StartPage
    public var startPage: Bool?
    
    /// Type of page (e.g, `ListPage`)
    public var type: String
}
