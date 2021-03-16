//
//  UIViewController+BadgeShare.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 16/03/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import Foundation
import UIKit
import LinkPresentation

public extension UIViewController {

    /// Share the given `badge` using `UIActivityViewController`
    ///
    /// - Parameters:
    ///   - badge: `Badge` to share
    ///   - defaultShareMessage: Message to share if `badge.shareMessage` is `nil`
    ///   - completionHandler: Handle completion on `UIActivityViewController`
    func shareBadge(
        _ badge: Badge,
        defaultShareMessage: String,
        completionHandler: UIActivityViewController.CompletionWithItemsHandler? = nil
    ) {
        // `String` message to share
        let message: String = badge.shareMessage ?? defaultShareMessage

        // `UIImage` of badge to share
        let badgeImage = badge.icon?.image

        // Map parts to `ShareItem`
        let shareItems = [message, badgeImage as Any]
            .compactMap { $0 }
            .map { shareObject -> BadgeShareItem in
                let item = BadgeShareItem(
                    shareObject: shareObject,
                    isPrimaryItem: shareObject is UIImage
                )
                item.shareText = message
                item.badgeImage = badgeImage
                return item
            }

        // Ensure there is something to share
        guard !shareItems.isEmpty else { return }

        // Present a `UIActivityViewController`
        let shareViewController = UIActivityViewController(
            activityItems: shareItems,
            applicationActivities: nil
        )
        shareViewController.excludedActivityTypes = [
            .saveToCameraRoll, .print, .assignToContact
        ]

        shareViewController.completionWithItemsHandler = completionHandler
        present(shareViewController, animated: true, completion: nil)
    }
}

/// `ShareItem` for badges
class BadgeShareItem: ShareItem {

    /// `String` text when sharing a `Badge`
    var shareText: String?

    /// `UIImage` for badge icon
    var badgeImage: UIImage?

    override func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        guard isPrimaryItem else { return "" }
        return "Badge Share".localised(with: "_BADGE_SHARE")
    }

    @available(iOS 13, *)
    override func activityViewControllerLinkMetadata(
        _ activityViewController: UIActivityViewController
    ) -> LPLinkMetadata? {
        guard isPrimaryItem else { return nil }
        let metadata = LPLinkMetadata()

        // shareText
        if let title = shareText {
            metadata.title = title
        }

        // badgeImage
        if let image = badgeImage {
            metadata.imageProvider = NSItemProvider(object: image)
        }

        return metadata
    }
}
