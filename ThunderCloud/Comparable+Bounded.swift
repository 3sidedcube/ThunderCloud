//
//  Comparable+Bounded.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 16/03/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import Foundation

extension Comparable {

    /// Bound `self` between `lower` and `upper`
    ///
    /// - Note:
    /// This is useful shorthand, but consider using a property wrapper instead!
    ///
    /// - Parameters:
    ///   - lower: Lower bound
    ///   - upper: Upper bound
    func bounded(lower: Self, upper: Self) -> Self {
        return max(lower, min(upper, self))
    }
}
