//
//  UIViewController+BadgeShare.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 16/03/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import Foundation
import UIKit

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
            .map { ShareItem(shareObject: $0, isPrimaryItem: $0 is UIImage) }

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
