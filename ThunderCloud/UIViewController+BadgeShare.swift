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
            .map { BadgeShareItem(shareObject: $0, isPrimaryItem: $0 is UIImage) }

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

class BadgeShareItem: ShareItem, ShareItemDelegate {

    // MARK: - Init

    override init(shareObject: Any, isPrimaryItem: Bool) {
        super.init(shareObject: shareObject, isPrimaryItem: isPrimaryItem)
        delegate = self
    }

    // MARK: - ShareItemDelegate

    func subjectForActivityType(
        _ activityType: UIActivity.ActivityType?,
        activityViewController: UIActivityViewController
    ) -> String {
        return "Badge Share".localised(with: "_BADGE_SHARE")
    }

    @available(iOS 13, *)
    func configureMetaData(
        _ metadata: LPLinkMetadata,
        activityViewController: UIActivityViewController
    ) {
        guard let text = shareObject as? String else { return }
        metadata.title = text
    }
}
