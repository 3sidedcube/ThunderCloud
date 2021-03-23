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
        var shareItems: [ShareItem] = []

        // `String` message to share
        let message = shareMessage ?? defaultMessage

        // `UIImage` of badge to share
        if let badgeImage = icon?.image {
            // Map `UIImage` to `BadgeShareItem`
            shareItems.append(BadgeShareItem(
                shareObject: badgeImage,
                isPrimaryItem: true,
                metadataTitle: message
            ))
        }

        // Map `String` share message to `BadgeShareItem`
        shareItems.append(BadgeShareItem(
            shareObject: message,
            isPrimaryItem: shareItems.isEmpty,
            metadataTitle: message
        ))

        return shareItems
    }
}

// MARK: - BadgeShareItem

/// `ShareItem` for `Badge`s
open class BadgeShareItem: ShareItem {

    /// Title for `LPLinkMetadata`
    public let metadataTitle: String

    // MARK: - Init

    public init(
        shareObject: Any,
        isPrimaryItem: Bool,
        metadataTitle: String
    ) {
        self.metadataTitle = metadataTitle
        super.init(shareObject: shareObject, isPrimaryItem: isPrimaryItem)
    }

    // MARK: - UIActivityViewController

    override open func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        guard isPrimaryItem else { return "" }
        return "Share Badge".localised(with: "_BADGE_SHARE")
    }

    @available(iOS 13, *)
    override open func activityViewControllerLinkMetadata(
        _ activityViewController: UIActivityViewController
    ) -> LPLinkMetadata? {
        let metadata = super.activityViewControllerLinkMetadata(activityViewController)
        metadata?.title = metadataTitle
        return metadata
    }
}
