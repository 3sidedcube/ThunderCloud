//
//  Badge+Shareable.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 16/03/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import Foundation
import LinkPresentation

/// Make the `Badge` `Shareable`
extension Badge: Shareable {

    /// Share the `shareMessage` and `icon`
    ///
    /// - Parameter defaultMessage: `String` default message to fall back on
    public func shareItems(defaultMessage: String) -> [ShareItem] {
        var builder =  ShareItemBuilder(
            image: icon?.image,
            text: shareMessage ?? defaultMessage,
            url: nil,
            other: []
        )
        builder.subjectForActivityType = { _, _ in
            return "Share Badge".localised(with: "_BADGE_SHARE")
        }
        return builder.shareItems()
    }
}
