//
//  Utilities.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 20/12/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation


/// Bound `value`between `lower` and `upper`
///
/// - Parameters:
///   - value: Value to bound
///   - lower: Lower bound
///   - upper: Upper bound
func bounded<T>(_ value: T, lower: T, upper: T) -> T where T : Comparable {
    return max(lower, min(upper, value))
}
