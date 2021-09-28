//
//  ShareProvider.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 23/03/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import Foundation
import LinkPresentation

/// Configure share content
public protocol ShareProvider {

    /// Subject for `shareItem` for `activityType`
    /// 
    /// - Parameters:
    ///   - shareItem: `ShareItem`
    ///   - activityType: `UIActivity.ActivityType?`
    func subjectForShareItem(
        _ shareItem: ShareItem,
        for activityType: UIActivity.ActivityType?
    ) -> String

    /// Should share `shareItem` for `activityType`
    ///
    /// - Parameters:
    ///   - shareItem: `ShareItem`
    ///   - activityType: `UIActivity.ActivityType?`
    func shouldShareItem(
        _ shareItem: ShareItem,
        for activityType: UIActivity.ActivityType?
    ) -> Bool

    /// Create a `LPLinkMetadata`
    @available(iOS 13.0, *)
    func linkMetadata() -> LPLinkMetadata
}
