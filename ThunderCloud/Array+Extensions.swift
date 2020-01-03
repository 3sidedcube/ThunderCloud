//
//  Array+Extensions.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 03/01/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func removeAllAndReturn(where block: (Element) throws -> Bool) rethrows -> [Element] {
        var removed = [Element]()
        try removeAll {
            let rc = try block($0)
            if rc {
                removed.append($0)
            }
            return rc
        }
        return removed
    }
    
}
